import 'dart:async';
import 'dart:ui';

import 'package:Bloomee/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:Bloomee/utils/download_types.dart';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:Bloomee/core/adapters/track_adapter.dart';
import 'package:Bloomee/screens/screen/home_views/timer_view.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/player_setting.dart';
import 'package:Bloomee/screens/widgets/gradient_progress_bar.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/up_next_panel.dart';
import 'package:Bloomee/screens/widgets/volume_slider.dart';
import 'package:Bloomee/screens/widgets/media_metadata_links.dart';
import 'package:Bloomee/screens/screen/player_views/segments_sheet.dart';
import 'package:Bloomee/services/bloomee_player.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/services/player/player_engine.dart';
import 'package:Bloomee/screens/widgets/like_widget.dart';
import 'package:Bloomee/screens/widgets/play_pause_widget.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:Bloomee/utils/pallete_generator.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../blocs/media_player/bloomee_player_cubit.dart';
import '../../blocs/mini_player/mini_player_cubit.dart';
import 'player_views/fullscreen_lyrics_view.dart';

class AudioPlayerView extends StatefulWidget {
  const AudioPlayerView({super.key});

  @override
  State<AudioPlayerView> createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<AudioPlayerView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UpNextPanelController _upNextPanelController = UpNextPanelController();
  late final PlayerOverlayCubit _playerOverlayCubit;

  @override
  void initState() {
    super.initState();
    _playerOverlayCubit = context.read<PlayerOverlayCubit>();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _playerOverlayCubit.registerUpNextPanelCollapse(
              () => _upNextPanelController.collapse(),
            );
      }
    });
  }

  @override
  void dispose() {
    _playerOverlayCubit.unregisterUpNextPanelCollapse();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloomeePlayerCubit = context.read<BloomeePlayerCubit>();
    final musicPlayer = bloomeePlayerCubit.bloomeePlayer;
    final isMobile = ResponsiveBreakpoints.of(context).smallerOrEqualTo(TABLET);

    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
          onPressed: () {
            if (!_upNextPanelController.collapse()) {
              context.read<PlayerOverlayCubit>().hidePlayer();
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              final mi = musicPlayer.mediaItem.valueOrNull;
              if (mi != null) {
                showSegmentsSheet(
                  context,
                  trackId: mi.id,
                  trackDuration: mi.duration ?? Duration.zero,
                  onSeek: (pos) => musicPlayer.seek(pos),
                );
              }
            },
            icon: const Icon(MingCute.list_check_3_line,
                size: 22, color: AppTheme.textPrimary),
          ),
          IconButton(
            onPressed: () =>
                showMoreBottomSheet(context, musicPlayer.currentMedia),
            icon: const Icon(MingCute.more_2_fill,
                size: 25, color: AppTheme.textPrimary),
          )
        ],
        title: Column(
          children: [
            Text(
              l10n.playerEnjoyingFrom.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppTheme.labelMedium.copyWith(
                fontSize: 10,
                letterSpacing: 1.5,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            StreamBuilder<String>(
              stream: musicPlayer.queueTitle,
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? l10n.playerUnknownQueue,
                  textAlign: TextAlign.center,
                  style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentPink,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(seconds: 1),
        child: isMobile
            ? LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned.fill(
                        child: _PlayerUI(
                          musicPlayer: musicPlayer,
                          tabController: _tabController,
                        ),
                      ),
                      UpNextPanel(
                        peekHeight: 60.0,
                        parentHeight: constraints.maxHeight,
                        controller: _upNextPanelController,
                      ),
                    ],
                  );
                },
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 400,
                      maxWidth: MediaQuery.of(context).size.width * 0.60,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _PlayerUI(
                        musicPlayer: musicPlayer,
                        tabController: _tabController,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: UpNextPanel(
                          peekHeight: 60,
                          parentHeight:
                              MediaQuery.of(context).size.height * 0.8,
                          isDesktopMode: true,
                          controller: _upNextPanelController,
                        ),
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}

class _PlayerUI extends StatelessWidget {
  final BloomeeMusicPlayer musicPlayer;
  final TabController tabController;

  const _PlayerUI({
    required this.musicPlayer,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: tabController.animation!,
            builder: (context, child) {
              return Opacity(
                opacity: (1 - tabController.animation!.value),
                child: child,
              );
            },
            child: const RepaintBoundary(child: AmbientImgShadowWidget()),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 40),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: CoverImageVolSlider(),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: PlayerCtrlWidgets(musicPlayer: musicPlayer),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }
}

class CoverImageVolSlider extends StatefulWidget {
  const CoverImageVolSlider({super.key});

  @override
  State<CoverImageVolSlider> createState() => _CoverImageVolSliderState();
}

class _CoverImageVolSliderState extends State<CoverImageVolSlider> {
  Color? _cachedColor;
  String? _lastArtUri;
  StreamSubscription? _mediaSub;
  bool _fetchingPalette = false;

  @override
  void initState() {
    super.initState();
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
    _mediaSub = player.mediaItem.listen((mi) {
      final artUri = mi?.artUri?.toString();
      if (artUri != _lastArtUri) {
        _lastArtUri = artUri;
        _fetchPalette(artUri);
      }
    });
    // Initial fetch
    final current = player.mediaItem.valueOrNull;
    _lastArtUri = current?.artUri?.toString();
    _fetchPalette(_lastArtUri);
  }

  Future<void> _fetchPalette(String? artUri) async {
    if (artUri == null || artUri.isEmpty || _fetchingPalette) return;
    _fetchingPalette = true;
    try {
      final palette = await getPalleteFromImage(artUri);
      if (mounted) {
        setState(() => _cachedColor = palette.dominantColor?.color);
      }
    } catch (_) {
    } finally {
      _fetchingPalette = false;
    }
  }

  @override
  void dispose() {
    _mediaSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloomeePlayerCubit = context.read<BloomeePlayerCubit>();

    return VolumeDragController(
      child: StreamBuilder<MediaItem?>(
        stream: bloomeePlayerCubit.bloomeePlayer.mediaItem,
        builder: (context, snapshot) {
          final currentTrack =
              bloomeePlayerCubit.bloomeePlayer.currentTrackInfo;
          final highResUrl =
              currentTrack.thumbnail.urlHigh ?? currentTrack.thumbnail.url;
          final lowResUrl =
              currentTrack.thumbnail.urlLow ?? currentTrack.thumbnail.url;

          final glowColor = _cachedColor ?? AppTheme.accentPink;

          return SizedBox.expand(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                    boxShadow: [
                      BoxShadow(
                        color: glowColor.withValues(alpha: 0.5),
                        blurRadius: 40,
                        spreadRadius: 4,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: AppTheme.accentOrange.withValues(alpha: 0.25),
                        blurRadius: 60,
                        spreadRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: AppTheme.accentPink.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLG - 1),
                    child: LoadImageCached(
                      imageUrl: highResUrl,
                      fallbackUrl: lowResUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PlayerCtrlWidgets extends StatelessWidget {
  final BloomeeMusicPlayer musicPlayer;
  const PlayerCtrlWidgets({super.key, required this.musicPlayer});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _SongInfoRow(),
        const SizedBox(height: 15),
        const _PlayerProgressBar(),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: _PlayerControlsRow(musicPlayer: musicPlayer),
        ),
        const SizedBox(height: 25),
        const _UtilityTray(),
      ],
    );
  }
}

class _SongInfoRow extends StatelessWidget {
  const _SongInfoRow();

  @override
  Widget build(BuildContext context) {
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<MediaItem?>(
            stream: player.mediaItem,
            builder: (context, snapshot) {
              final currentTrack = player.currentTrackInfo;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentTrack.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.headingMedium.copyWith(
                      fontSize: 22,
                      fontFamily: 'Unageo',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TrackMetadataLinks(
                    track: currentTrack,
                    showAlbum: currentTrack.album != null,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        const _DownloadButton(),
        const _LikeButton(),
      ],
    );
  }
}

class _DownloadButton extends StatefulWidget {
  const _DownloadButton();

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  String? _lastTrackId;
  bool _isDownloaded = false;
  StreamSubscription? _mediaSub;

  @override
  void initState() {
    super.initState();
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
    _mediaSub = player.mediaItem.listen((mi) {
      if (mi?.id != _lastTrackId) {
        _lastTrackId = mi?.id;
        _queryDownloadState(mi);
      }
    });
    _queryDownloadState(player.mediaItem.valueOrNull);
  }

  void _queryDownloadState(MediaItem? mi) {
    if (mi == null) {
      if (mounted) setState(() => _isDownloaded = false);
      return;
    }
    final downloaded = context.read<DownloaderCubit>().isDownloaded(mi.id);
    if (mounted) {
      setState(() {
        _isDownloaded = downloaded;
      });
    }
  }

  @override
  void dispose() {
    _mediaSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
    final mi = player.mediaItem.valueOrNull;

    if (mi == null) return const SizedBox.shrink();

    return BlocBuilder<DownloaderCubit, DownloaderState>(
      builder: (context, state) {
        final isThisDownloading = state.downloads.any((p) =>
            p.task.mediaId == mi.id &&
            (p.status.state == DownloadState.downloading ||
                p.status.state == DownloadState.queued ||
                p.status.state == DownloadState.resolving ||
                p.status.state == DownloadState.fetchingMetadata));

        if (isThisDownloading) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.accentPink,
              ),
            ),
          );
        }

        return IconButton(
          onPressed: () {
            if (_isDownloaded) {
              SnackbarService.showMessage('Already downloaded');
            } else {
              context.read<DownloaderCubit>().downloadSong(mediaItemToTrack(mi));
              _queryDownloadState(mi);
            }
          },
          icon: Icon(
            _isDownloaded ? MingCute.check_circle_fill : MingCute.download_2_line,
            color: _isDownloaded ? AppTheme.accentPink : AppTheme.textPrimary,
            size: 24,
          ),
        );
      },
    );
  }
}

class _LikeButton extends StatefulWidget {
  const _LikeButton();

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton> {
  String? _lastTrackId;
  bool _isLiked = false;
  StreamSubscription? _mediaSub;

  @override
  void initState() {
    super.initState();
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
    _mediaSub = player.mediaItem.listen((mi) {
      if (mi?.id != _lastTrackId) {
        _lastTrackId = mi?.id;
        _queryLikeState(mi);
      }
    });
    _queryLikeState(player.mediaItem.valueOrNull);
  }

  Future<void> _queryLikeState(MediaItem? mi) async {
    if (mi == null) {
      if (mounted) setState(() => _isLiked = false);
      return;
    }
    final liked = await context
        .read<LibraryItemsCubit>()
        .isTrackLiked(mediaItemToTrack(mi));
    if (mounted) setState(() => _isLiked = liked);
  }

  @override
  void dispose() {
    _mediaSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<MediaItem?>(
      stream: player.mediaItem,
      builder: (context, snapshot) {
        final currentMedia = player.currentMedia;
        return LikeBtnWidget(
          isLiked: _isLiked,
          iconSize: 26,
          onLiked: () {
            context
                .read<LibraryItemsCubit>()
                .setTrackLiked(currentMedia, true);
            setState(() => _isLiked = true);
            SnackbarService.showMessage(l10n.playerLiked(currentMedia.title));
          },
          onDisliked: () {
            context
                .read<LibraryItemsCubit>()
                .setTrackLiked(currentMedia, false);
            setState(() => _isLiked = false);
            SnackbarService.showMessage(l10n.playerUnliked(currentMedia.title));
          },
        );
      },
    );
  }
}

class _PlayerProgressBar extends StatelessWidget {
  const _PlayerProgressBar();

  @override
  Widget build(BuildContext context) {
    final playerCubit = context.read<BloomeePlayerCubit>();
    return RepaintBoundary(
      child: StreamBuilder<ProgressBarStreams>(
        stream: playerCubit.progressStreams,
        builder: (context, snapshot) {
          final data = snapshot.data;
          return GradientProgressBar.fromAccentColors(
            progress: data?.position ?? Duration.zero,
            total: data?.duration ?? Duration.zero,
            buffered: data?.buffered ?? Duration.zero,
            onSeek: playerCubit.bloomeePlayer.seek,
            isPlaying: data?.isPlaying ?? false,
            activeAccentColor: AppTheme.accentPink,
            inactiveAccentColor: AppTheme.textSecondary,
            activeGradientStyle: GradientStyle.lightAndBreezy,
            inactiveGradientStyle: GradientStyle.warmAndRich,
            trackHeight: 4.0,
            thumbRadius: 6.0,
            timeLabelPadding: 6,
            timeLabelStyle: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            timeLabelLocation: TimeLabelLocation.below,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
            animationDuration: const Duration(milliseconds: 200),
            animationCurve: Curves.easeOutCubic,
          );
        },
      ),
    );
  }
}

class _PlayerControlsRow extends StatelessWidget {
  final BloomeeMusicPlayer musicPlayer;
  const _PlayerControlsRow({required this.musicPlayer});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const _ShuffleControl(),
        IconButton(
          icon: const Icon(MingCute.skip_previous_fill,
              color: AppTheme.textPrimary, size: 36),
          onPressed: musicPlayer.skipToPrevious,
        ),
        const _PlayPauseButton(),
        IconButton(
          icon: const Icon(MingCute.skip_forward_fill,
              color: AppTheme.textPrimary, size: 36),
          onPressed: musicPlayer.skipToNext,
        ),
        const _LoopControl(),
      ],
    );
  }
}

class _LoopControl extends StatelessWidget {
  const _LoopControl();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LoopMode>(
      stream: context.read<BloomeePlayerCubit>().bloomeePlayer.loopMode,
      builder: (context, snapshot) {
        final loopMode = snapshot.data ?? LoopMode.off;
        final l10n = AppLocalizations.of(context)!;
        return PopupMenuButton(
          itemBuilder: (_) => [
            PopupMenuItem(value: 0, child: Text(l10n.playerLoopOff)),
            PopupMenuItem(value: 1, child: Text(l10n.playerLoopOne)),
            PopupMenuItem(value: 2, child: Text(l10n.playerLoopAll)),
          ],
          child: Icon(
            loopMode == LoopMode.off
                ? MingCute.repeat_line
                : loopMode == LoopMode.one
                    ? MingCute.repeat_one_line
                    : MingCute.repeat_fill,
            color: loopMode == LoopMode.off
                ? AppTheme.textPrimary
                : AppTheme.accentPink,
            size: 24,
          ),
          onSelected: (value) {
            final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
            if (value == 0) player.setLoopMode(LoopMode.off);
            if (value == 1) player.setLoopMode(LoopMode.one);
            if (value == 2) player.setLoopMode(LoopMode.all);
          },
        );
      },
    );
  }
}

class _ShuffleControl extends StatelessWidget {
  const _ShuffleControl();

  @override
  Widget build(BuildContext context) {
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
    return StreamBuilder<bool>(
      stream: player.shuffleMode,
      builder: (context, snapshot) {
        final isShuffle = snapshot.data ?? false;
        return IconButton(
          icon: Icon(
            MingCute.shuffle_2_fill,
            color: isShuffle
                ? AppTheme.accentPink
                : AppTheme.textPrimary,
            size: 24,
          ),
          onPressed: () => player.shuffle(!isShuffle),
        );
      },
    );
  }
}

class _ExternalLinkControl extends StatelessWidget {
  const _ExternalLinkControl();

  @override
  Widget build(BuildContext context) {
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
    return IconButton(
      icon: const Icon(MingCute.external_link_line,
          color: AppTheme.textSecondary, size: 22),
      onPressed: () async {
        final url = player.currentTrackInfo.url;
        if (url != null) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          SnackbarService.showMessage(
              AppLocalizations.of(context)!.snackbarCouldNotOpenLink);
        }
      },
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton();

  @override
  Widget build(BuildContext context) {
    final musicPlayer = context.read<BloomeePlayerCubit>().bloomeePlayer;
    return BlocBuilder<MiniPlayerCubit, MiniPlayerState>(
      builder: (context, state) {
        Widget child;
        Color buttonColor = AppTheme.accentPink;

        if (state.isLoading || state.isResolving) {
          child = const CircularProgressIndicator(
              strokeWidth: 3, color: AppTheme.textPrimary);
          buttonColor = state.isPlaying
              ? AppTheme.accentPink
              : AppTheme.accentPink.withValues(alpha: 0.6);
        } else if (state.isCompleted) {
          child = const Icon(FontAwesome.rotate_right_solid,
              color: AppTheme.textPrimary, size: 32);
          buttonColor = AppTheme.accentPink;
        } else if (state.hasError) {
          child = const Icon(MingCute.warning_line,
              color: AppTheme.textPrimary, size: 32);
        } else if (state.isVisible) {
          return PlayPauseButton(
            size: 72,
            onPause: musicPlayer.pause,
            onPlay: musicPlayer.play,
            isPlaying: state.isPlaying,
          );
        } else {
          child = const SizedBox();
        }

        return GestureDetector(
          onTap: () {
            if (state.isCompleted) {
              musicPlayer.seek(Duration.zero);
              musicPlayer.play();
            } else if (state.hasError) {
              musicPlayer.play();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.accentGradientHorizontal,
              boxShadow: [
                BoxShadow(
                  color: buttonColor.withValues(alpha: 0.35),
                  spreadRadius: 1,
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Center(child: SizedBox(width: 32, height: 32, child: child)),
          ),
        );
      },
    );
  }
}

class AmbientImgShadowWidget extends StatefulWidget {
  const AmbientImgShadowWidget({super.key});

  @override
  State<AmbientImgShadowWidget> createState() => _AmbientImgShadowWidgetState();
}

class _AmbientImgShadowWidgetState extends State<AmbientImgShadowWidget> {
  Color? _cachedColor;
  String? _lastArtUri;
  StreamSubscription? _mediaSub;
  bool _fetchingPalette = false;

  @override
  void initState() {
    super.initState();
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
    _mediaSub = player.mediaItem.listen((mi) {
      final artUri = mi?.artUri?.toString();
      if (artUri != _lastArtUri) {
        _lastArtUri = artUri;
        _fetchPalette(artUri);
      }
    });
    final current = player.mediaItem.valueOrNull;
    _lastArtUri = current?.artUri?.toString();
    _fetchPalette(_lastArtUri);
  }

  Future<void> _fetchPalette(String? artUri) async {
    if (artUri == null || artUri.isEmpty || _fetchingPalette) return;
    _fetchingPalette = true;
    try {
      final palette = await getPalleteFromImage(artUri);
      if (mounted) {
        setState(() => _cachedColor = palette.dominantColor?.color);
      }
    } catch (_) {
    } finally {
      _fetchingPalette = false;
    }
  }

  @override
  void dispose() {
    _mediaSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  (_cachedColor ?? AppTheme.accentPink).withValues(alpha: 0.22),
                  Colors.transparent,
                ],
                center: Alignment.center,
                radius: 0.8,
              ),
            ),
          ),
          if (_lastArtUri != null)
            AnimatedOpacity(
              opacity: 0.15,
              duration: const Duration(milliseconds: 500),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 45.0, sigmaY: 45.0),
                child: LoadImageCached(
                  imageUrl: _lastArtUri!,
                  fallbackUrl: _lastArtUri!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  Colors.transparent,
                  Colors.black,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UtilityTray extends StatelessWidget {
  const _UtilityTray();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(MingCute.alarm_1_line, color: AppTheme.textSecondary, size: 22),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const TimerView())),
          ),
          IconButton(
            icon: const Icon(MingCute.align_center_line, color: AppTheme.textSecondary, size: 22),
            onPressed: () {
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (_, __, ___) => const FullscreenLyricsView(),
                transitionsBuilder: (_, a, __, c) =>
                    FadeTransition(opacity: a, child: c),
                transitionDuration: const Duration(milliseconds: 300),
              ));
            },
          ),
          IconButton(
            icon: const Icon(MingCute.settings_6_line, color: AppTheme.textSecondary, size: 22),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PlayerSettings())),
          ),
          const _ExternalLinkControl(),
        ],
      ),
    );
  }
}
