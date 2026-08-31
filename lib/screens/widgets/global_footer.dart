import 'package:Bloomee/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:Bloomee/screens/widgets/player_overlay_wrapper.dart';
import 'package:Bloomee/screens/widgets/mini_player_widget.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:Bloomee/core/constants/route_paths.dart';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/screens/screen/home_views/setting_view.dart';
import 'package:Bloomee/screens/widgets/create_playlist_bottomsheet.dart';

class GlobalFooter extends StatelessWidget {
  const GlobalFooter({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    context.watch<PlayerOverlayCubit>();
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return PlayerOverlayWrapper(
      child: BackButtonListener(
        onBackButtonPressed: () async {
          final overlayC = context.read<PlayerOverlayCubit>();
          final router = GoRouter.of(context);

          if (router.canPop()) {
            router.pop();
            return true;
          }

          if (overlayC.state && overlayC.collapseUpNextPanel()) {
            return true;
          }

          if (overlayC.state) {
            overlayC.hidePlayer();
            return true;
          }

          return false;
        },
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            await _handleHardwareBackPress(context);
          },
          child: Scaffold(
            backgroundColor: Default_Theme.themeColor,
            drawerScrimColor: Default_Theme.themeColor,
            body: isMobile
                ? _AnimatedPageView(navigationShell: navigationShell)
                : Row(
                    children: [
                      DesktopSidebar(navigationShell: navigationShell),
                      Expanded(
                        child:
                            _AnimatedPageView(navigationShell: navigationShell),
                      ),
                    ],
                  ),
            bottomNavigationBar: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MiniPlayerWidget(),
                  if (isMobile)
                    Container(
                      color: Colors.transparent,
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: HorizontalNavBar(navigationShell: navigationShell),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleHardwareBackPress(BuildContext context) async {
    final overlayC = context.read<PlayerOverlayCubit>();
    final router = GoRouter.of(context);

    if (router.canPop()) {
      router.pop();
      return;
    }

    if (overlayC.state && overlayC.collapseUpNextPanel()) return;

    if (overlayC.state) {
      overlayC.hidePlayer();
      return;
    }

    if (navigationShell.currentIndex != 0) {
      navigationShell.goBranch(0);
      return;
    }

    if (context.mounted) {
      await SystemNavigator.pop();
    }
  }
}

class _AnimatedPageView extends StatefulWidget {
  const _AnimatedPageView({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  State<_AnimatedPageView> createState() => _AnimatedPageViewState();
}

class _AnimatedPageViewState extends State<_AnimatedPageView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.navigationShell.currentIndex;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(_AnimatedPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.navigationShell.currentIndex != _previousIndex) {
      _previousIndex = widget.navigationShell.currentIndex;
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.navigationShell,
      ),
    );
  }
}

class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final activeBranch = navigationShell.currentIndex;
    final l10n = AppLocalizations.of(context)!;
    
    final isHomeActive = activeBranch == 0;
    final isSearchActive = activeBranch == 2;
    final isLibraryActive = activeBranch == 1 || activeBranch == 3 || activeBranch == 4;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border(
          right: BorderSide(
            color: AppTheme.surfaceBorder.withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 24, top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF2D78), Color(0xFFFF5252), Color(0xFFFF6B35)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF2D78).withValues(alpha: 0.5),
                            blurRadius: 16,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'TB',
                          style: TextStyle(
                            fontFamily: 'Unageo',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TEJABEATS',
                          style: TextStyle(
                            fontFamily: 'Unageo',
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'YOUR MUSIC. YOUR BEATS.',
                          style: TextStyle(
                            fontFamily: 'Gilroy',
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          _SidebarItem(
            icon: MingCute.home_4_fill,
            label: l10n.navHome,
            isActive: isHomeActive,
            onTap: () => navigationShell.goBranch(0),
          ),
          const SizedBox(height: 6),
          _SidebarItem(
            icon: MingCute.search_2_fill,
            label: l10n.navSearch,
            isActive: isSearchActive,
            onTap: () => navigationShell.goBranch(2),
          ),
          const SizedBox(height: 6),
          _SidebarItem(
            icon: MingCute.book_5_fill,
            label: l10n.navLibrary,
            isActive: isLibraryActive,
            onTap: () => navigationShell.goBranch(1),
          ),
          
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PLAYLISTS',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.textTertiary,
                    letterSpacing: 1.2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_rounded, size: 20),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    createPlaylistDialog(context);
                  },
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),
          
          _SidebarPlaylistItem(
            icon: MingCute.heart_fill,
            iconColor: const Color(0xFFFF2D78),
            label: 'My Favourites',
            onTap: () {
              context.pushNamed(RoutePaths.playlistView, extra: 'Liked');
            },
          ),

          BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
            builder: (context, state) {
              final userPlaylists = state.playlists
                  .where((p) => p.playlistName != 'Liked')
                  .toList();

              if (userPlaylists.isEmpty) {
                return Column(
                  children: [
                    _SidebarPlaylistItem(
                      icon: MingCute.music_2_line,
                      label: 'Chill Beats',
                      onTap: () {
                        context.pushNamed(RoutePaths.searchScreen,
                            queryParameters: {'query': 'Chill Beats'});
                      },
                    ),
                    _SidebarPlaylistItem(
                      icon: Icons.bar_chart_rounded,
                      label: 'Workout Mix',
                      onTap: () {
                        context.pushNamed(RoutePaths.searchScreen,
                            queryParameters: {'query': 'Workout Mix'});
                      },
                    ),
                    _SidebarPlaylistItem(
                      icon: MingCute.car_fill,
                      iconColor: const Color(0xFFFF9800),
                      label: 'Roadtrip Songs',
                      onTap: () {
                        context.pushNamed(RoutePaths.searchScreen,
                            queryParameters: {'query': 'Roadtrip Songs'});
                      },
                    ),
                  ],
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: userPlaylists.map((p) {
                  return _SidebarPlaylistItem(
                    icon: MingCute.playlist_fill,
                    iconColor: const Color(0xFFFF2D78),
                    label: p.playlistName,
                    onTap: () {
                      context.pushNamed(RoutePaths.playlistView,
                          extra: p.playlistName);
                    },
                  );
                }).toList(),
              );
            },
          ),
          
          const Spacer(),
          
          _SidebarItem(
            icon: MingCute.settings_1_fill,
            label: 'Settings',
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsView()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppTheme.durationFast,
          curve: AppTheme.curveDefault,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppTheme.accentPink.withValues(alpha: 0.12)
                : _isHovered
                    ? AppTheme.surfaceLight.withValues(alpha: 0.5)
                    : Colors.transparent,
            borderRadius: AppTheme.borderRadiusMD,
            border: widget.isActive
                ? Border.all(color: AppTheme.accentPink.withValues(alpha: 0.3), width: 0.5)
                : Border.all(color: Colors.transparent, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: widget.isActive
                    ? AppTheme.accentPink
                    : _isHovered
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: AppTheme.labelMedium.copyWith(
                    color: widget.isActive
                        ? AppTheme.accentPink
                        : _isHovered
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarPlaylistItem extends StatefulWidget {
  const _SidebarPlaylistItem({
    required this.label,
    required this.onTap,
    this.icon = MingCute.playlist_line,
    this.iconColor,
  });

  final String label;
  final VoidCallback onTap;
  final IconData icon;
  final Color? iconColor;

  @override
  State<_SidebarPlaylistItem> createState() => _SidebarPlaylistItemState();
}

class _SidebarPlaylistItemState extends State<_SidebarPlaylistItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppTheme.durationFast,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppTheme.surfaceLight.withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: AppTheme.borderRadiusSM,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: widget.iconColor ??
                    (_isHovered ? AppTheme.textPrimary : AppTheme.textTertiary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bodyMedium.copyWith(
                    color: _isHovered ? AppTheme.textPrimary : AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HorizontalNavBar extends StatelessWidget {
  const HorizontalNavBar({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  int _mapBranchToMobileIndex(int branchIndex) {
    switch (branchIndex) {
      case 0:
        return 0; // Home
      case 2:
        return 1; // Search
      case 1:
      case 3:
      case 4:
        return 2; // Library (highlight library tab for sub-pages)
      default:
        return 0;
    }
  }

  void _onMobileTabChange(int index, BuildContext context) {
    switch (index) {
      case 0:
        navigationShell.goBranch(0); // Home
        break;
      case 1:
        navigationShell.goBranch(2); // Search
        break;
      case 2:
        navigationShell.goBranch(1); // Library
        break;
      case 3:
        context.read<PlayerOverlayCubit>().showPlayer(); // Now Playing
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = _mapBranchToMobileIndex(navigationShell.currentIndex);

    return GNav(
      gap: 7.0,
      tabBackgroundColor: AppTheme.accentPink.withValues(alpha: 0.15),
      color: AppTheme.textSecondary,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      activeColor: AppTheme.accentPink,
      textStyle: AppTheme.labelMedium.copyWith(color: AppTheme.accentPink),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      backgroundColor: Colors.transparent,
      tabs: [
        GButton(icon: MingCute.home_4_fill, text: l10n.navHome),
        GButton(icon: MingCute.search_2_fill, text: l10n.navSearch),
        GButton(icon: MingCute.book_5_fill, text: l10n.navLibrary),
        GButton(icon: MingCute.music_2_fill, text: 'Now Playing'),
      ],
      selectedIndex: currentIndex,
      onTabChange: (index) => _onMobileTabChange(index, context),
    );
  }
}
