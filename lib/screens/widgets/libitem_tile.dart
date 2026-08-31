import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

enum LibItemTypes {
  userPlaylist,
  onlPlaylist,
  artist,
  album,
}

class LibItemCard extends StatelessWidget {
  final String title;
  final String coverArt;
  final String subtitle;
  final LibItemTypes type;
  final VoidCallback? onTap;
  final VoidCallback? onSecondaryTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onMenuTap;
  final bool showMenuButton;
  final bool isPinned;
  const LibItemCard({
    super.key,
    required this.title,
    required this.coverArt,
    required this.subtitle,
    this.type = LibItemTypes.userPlaylist,
    this.onTap,
    this.onSecondaryTap,
    this.onLongPress,
    this.onMenuTap,
    this.showMenuButton = false,
    this.isPinned = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMD,
        vertical: AppTheme.spacingXS,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: AppTheme.borderRadiusMD,
          border: Border.all(
            color: AppTheme.surfaceBorder.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: AppTheme.textSecondary.withValues(alpha: 0.08),
            hoverColor: AppTheme.surfaceLight,
            highlightColor: AppTheme.textSecondary.withValues(alpha: 0.08),
            borderRadius: AppTheme.borderRadiusMD,
            onTap: onTap ?? () {},
            onSecondaryTap: onSecondaryTap ?? () {},
            onLongPress: onLongPress ?? () {},
            child: Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  type == LibItemTypes.userPlaylist
                      ? StreamBuilder<String>(
                          stream: context
                              .watch<BloomeePlayerCubit>()
                              .bloomeePlayer
                              .queueTitle,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data == title) {
                              return const Padding(
                                padding: EdgeInsets.only(left: AppTheme.spacingXS),
                                child: Icon(
                                  FontAwesome.chart_simple_solid,
                                  color: AppTheme.accentPink,
                                  size: 15,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          })
                      : const SizedBox.shrink(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSM),
                    child: SizedBox.square(
                      dimension: 60,
                      child: ClipRRect(
                        borderRadius: type == LibItemTypes.artist
                            ? BorderRadius.circular(30)
                            : AppTheme.borderRadiusSM,
                        child: LoadImageCached(
                          imageUrl: coverArt,
                          fallbackUrl: coverArt,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: AppTheme.labelMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (isPinned) ...[
                              const Icon(
                                MingCute.pin_2_fill,
                                size: 12,
                                color: AppTheme.accentPink,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (showMenuButton)
                    Padding(
                      padding: const EdgeInsets.only(right: AppTheme.spacingXS),
                      child: IconButton(
                        onPressed: onMenuTap,
                        splashRadius: 20,
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          size: 20,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
