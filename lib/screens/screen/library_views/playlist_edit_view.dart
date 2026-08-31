// Page for editing and reordering playlist items.
import 'dart:ui';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/current_playlist_cubit.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/utils/load_image.dart';

class PlaylistEditView extends StatefulWidget {
	const PlaylistEditView({super.key});

	@override
	State<PlaylistEditView> createState() => _PlaylistEditViewState();
}

class _PlaylistEditViewState extends State<PlaylistEditView> {
	// Working copy of the track list. Updated by the child on every drag.
	List<Track> _localTracks = [];
	// Seeded once from the cubit state on first loaded data.
	bool _initialized = false;

	void _onTracksReordered(List<Track> newOrder) {
		setState(() => _localTracks = newOrder);
	}

	List<Color> _getOptimizedPalette(BuildContext context) {
		final pallete =
				context.read<CurrentPlaylistCubit>().getCurrentPlaylistPallete();
		Color fgColor = pallete?.lightVibrantColor?.color ?? Colors.white;
		Color bgColor = pallete?.dominantColor?.color ??
				pallete?.darkMutedColor?.color ??
				Default_Theme.themeColor;

		if (bgColor.computeLuminance() / fgColor.computeLuminance() > 0.05) {
			fgColor = HSLColor.fromColor(fgColor)
					.withLightness(
							(HSLColor.fromColor(fgColor).lightness + 0.1).clamp(0.0, 1.0))
					.toColor();
			bgColor = HSLColor.fromColor(bgColor)
					.withLightness(
							(HSLColor.fromColor(bgColor).lightness - 0.1).clamp(0.0, 1.0))
					.toColor();
		}
		return [fgColor, bgColor];
	}

	Widget _buildAmbientBackground(String imageUrl, Color dominantColor) {
		return Positioned.fill(
			child: Stack(
				fit: StackFit.expand,
				children: [
					Container(color: Default_Theme.themeColor),
					AnimatedContainer(
						duration: const Duration(milliseconds: 600),
						decoration: BoxDecoration(
							gradient: RadialGradient(
								center: Alignment.topRight,
								radius: 1.4,
								colors: [
									dominantColor.withValues(alpha: 0.32),
									Default_Theme.themeColor,
								],
							),
						),
					),
					if (imageUrl.isNotEmpty)
						Positioned.fill(
							child: Opacity(
								opacity: 0.28,
								child: ImageFiltered(
									imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
									child: LoadImageCached(imageUrl: imageUrl, fit: BoxFit.cover),
								),
							),
						),
					Container(
						decoration: BoxDecoration(
							gradient: LinearGradient(
								begin: Alignment.topCenter,
								end: Alignment.bottomCenter,
								colors: [
									Colors.black.withValues(alpha: 0.25),
									Default_Theme.themeColor.withValues(alpha: 0.8),
									Default_Theme.themeColor,
								],
								stops: const [0.0, 0.5, 1.0],
							),
						),
					),
				],
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return BlocBuilder<CurrentPlaylistCubit, CurrentPlaylistState>(
			builder: (context, state) {
				// Seed local list once from cubit state.
				if (!_initialized && state.playlist.tracks.isNotEmpty) {
					_localTracks = List<Track>.from(state.playlist.tracks);
					_initialized = true;
				}

				final bool isLoading = !_initialized &&
						(state is CurrentPlaylistInitial ||
								state is CurrentPlaylistLoading);

				if (isLoading) {
					return const Scaffold(
						backgroundColor: Default_Theme.themeColor,
						body: Center(child: CircularProgressIndicator()),
					);
				}

				final colors = _getOptimizedPalette(context);
				final bgColor = colors[1];
				final imageUrl = _localTracks.isNotEmpty
						? (_localTracks.first.thumbnail.urlHigh ?? _localTracks.first.thumbnail.url)
						: '';

				return Scaffold(
					backgroundColor: Colors.transparent,
					extendBodyBehindAppBar: true,
					body: Stack(
						fit: StackFit.expand,
						children: [
							_buildAmbientBackground(imageUrl, bgColor),
							SafeArea(
								child: CustomScrollView(
									slivers: [
										SliverAppBar(
											floating: true,
											centerTitle: true,
											elevation: 0,
											scrolledUnderElevation: 0,
											backgroundColor: Colors.transparent,
											leading: Padding(
												padding: const EdgeInsets.only(left: 12.0),
												child: Center(
													child: IconButton(
														icon: Container(
															padding: const EdgeInsets.all(8),
															decoration: BoxDecoration(
																color: Colors.white.withValues(alpha: 0.05),
																shape: BoxShape.circle,
																border: Border.all(
																		color: Colors.white.withValues(alpha: 0.1)),
															),
															child: const Icon(Icons.arrow_back_rounded,
																	color: Colors.white, size: 18),
														),
														onPressed: () => Navigator.of(context).pop(),
													),
												),
											),
											title: const Text(
												'Edit Playlist',
												style: TextStyle(
													fontFamily: 'Gilroy',
													fontSize: 18,
													fontWeight: FontWeight.bold,
													color: Colors.white,
												),
											),
											actions: [
												Padding(
													padding: const EdgeInsets.only(right: 16),
													child: Center(
														child: IconButton(
															onPressed: () async {
																final playlistCubit =
																		context.read<CurrentPlaylistCubit>();
																final navigator = Navigator.of(context);
																if (_localTracks.isNotEmpty) {
																	try {
																		await playlistCubit.updatePlaylist(_localTracks);
																		if (!mounted) return;
																		SnackbarService.showMessage('Playlist Updated!');
																	} catch (_) {
																		if (!mounted) return;
																		SnackbarService.showMessage(
																			'Unable to save playlist order. Please try again.',
																		);
																		return;
																	}
																}
																if (!mounted) return;
																navigator.pop();
															},
															icon: Container(
																padding: const EdgeInsets.all(8),
																decoration: BoxDecoration(
																	color: Default_Theme.accentColor2
																			.withValues(alpha: 0.15),
																	shape: BoxShape.circle,
																	border: Border.all(
																			color: Default_Theme.accentColor2
																					.withValues(alpha: 0.35)),
																),
																child: const Icon(
																	MingCute.check_fill,
																	color: Default_Theme.accentColor2,
																	size: 18,
																),
															),
														),
													),
												),
											],
										),
										// Glassy Info Panel
										SliverToBoxAdapter(
											child: Padding(
												padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
												child: ClipRRect(
													borderRadius: BorderRadius.circular(16),
													child: BackdropFilter(
														filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
														child: Container(
															padding: const EdgeInsets.symmetric(
																	horizontal: 16, vertical: 12),
															decoration: BoxDecoration(
																color: Colors.white.withValues(alpha: 0.035),
																borderRadius: BorderRadius.circular(16),
																border: Border.all(
																	color: Default_Theme.accentColor2.withValues(alpha: 0.15),
																),
															),
															child: Row(
																children: [
																	Container(
																		width: 32,
																		height: 32,
																		decoration: BoxDecoration(
																			color: Default_Theme.accentColor2
																					.withValues(alpha: 0.12),
																			borderRadius: BorderRadius.circular(10),
																		),
																		child: const Icon(
																			Icons.drag_indicator_rounded,
																			size: 18,
																			color: Default_Theme.accentColor2,
																		),
																	),
																	const SizedBox(width: 12),
																	Expanded(
																		child: Column(
																			crossAxisAlignment: CrossAxisAlignment.start,
																			children: [
																				Text(
																					'Edit & Reorder Playlist',
																					style: TextStyle(
																						fontFamily: 'Gilroy',
																						fontSize: 14,
																						fontWeight: FontWeight.bold,
																						color: Colors.white.withValues(alpha: 0.9),
																					),
																				),
																				const SizedBox(height: 2),
																				Text(
																					'Drag handles to reorder. Swipe left on tiles to remove.',
																					style: TextStyle(
																						fontFamily: 'Gilroy',
																						fontSize: 11,
																						fontWeight: FontWeight.w500,
																						color: Colors.white.withValues(alpha: 0.5),
																					),
																				),
																			],
																		),
																	),
																],
															),
														),
													),
												),
											),
										),
										// Reorderable list
										SliverPlaylistItems(
											initialTracks: _localTracks,
											onTracksReordered: _onTracksReordered,
										),
										SliverToBoxAdapter(
											child: SizedBox(
													height: MediaQuery.of(context).padding.bottom + 24),
										),
									],
								),
							),
						],
					),
				);
			},
		);
	}
}

/// Internal stateful list widget that manages the drag order locally
/// and reports the new order to the parent via [onTracksReordered].
class SliverPlaylistItems extends StatefulWidget {
	const SliverPlaylistItems({
		super.key,
		required this.initialTracks,
		this.onTracksReordered,
	});

	final List<Track> initialTracks;
	final ValueChanged<List<Track>>? onTracksReordered;

	@override
	State<SliverPlaylistItems> createState() => _SliverPlaylistItemsState();
}

class _SliverPlaylistItemsState extends State<SliverPlaylistItems> {
	late List<Track> _tracks;

	@override
	void initState() {
		super.initState();
		_tracks = List<Track>.from(widget.initialTracks);
	}

	@override
	void didUpdateWidget(SliverPlaylistItems oldWidget) {
		super.didUpdateWidget(oldWidget);
		// Re-sync when the parent's list length changes (external add/remove).
		if (widget.initialTracks.length != _tracks.length) {
			setState(() => _tracks = List<Track>.from(widget.initialTracks));
		}
	}

	@override
	Widget build(BuildContext context) {
		return SliverPadding(
			padding: const EdgeInsets.symmetric(horizontal: 12),
			sliver: SliverReorderableList(
				itemCount: _tracks.length,
				itemExtent: 78,
				proxyDecorator: _proxyDecorator,
				onReorder: (oldIndex, newIndex) {
					setState(() {
						if (oldIndex < newIndex) newIndex -= 1;
						final Track item = _tracks.removeAt(oldIndex);
						_tracks.insert(newIndex, item);
					});
					widget.onTracksReordered?.call(List<Track>.from(_tracks));
				},
				itemBuilder: (context, index) {
					final track = _tracks[index];
					return KeyedSubtree(
						key: ValueKey(track.id),
						child: Dismissible(
							key: ValueKey(track.id + '_dismiss'),
							direction: DismissDirection.endToStart,
							background: Container(
								alignment: Alignment.centerRight,
								padding: const EdgeInsets.only(right: 24.0),
								margin: const EdgeInsets.symmetric(vertical: 4),
								decoration: BoxDecoration(
									color: Colors.redAccent.withValues(alpha: 0.15),
									borderRadius: BorderRadius.circular(14),
									border: Border.all(
											color: Colors.redAccent.withValues(alpha: 0.25), width: 1),
								),
								child: const Icon(MingCute.delete_2_line,
										color: Colors.redAccent, size: 22),
							),
							onDismissed: (direction) {
								setState(() {
									_tracks.removeAt(index);
								});
								widget.onTracksReordered?.call(List<Track>.from(_tracks));
								SnackbarService.showMessage('Track removed from playlist edit list');
							},
							child: Stack(
								children: [
									IgnorePointer(
										ignoring: true,
										child: Container(
											margin: const EdgeInsets.symmetric(vertical: 4),
											decoration: BoxDecoration(
												color: Colors.white.withValues(alpha: 0.02),
												borderRadius: BorderRadius.circular(14),
												border: Border.all(
														color: Colors.white.withValues(alpha: 0.04)),
											),
											child: SongCardWidget(
												song: track,
												showOptions: false,
												trailing: const SizedBox(width: 50),
											),
										),
									),
									Positioned(
										right: 12,
										top: 0,
										bottom: 0,
										child: Center(
											child: ReorderableDragStartListener(
												index: index,
												child: Container(
													width: 34,
													height: 34,
													decoration: BoxDecoration(
														color: Default_Theme.accentColor2
																.withValues(alpha: 0.12),
														borderRadius: BorderRadius.circular(10),
														border: Border.all(
															color: Default_Theme.accentColor2
																	.withValues(alpha: 0.25),
														),
													),
													child: const Icon(
														Icons.drag_handle_rounded,
														color: Default_Theme.accentColor2,
														size: 18,
													),
												),
											),
										),
									),
								],
							),
						),
					);
				},
			),
		);
	}
}

Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
	return AnimatedBuilder(
		animation: animation,
		builder: (BuildContext context, Widget? child) {
			final double animValue = Curves.easeInOut.transform(animation.value);
			final double scale = lerpDouble(1.0, 1.04, animValue)!;
			return Transform.scale(
				scale: scale,
				child: Material(
					color: Default_Theme.themeColor.withValues(alpha: 0.85),
					elevation: 0,
					borderRadius: BorderRadius.circular(14),
					child: Container(
						decoration: BoxDecoration(
							borderRadius: BorderRadius.circular(14),
							border: Border.all(
								color: Default_Theme.accentColor2.withValues(alpha: 0.45),
								width: 1.5,
							),
							boxShadow: [
								BoxShadow(
									color: Default_Theme.accentColor2.withValues(alpha: 0.35),
									blurRadius: 20,
									spreadRadius: 1,
								),
							],
						),
						child: child,
					),
				),
			);
		},
		child: child,
	);
}
