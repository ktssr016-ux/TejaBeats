import 'dart:developer';
import 'package:Bloomee/blocs/explore/cubit/explore_cubits.dart';
import 'package:Bloomee/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:Bloomee/blocs/lastdotfm/lastdotfm_cubit.dart';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/notification/notification_cubit.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/plugins/blocs/content/content_bloc.dart';
import 'package:Bloomee/plugins/blocs/content/content_event.dart';
import 'package:Bloomee/plugins/blocs/content/content_state.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_state.dart';
import 'package:Bloomee/screens/screen/home_views/recents_view.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/about.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/screens/screen/home_views/notification_view.dart';
import 'package:Bloomee/screens/screen/home_views/setting_view.dart';
import 'package:Bloomee/screens/screen/home_views/timer_view.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:go_router/go_router.dart';
import 'chart/carousal_widget.dart';
import '../widgets/horizontal_card_view.dart';
import 'package:Bloomee/utils/load_image.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool isUpdateChecked = false;
  late final ContentBloc _homeContentBloc;
  Future<List<Track>> lFMData = Future.value(const []);

  @override
  void initState() {
    super.initState();
    _homeContentBloc = ContentBloc(pluginService: ServiceLocator.pluginService);
    _tryLoadHomeSections();
  }

  void _tryLoadHomeSections() {
    final settingsState = context.read<SettingsCubit>().state;
    if (!settingsState.settingsReady) return;

    final pluginState = context.read<PluginBloc>().state;
    final contentResolvers = pluginState.loadedContentResolvers;
    if (contentResolvers.isEmpty) return;

    final preferredId = settingsState.homePluginId;
    if (preferredId.isNotEmpty) {
      final isAlreadyLoaded =
          contentResolvers.any((p) => p.manifest.id == preferredId);
      if (!isAlreadyLoaded) {
        final isInstalled = pluginState.availablePlugins
            .any((p) => p.manifest.id == preferredId);
        if (isInstalled) return;
      }
    }

    final pluginId = _effectiveHomePluginId(contentResolvers);

    if (_homeContentBloc.state.activePluginId == pluginId &&
        _homeContentBloc.state.homeSections != null) {
      return;
    }

    _homeContentBloc.add(GetHomeSections(pluginId: pluginId));
  }

  String _effectiveHomePluginId(List<dynamic> loadedResolvers) {
    final preferredId = context.read<SettingsCubit>().state.homePluginId;
    final hasPreferred = preferredId.isNotEmpty &&
        loadedResolvers.any((plugin) => plugin.manifest.id == preferredId);
    return hasPreferred ? preferredId : loadedResolvers.first.manifest.id;
  }

  @override
  void dispose() {
    _homeContentBloc.close();
    super.dispose();
  }

  Future<List<Track>> fetchLFMPicks(bool state, BuildContext ctx) async {
    if (state) {
      try {
        final data = await lFMData;
        if (data.isNotEmpty) return data;
        if (ctx.mounted) {
          final pluginState = ctx.read<PluginBloc>().state;
          final priority = ctx.read<SettingsCubit>().state.resolverPriority;
          final allIds = pluginState.loadedContentResolvers
              .map((p) => p.manifest.id)
              .toList();
          final resolverIds = [
            ...priority.where(allIds.contains),
            ...allIds.where((id) => !priority.contains(id)),
          ];
          lFMData = ctx.read<LastdotfmCubit>().getRecommendedTracks(
                resolverPluginIds: resolverIds,
              );
        }
        return (await lFMData);
      } catch (e) {
        log(e.toString(), name: "ExploreScreen");
      }
    }
    return const [];
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocListener(
        listeners: [
          BlocListener<SettingsCubit, SettingsState>(
            listenWhen: (previous, current) =>
                previous.homePluginId != current.homePluginId ||
                (!previous.settingsReady && current.settingsReady),
            listener: (context, state) {
              _homeContentBloc.add(const ClearHomeSections());
              _tryLoadHomeSections();
            },
          ),
          BlocListener<PluginBloc, PluginState>(
            listenWhen: (previous, current) {
              return previous.loadedContentResolvers !=
                      current.loadedContentResolvers ||
                   previous.loadedPluginIds != current.loadedPluginIds;
            },
            listener: (context, state) {
              if (state.loadedContentResolvers.isEmpty) {
                _homeContentBloc.add(const ClearHomeSections());
                return;
              }

              final activePluginId = _homeContentBloc.state.activePluginId;
              if (activePluginId != null &&
                  !state.loadedPluginIds.contains(activePluginId)) {
                _homeContentBloc.add(const ClearHomeSections());
                _tryLoadHomeSections();
                return;
              }

              _tryLoadHomeSections();
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: AppTheme.background,
          body: RefreshIndicator(
            color: AppTheme.accentPink,
            onRefresh: () async {
              final pluginId = _effectiveHomePluginId(
                context.read<PluginBloc>().state.loadedContentResolvers,
              );
              _homeContentBloc.add(
                GetHomeSections(pluginId: pluginId, bypassCache: true),
              );
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Custom Header App Bar
                SliverToBoxAdapter(
                  child: FadeSlideStagger(
                    index: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: AppTheme.spacingLG,
                        right: AppTheme.spacingLG,
                        top: AppTheme.spacingLG,
                        bottom: AppTheme.spacingSM,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_getGreeting()}, Teja 👋',
                                style: AppTheme.headingMedium.copyWith(
                                  fontFamily: 'Unageo',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'YOUR MUSIC. YOUR BEATS.',
                                style: AppTheme.labelSmall.copyWith(
                                  color: AppTheme.accentPink,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const NotificationIcon(),
                              const SizedBox(width: AppTheme.spacingXS),
                              const TimerIcon(),
                              const SizedBox(width: AppTheme.spacingXS),
                              const SettingsIcon(),
                              const SizedBox(width: AppTheme.spacingXS),
                              const SiteIcon(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Search Bar Adapter
                SliverToBoxAdapter(
                  child: FadeSlideStagger(
                    index: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingLG,
                        vertical: AppTheme.spacingMD,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          GoRouter.of(context).go('/Search');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            border: Border.all(
                              color: AppTheme.surfaceBorder.withValues(alpha: 0.4),
                              width: 0.5,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingLG,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                MingCute.search_2_line,
                                color: AppTheme.textTertiary,
                                size: AppTheme.iconSizeMD,
                              ),
                              const SizedBox(width: AppTheme.spacingSM),
                              Text(
                                'Search for songs, artists, albums...',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Quick Picks Adapter
                SliverToBoxAdapter(
                  child: FadeSlideStagger(
                    index: 2,
                    child: const _QuickPicksSection(),
                  ),
                ),

                // Carousel Widget (Featured/Trending)
                SliverToBoxAdapter(
                  child: FadeSlideStagger(
                    index: 3,
                    child: const Padding(
                      padding: EdgeInsets.only(top: AppTheme.spacingLG),
                      child: CaraouselWidget(),
                    ),
                  ),
                ),

                // Main body lists
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // Recently Played
                      FadeSlideStagger(
                        index: 4,
                        child: Padding(
                          padding: const EdgeInsets.only(top: AppTheme.spacingLG),
                          child: BlocBuilder<RecentlyCubit, RecentlyCubitState>(
                            builder: (context, state) {
                              if (state is RecentlyCubitInitial) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(AppTheme.spacingLG),
                                    child: CircularProgressIndicator(
                                      color: AppTheme.accentPink,
                                    ),
                                  ),
                                );
                              }
                              if (state.tracks.isNotEmpty) {
                                return _buildCuratedSection(
                                  context: context,
                                  title: 'Recently Played',
                                  tracks: state.tracks,
                                  onSeeAll: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const HistoryView(),
                                      ),
                                    );
                                  },
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),

                      // Made For You (Last.Fm Picks)
                      FadeSlideStagger(
                        index: 5,
                        child: BlocBuilder<SettingsCubit, SettingsState>(
                          builder: (context, state) {
                            if (state.lFMPicks) {
                              return FutureBuilder<List<Track>>(
                                future: fetchLFMPicks(state.lFMPicks, context),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      (snapshot.data?.isNotEmpty ?? false)) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: AppTheme.spacingLG),
                                      child: _buildCuratedSection(
                                        context: context,
                                        title: 'Made For You',
                                        tracks: snapshot.data!,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),

                      // Home sections from plugin (Trending Now, Continue Listening, etc.)
                      FadeSlideStagger(
                        index: 6,
                        child: BlocBuilder<ContentBloc, ContentState>(
                          bloc: _homeContentBloc,
                          builder: (context, state) {
                            final loadedResolvers = context
                                .read<PluginBloc>()
                                .state
                                .loadedContentResolvers;
                            if (loadedResolvers.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: SignBoardWidget(
                                  message:
                                      'No content plugin loaded.\nLoad a Content Resolver in Plugin Manager.',
                                  icon: MingCute.plugin_2_line,
                                ),
                              );
                            }

                            final sections = state.homeSections ?? const [];
                            final hasSections = sections.isNotEmpty;
                            final activePluginId = state.activePluginId;

                            if (activePluginId != null &&
                                !context
                                    .read<PluginBloc>()
                                    .state
                                    .loadedPluginIds
                                    .contains(activePluginId) &&
                                !hasSections) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: SignBoardWidget(
                                  message:
                                      'Refreshing Discover source...\nThe previous source is no longer available.',
                                  icon: MingCute.warning_line,
                                ),
                              );
                            }

                            if (state.homeSectionsStatus == DetailStatus.loading) {
                              if (hasSections) {
                                return _HomeSectionsList(
                                  sections: sections,
                                  contentBloc: _homeContentBloc,
                                  state: state,
                                );
                              }

                              return BlocBuilder<ConnectivityCubit,
                                  ConnectivityState>(
                                builder: (context, connState) {
                                  if (connState ==
                                      ConnectivityState.disconnected) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 24),
                                      child: SignBoardWidget(
                                        message: 'No Internet Connection!',
                                        icon: MingCute.wifi_off_line,
                                      ),
                                    );
                                  }

                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 40),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppTheme.accentPink,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }

                            if (state.homeSectionsStatus == DetailStatus.error) {
                              if (hasSections) {
                                return _HomeSectionsList(
                                  sections: sections,
                                  contentBloc: _homeContentBloc,
                                  state: state,
                                );
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: SignBoardWidget(
                                  message: state.error ??
                                      'Failed to load home sections.',
                                  icon: MingCute.sweats_line,
                                ),
                              );
                            }

                            if (!hasSections) {
                              return const SizedBox.shrink();
                            }

                            return _HomeSectionsList(
                              sections: sections,
                              contentBloc: _homeContentBloc,
                              state: state,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXXL),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCuratedSection({
    required BuildContext context,
    required String title,
    required List<Track> tracks,
    VoidCallback? onSeeAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLG,
            vertical: AppTheme.spacingSM,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTheme.headingSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  style: AppTheme.ghostButtonStyle(),
                  child: Row(
                    children: [
                      Text('See All', style: AppTheme.labelSmall.copyWith(color: AppTheme.accentPink)),
                      const Icon(Icons.chevron_right_rounded, size: 16, color: AppTheme.accentPink),
                    ],
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 195,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSM),
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSM),
                child: GestureDetector(
                  onTap: () {
                    context.read<BloomeePlayerCubit>().bloomeePlayer.loadPlaylist(
                          Playlist(
                            tracks: tracks,
                            title: title,
                          ),
                          idx: index,
                          doPlay: true,
                        );
                  },
                  child: Container(
                    width: 130,
                    margin: const EdgeInsets.only(bottom: AppTheme.spacingXS),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: AppTheme.borderRadiusLG,
                              child: Container(
                                height: 130,
                                width: 130,
                                color: AppTheme.surfaceLight,
                                child: LoadImageCached(
                                  imageUrl: track.thumbnail.urlLow ?? track.thumbnail.url,
                                  fallbackUrl: track.thumbnail.url,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.labelMedium.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          track.artists.isNotEmpty
                              ? track.artists.map((a) => a.name).join(', ')
                              : 'Unknown Artist',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class FuturisticHoverCard extends StatefulWidget {
  final Map<String, dynamic> pick;
  final VoidCallback onTap;

  const FuturisticHoverCard({
    super.key,
    required this.pick,
    required this.onTap,
  });

  @override
  State<FuturisticHoverCard> createState() => _FuturisticHoverCardState();
}

class _FuturisticHoverCardState extends State<FuturisticHoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final gradient = widget.pick['gradient'] as Gradient;
    final firstColor = gradient.colors.first;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.06 : 1.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 140,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: AppTheme.borderRadiusLG,
              border: Border.all(
                color: _isHovered
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.15),
                width: _isHovered ? 1.5 : 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: firstColor.withValues(alpha: _isHovered ? 0.65 : 0.35),
                  blurRadius: _isHovered ? 20 : 12,
                  spreadRadius: _isHovered ? 2 : 0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedRotation(
                  turns: _isHovered ? 0.04 : 0.0,
                  duration: const Duration(milliseconds: 220),
                  child: Icon(
                    widget.pick['icon'] as IconData,
                    color: Colors.white,
                    size: AppTheme.iconSizeLG,
                  ),
                ),
                Text(
                  widget.pick['label'] as String,
                  style: AppTheme.labelMedium.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickPicksSection extends StatelessWidget {
  const _QuickPicksSection();

  static final List<Map<String, dynamic>> _quickPicks = [
    {
      'label': 'Chill Vibes',
      'query': 'Chill Vibes',
      'icon': MingCute.music_2_line,
      'gradient': const LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )
    },
    {
      'label': 'Workout',
      'query': 'Workout',
      'icon': MingCute.run_line,
      'gradient': AppTheme.accentGradient,
    },
    {
      'label': 'Focus',
      'query': 'Focus',
      'icon': MingCute.book_5_line,
      'gradient': const LinearGradient(
        colors: [Color(0xFF0EA5E0), Color(0xFF10B981)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )
    },
    {
      'label': 'Romantic',
      'query': 'Romantic',
      'icon': MingCute.heart_line,
      'gradient': const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFEC4899)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )
    },
    {
      'label': 'Party',
      'query': 'Party',
      'icon': MingCute.music_line,
      'gradient': const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppTheme.spacingLG,
            bottom: AppTheme.spacingSM,
            top: AppTheme.spacingSM,
          ),
          child: Text(
            'Quick Picks',
            style: AppTheme.headingSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSM),
            itemCount: _quickPicks.length,
            itemBuilder: (context, index) {
              final pick = _quickPicks[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSM),
                child: FuturisticHoverCard(
                  pick: pick,
                  onTap: () {
                    GoRouter.of(context).go(
                      '/Search?query=${Uri.encodeComponent(pick['query'] as String)}',
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HomeSectionsList extends StatelessWidget {
  final List<Section> sections;
  final ContentBloc contentBloc;
  final ContentState state;

  const _HomeSectionsList({
    required this.sections,
    required this.contentBloc,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemExtent: 275,
      padding: const EdgeInsets.only(top: 0),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return HorizontalCardView(
          section: section,
          pluginId: contentBloc.state.activePluginId ?? '',
          canLoadMore: section.moreLink != null,
          isLoadingMore: state.isHomeSectionLoading(section.id),
          onLoadMore: section.moreLink == null
              ? null
              : () {
                  contentBloc.add(
                    LoadMoreHomeSectionItems(
                      pluginId: contentBloc.state.activePluginId ?? '',
                      sectionId: section.id,
                      moreLink: section.moreLink!,
                    ),
                  );
                },
        );
      },
    );
  }
}

class AnimatedHoverIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final double size;

  const AnimatedHoverIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color = AppTheme.textSecondary,
    this.size = 24.0,
  });

  @override
  State<AnimatedHoverIconButton> createState() => _AnimatedHoverIconButtonState();
}

class _AnimatedHoverIconButtonState extends State<AnimatedHoverIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _isHovered ? 1.22 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _isHovered ? AppTheme.accentPink.withValues(alpha: 0.18) : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: AppTheme.accentPink.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
            child: Icon(
              widget.icon,
              color: _isHovered ? AppTheme.accentPink : widget.color,
              size: widget.size,
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        return AnimatedHoverIconButton(
          icon: MingCute.notification_line,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationView(),
              ),
            );
          },
        );
      },
    );
  }
}

class TimerIcon extends StatelessWidget {
  const TimerIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedHoverIconButton(
      icon: MingCute.stopwatch_line,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TimerView()),
        );
      },
    );
  }
}

class SettingsIcon extends StatelessWidget {
  const SettingsIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedHoverIconButton(
      icon: MingCute.settings_3_line,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsView()),
        );
      },
    );
  }
}

class SiteIcon extends StatelessWidget {
  const SiteIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedHoverIconButton(
      icon: MingCute.music_2_line,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const About()),
        );
      },
    );
  }
}

class FadeSlideStagger extends StatelessWidget {
  const FadeSlideStagger({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 15 * (1.0 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
