import 'dart:ui';

import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/plugins/blocs/import/content_import_cubit.dart';
import 'package:Bloomee/plugins/blocs/import/content_import_state.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/screens/screen/library_views/more_opts_sheet.dart';
import 'package:Bloomee/screens/screen/common_views/album_view.dart';
import 'package:Bloomee/screens/screen/common_views/artist_view.dart';
import 'package:Bloomee/screens/screen/common_views/playlist_view.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/plugins/utils/media_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/core/constants/route_paths.dart';
import 'package:Bloomee/screens/widgets/create_playlist_bottomsheet.dart';
import 'package:Bloomee/screens/widgets/libitem_tile.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/blocs/library/search_cubit/library_search_cubit.dart';
import 'package:Bloomee/core/models/library_search_result.dart';
import 'package:Bloomee/screens/widgets/animated_list_item.dart';
import 'package:Bloomee/screens/screen/home_views/recents_view.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LibrarySearchCubit(
        searchTracks: context.read<LibraryItemsCubit>().searchTracks,
      ),
      child: const _LibraryScreenView(),
    );
  }
}

class _LibraryScreenView extends StatefulWidget {
  const _LibraryScreenView();

  @override
  State<_LibraryScreenView> createState() => _LibraryScreenViewState();
}

class _LibraryScreenViewState extends State<_LibraryScreenView> {
  final ValueNotifier<String> _searchQuery = ValueNotifier('');
  final ValueNotifier<String> _selectedFilter = ValueNotifier('All');
  bool _isSearching = false;
  bool _isReordering = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchQuery.dispose();
    _selectedFilter.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _searchQuery.value = query;

    final itemsState = context.read<LibraryItemsCubit>().state;
    context.read<LibrarySearchCubit>().search(query, itemsState);
  }

  void _openSearch() {
    setState(() {
      _isSearching = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  void _closeSearch() {
    _searchController.clear();
    _searchQuery.value = '';
    context.read<LibrarySearchCubit>().clearSearch();
    setState(() {
      _isSearching = false;
    });
  }

  void _dismissKeyboard() {
    _searchFocusNode.unfocus();
  }

  void _openLikedSongs() {
    context.pushNamed(RoutePaths.playlistView, extra: 'Liked');
  }

  List<PlaylistItemProperties> _getFilteredPlaylists(
      List<PlaylistItemProperties> original, String filter) {
    if (filter == 'All') return original;
    if (filter == 'Playlists') {
      return original
          .where((p) =>
              p.type == PlaylistType.userPlaylist ||
              p.type == PlaylistType.remotePlaylist)
          .toList();
    }
    if (filter == 'Albums') {
      return original.where((p) => p.type == PlaylistType.album).toList();
    }
    if (filter == 'Artists') {
      return original.where((p) => p.type == PlaylistType.artist).toList();
    }
    return original;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
          builder: (context, itemsState) {
            if (itemsState is LibraryItemsLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.accentPink,
                ),
              );
            }

            if (itemsState is LibraryItemsError) {
              return Center(
                child: SignBoardWidget(
                  message: itemsState.message,
                  icon: Icons.error_outline_rounded,
                ),
              );
            }

            return BlocBuilder<LibrarySearchCubit, LibrarySearchState>(
              builder: (context, searchState) {
                final isSearching = searchState is LibrarySearchSuccess;
                final isLoading = searchState is LibrarySearchLoading;

                final rawPlaylists = isSearching
                    ? searchState.filteredPlaylists
                    : itemsState.playlists;
                final filteredSongs = isSearching
                    ? searchState.songResults
                    : <SongSearchResult>[];

                return ValueListenableBuilder<String>(
                  valueListenable: _selectedFilter,
                  builder: (context, filterValue, _) {
                    final filteredPlaylists =
                        _getFilteredPlaylists(rawPlaylists, filterValue);

                    final hasResults =
                        filteredPlaylists.isNotEmpty || filteredSongs.isNotEmpty;

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        customDiscoverBar(context),
                        
                        // Search Bar
                        if (_isSearching)
                          SliverToBoxAdapter(
                            child: FadeSlideStagger(
                              index: 0,
                              child: _buildSearchBar(),
                            ),
                          ),

                        // Loading Indicators
                        if (isLoading)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 4, bottom: 8),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.accentPink,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Shortcuts Grid
                        if (!_isSearching)
                          SliverToBoxAdapter(
                            child: FadeSlideStagger(
                              index: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: AppTheme.spacingSM,
                                  bottom: AppTheme.spacingMD,
                                ),
                                child: SizedBox(
                                  height: 100,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSM),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSM),
                                        child: _LibraryShortcutCard(
                                          label: 'Liked Songs',
                                          icon: MingCute.heart_fill,
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFEC4899), Color(0xFFEF4444)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          onTap: _openLikedSongs,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSM),
                                        child: _LibraryShortcutCard(
                                          label: 'Downloads',
                                          icon: MingCute.download_2_fill,
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          onTap: () {
                                            context.pushNamed(RoutePaths.offlineScreen);
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSM),
                                        child: _LibraryShortcutCard(
                                          label: 'History',
                                          icon: MingCute.time_fill,
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => const HistoryView(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Filter Chips Row
                        if (!_isSearching && itemsState.playlists.isNotEmpty)
                          SliverToBoxAdapter(
                            child: FadeSlideStagger(
                              index: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppTheme.spacingSM,
                                ),
                                child: SizedBox(
                                  height: 38,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLG),
                                    children: [
                                      _buildFilterChip('All', filterValue),
                                      const SizedBox(width: 8),
                                      _buildFilterChip('Playlists', filterValue),
                                      const SizedBox(width: 8),
                                      _buildFilterChip('Albums', filterValue),
                                      const SizedBox(width: 8),
                                      _buildFilterChip('Artists', filterValue),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Empty Search results
                        if (_isSearching && !hasResults && !isLoading)
                          SliverFillRemaining(
                            child: Center(
                              child: SignBoardWidget(
                                message:
                                    AppLocalizations.of(context)!.emptyNoResults,
                                icon: MingCute.search_line,
                              ),
                            ),
                          ),

                        // Empty library state
                        if (itemsState.playlists.isEmpty)
                          SliverFillRemaining(
                            child: Center(
                              child: SignBoardWidget(
                                message:
                                    AppLocalizations.of(context)!.libraryEmptyState,
                                icon: MingCute.playlist_fill,
                              ),
                            ),
                          ),

                        // Results
                        if (hasResults) ...[
                          if (filteredSongs.isNotEmpty)
                            _buildSongSearchResults(context, filteredSongs),
                          if (filteredPlaylists.isNotEmpty) ...[
                            if (_isReordering && !isSearching)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.035),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppTheme.accentPink
                                            .withValues(alpha: 0.22),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: AppTheme.accentPink
                                                .withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.drag_indicator_rounded,
                                            color: AppTheme.accentPink,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .importReorderTip,
                                            style: AppTheme.bodySmall,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              setState(() => _isReordering = false),
                                          style: TextButton.styleFrom(
                                            foregroundColor: AppTheme.accentPink,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            minimumSize: Size.zero,
                                            tapTargetSize:
                                                MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .importDone,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            _ListOfPlaylists(
                              playlists: filteredPlaylists,
                              isReorderable: _isReordering && !isSearching,
                              onEnterReorder: isSearching
                                  ? null
                                  : () => setState(() => _isReordering = true),
                            ),
                          ],
                        ],
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String currentSelected) {
    final isSelected = currentSelected == label;
    return GestureDetector(
      onTap: () {
        _selectedFilter.value = label;
      },
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        curve: AppTheme.curveDefault,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.accentGradientHorizontal : null,
          color: isSelected ? null : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppTheme.surfaceBorder.withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: AppTheme.surfaceBorder.withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          autofocus: false,
          textInputAction: TextInputAction.search,
          style: AppTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.searchHintLibrary,
            hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
            prefixIcon: const Icon(
              MingCute.search_line,
              color: AppTheme.textTertiary,
              size: 20,
            ),
            suffixIcon: ValueListenableBuilder<String>(
              valueListenable: _searchQuery,
              builder: (context, query, _) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: query.isEmpty
                      ? const SizedBox.shrink(key: ValueKey('empty'))
                      : IconButton(
                          key: const ValueKey('clear'),
                          icon: const Icon(
                            MingCute.close_fill,
                            color: AppTheme.textSecondary,
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        ),
                );
              },
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildSongSearchResults(
      BuildContext context, List<SongSearchResult> songs) {
    return SliverList.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final result = songs[index];
        return AnimatedListItem(
          key: ValueKey('song_${result.song.id}_${result.playlistName}'),
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(left: 4, right: 0),
            child: SongCardWidget(
              song: result.song,
              showOptions: true,
              subtitleOverride:
                  AppLocalizations.of(context)!.libraryIn(result.playlistName),
              onTap: () async {
                _dismissKeyboard();
                final playlist = await context
                    .read<LibraryItemsCubit>()
                    .getPlaylistByName(result.playlistName);
                if (playlist != null && context.mounted) {
                  final songIdx =
                      playlist.tracks.indexWhere((s) => s.id == result.song.id);
                  context.read<BloomeePlayerCubit>().bloomeePlayer.loadPlaylist(
                        playlist,
                        idx: songIdx >= 0 ? songIdx : 0,
                        doPlay: true,
                      );
                }
              },
              onOptionsTap: () {
                showMoreBottomSheet(context, result.song);
              },
            ),
          ),
        );
      },
    );
  }

  SliverAppBar customDiscoverBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: false,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      title: Row(
        children: [
          Text(
            AppLocalizations.of(context)!.libraryTitle,
            style: AppTheme.headingLarge.copyWith(
              fontFamily: 'Unageo',
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            padding: const EdgeInsets.all(8),
            onPressed: () {
              if (_isSearching) {
                _closeSearch();
              } else {
                _openSearch();
              }
            },
            icon: Icon(
              _isSearching ? MingCute.close_fill : MingCute.search_line,
              size: 24,
              color: _isSearching
                  ? AppTheme.accentPink
                  : AppTheme.textPrimary,
            ),
          ),
          IconButton(
            padding: const EdgeInsets.all(8),
            onPressed: () => createPlaylistDialog(context),
            icon: const Icon(MingCute.add_fill,
                size: 25, color: AppTheme.textPrimary),
          ),
          IconButton(
            padding: const EdgeInsets.all(8),
            onPressed: () {
              final importPhase =
                  context.read<ContentImportCubit>().state.phase;
              final isOngoing = importPhase != ImportPhase.idle &&
                  importPhase != ImportPhase.done &&
                  importPhase != ImportPhase.error;
              if (isOngoing) {
                final pluginId =
                    context.read<ContentImportCubit>().state.pluginId ?? '';
                context.pushNamed(RoutePaths.importProcess,
                    queryParameters: {'pluginId': pluginId});
              } else {
                context.pushNamed(RoutePaths.importMediaFromPlatforms);
              }
            },
            icon: const Icon(FontAwesome.file_import_solid,
                size: 22, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _ListOfPlaylists extends StatelessWidget {
  final List<PlaylistItemProperties> playlists;
  final bool isReorderable;
  final VoidCallback? onEnterReorder;
  const _ListOfPlaylists({
    required this.playlists,
    this.isReorderable = false,
    this.onEnterReorder,
  });

  static LibItemTypes _toCardType(PlaylistType type) {
    switch (type) {
      case PlaylistType.artist:
        return LibItemTypes.artist;
      case PlaylistType.album:
        return LibItemTypes.album;
      case PlaylistType.remotePlaylist:
        return LibItemTypes.onlPlaylist;
      case PlaylistType.userPlaylist:
        return LibItemTypes.userPlaylist;
    }
  }

  static Future<void> _openLibraryItem(
      BuildContext context, PlaylistItemProperties item) async {
    if (item.type == PlaylistType.userPlaylist) {
      context.pushNamed(
        RoutePaths.playlistView,
        extra: item.storageKey,
      );
      return;
    }

    final playlist = await context
        .read<LibraryItemsCubit>()
        .resolveLibraryItem(item.storageKey);
    if (!context.mounted || playlist == null) return;

    switch (playlist.type) {
      case PlaylistType.artist:
        if (playlist.artists == null || playlist.artists!.isEmpty) return;
        final artist = playlist.artists!.first;
        final pluginId = pluginIdOf(artist.id);
        if (pluginId == null || pluginId.isEmpty) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArtistView(artist: artist, pluginId: pluginId),
          ),
        );
        return;
      case PlaylistType.album:
        if (playlist.album == null) return;
        final album = playlist.album!;
        final pluginId = pluginIdOf(album.id);
        if (pluginId == null || pluginId.isEmpty) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AlbumView(album: album, pluginId: pluginId),
          ),
        );
        return;
      case PlaylistType.remotePlaylist:
        if (playlist.remotePlaylist == null) return;
        final remote = playlist.remotePlaylist!;
        final pluginId = pluginIdOf(remote.id);
        if (pluginId == null || pluginId.isEmpty) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OnlPlaylistView(playlist: remote, pluginId: pluginId),
          ),
        );
        return;
      case PlaylistType.userPlaylist:
        return;
    }
  }

  Widget _buildTile(BuildContext context, PlaylistItemProperties playlist) {
    void openMenu() {
      showPlaylistOptsExtSheet(
        context,
        playlist.playlistName,
        playlistId: playlist.playlistId,
        isPinned: playlist.isPinned,
      );
    }

    return LibItemCard(
      onTap: isReorderable ? null : () => _openLibraryItem(context, playlist),
      onSecondaryTap: isReorderable ? null : openMenu,
      onLongPress: isReorderable
          ? null
          : () => onEnterReorder != null ? onEnterReorder!() : openMenu,
      onMenuTap: isReorderable ? null : openMenu,
      showMenuButton: !isReorderable,
      title: playlist.playlistName,
      coverArt: playlist.coverImgUrl ?? '',
      subtitle: playlist.subTitle ?? '',
      type: _toCardType(playlist.type),
      isPinned: playlist.isPinned,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isReorderable) {
      return SliverList.builder(
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          return FadeSlideStagger(
            index: index,
            child: _buildTile(context, playlists[index]),
          );
        },
      );
    }

    return SliverReorderableList(
      itemBuilder: (context, index) {
        return KeyedSubtree(
          key: ValueKey(playlists[index].playlistId),
          child: Stack(
            children: [
              IgnorePointer(
                ignoring: true,
                child: _buildTile(context, playlists[index]),
              ),
              Positioned(
                right: 14,
                top: 0,
                bottom: 0,
                child: Center(
                  child: ReorderableDragStartListener(
                    index: index,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color:
                            AppTheme.accentPink.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.accentPink
                              .withValues(alpha: 0.20),
                        ),
                      ),
                      child: const Icon(
                        Icons.drag_handle_rounded,
                        color: AppTheme.accentPink,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      itemExtent: 80,
      itemCount: playlists.length,
      proxyDecorator: _proxyDecorator,
      onReorder: (oldIndex, newIndex) {
        context.read<LibraryItemsCubit>().reorderLibrary(oldIndex, newIndex);
      },
    );
  }
}

Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
  return AnimatedBuilder(
    animation: animation,
    builder: (BuildContext context, Widget? child) {
      final double animValue = Curves.easeInOut.transform(animation.value);
      final double elevation = lerpDouble(0, 6, animValue)!;
      return Material(
        elevation: elevation,
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        shadowColor: AppTheme.accentPink.withValues(alpha: 0.25),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.accentPink.withValues(alpha: 0.20),
            ),
          ),
          child: child,
        ),
      );
    },
    child: child,
  );
}

class _LibraryShortcutCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _LibraryShortcutCard({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_LibraryShortcutCard> createState() => _LibraryShortcutCardState();
}

class _LibraryShortcutCardState extends State<_LibraryShortcutCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: AppTheme.durationFast,
          curve: AppTheme.curveDefault,
          child: Container(
            width: 140,
            height: 100,
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: AppTheme.borderRadiusLG,
              boxShadow: [
                BoxShadow(
                  color: widget.gradient.colors.first.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  widget.icon,
                  color: Colors.white,
                  size: AppTheme.iconSizeLG,
                ),
                Text(
                  widget.label,
                  style: AppTheme.labelMedium.copyWith(
                    color: Colors.white,
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
