// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:icons_plus/icons_plus.dart';

class PlayPauseButton extends StatefulWidget {
  final double size;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final bool isPlaying;
  const PlayPauseButton({
    super.key,
    this.size = 60,
    this.onPlay,
    this.onPause,
    this.isPlaying = false,
  });
  @override
  State<PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _colorController;
  late Animation<Color?> _colorAnimation;
  late Animation<Color?> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _setupAnimations();

    // Set initial state
    if (widget.isPlaying) {
      _colorController.value = 1.0;
    }
  }

  void _setupAnimations() {
    _colorAnimation = ColorTween(
      begin: const Color(0xFFFF2D78),
      end: const Color(0xFFFF6B35),
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = ColorTween(
      begin: const Color(0xFFFF2D78).withValues(alpha: 0.65),
      end: const Color(0xFFFF6B35).withValues(alpha: 0.65),
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(covariant PlayPauseButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _colorController.forward();
      } else {
        _colorController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _colorController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    HapticFeedback.lightImpact();
    if (widget.isPlaying) {
      widget.onPause?.call();
    } else {
      widget.onPlay?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return GestureDetector(
      onTap: _togglePlayPause,
      child: AnimatedBuilder(
        animation: _colorController,
        builder: (context, child) {
          final primaryColor = _colorAnimation.value ?? const Color(0xFFFF2D78);
          final glowColor = _glowAnimation.value ?? const Color(0xFFFF2D78);

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor == const Color(0xFFFF2D78)
                      ? const Color(0xFFFF5252)
                      : const Color(0xFFFF8A65),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: glowColor,
                  spreadRadius: 1,
                  blurRadius: 18,
                  offset: const Offset(0, 3),
                )
              ],
              shape: BoxShape.circle,
            ),
            width: size,
            height: size,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: Tween<double>(begin: 0.5, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: widget.isPlaying
                    ? Icon(
                        FontAwesome.pause_solid,
                        key: const ValueKey('pause'),
                        size: size * 0.48,
                        color: Colors.white,
                      )
                    : Icon(
                        MingCute.play_fill,
                        key: const ValueKey('play'),
                        size: size * 0.48,
                        color: Colors.white,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
