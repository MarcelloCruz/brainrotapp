import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';

/// A premium dashboard card displaying key stats in a clean row layout.
///
/// Designed with Apple-like soft corners, zero Material elevation,
/// and optional Cupertino-style subtle shadow.
class DashboardCard extends StatelessWidget {
  const DashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // ── Time Saved ──
          Expanded(
            child: _StatColumn(
              label: 'Daily Allowance Used',
              value: '${state.timeUsedMins}m / ${state.dailyAllowanceMins}m',
              theme: theme,
              bottomWidget: _ProgressBar(
                used: state.timeUsedMins,
                total: state.dailyAllowanceMins,
              ),
            ),
          ),
          // ── Divider ──
          Container(
            width: 0.5,
            height: 44,
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.08),
          ),
          // ── Tax Paid ──
          Expanded(
            child: _StatColumn(
              label: 'Tax Paid',
              value: state.formatPrice(state.totalTaxPaid),
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final Widget? bottomWidget;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.theme,
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
        if (bottomWidget != null) ...[
          const SizedBox(height: 8),
          bottomWidget!,
        ],
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int used;
  final int total;

  const _ProgressBar({required this.used, required this.total});

  @override
  Widget build(BuildContext context) {
    final double progress = (total > 0) ? (used / total).clamp(0.0, 1.0) : 0.0;
    Color color;
    if (progress < 0.5) {
      color = CupertinoColors.activeGreen;
    } else if (progress < 1.0) {
      color = CupertinoColors.systemYellow;
    } else {
      color = CupertinoColors.destructiveRed;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF39FF14)),
        minHeight: 8,
      ),
    );
  }
}
