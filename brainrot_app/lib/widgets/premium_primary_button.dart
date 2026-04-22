import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A premium, fully-rounded button with a press-down scale animation and
/// haptic feedback — matching Apple HIG interaction standards.
///
/// Features:
/// - Stadium (pill) border shape
/// - Scale-down to 0.95 on press, spring back on release
/// - [HapticFeedback.mediumImpact] on tap
/// - Optional leading [icon]
class PremiumPrimaryButton extends StatefulWidget {
  /// Button label text.
  final String label;

  /// Tap callback. If `null`, the button is visually disabled.
  final VoidCallback? onPressed;

  /// Optional leading icon shown before the label.
  final IconData? icon;

  /// Background colour override. Falls back to theme primary.
  final Color? backgroundColor;

  /// Foreground (text/icon) colour override.
  final Color? foregroundColor;

  const PremiumPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<PremiumPrimaryButton> createState() => _PremiumPrimaryButtonState();
}

class _PremiumPrimaryButtonState extends State<PremiumPrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isEnabled => widget.onPressed != null;

  void _handleTapDown(TapDownDetails _) {
    if (!_isEnabled) return;
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    if (!_isEnabled) return;
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!_isEnabled) return;
    _controller.reverse();
  }

  void _handleTap() {
    if (!_isEnabled) return;
    HapticFeedback.mediumImpact();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = widget.backgroundColor ?? theme.colorScheme.primary;
    final fg = widget.foregroundColor ?? theme.colorScheme.onPrimary;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedOpacity(
          opacity: _isEnabled ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(100), // stadium
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: fg, size: 20),
                  const SizedBox(width: 10),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    color: fg,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
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
