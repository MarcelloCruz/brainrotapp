import 'package:flutter/material.dart';
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
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? [] : AppTheme.subtleShadow,
      ),
      child: Row(
        children: [
          // ── Time Saved ──
          Expanded(
            child: _StatColumn(
              label: 'Daily Allowance Used',
              value: '${state.timeUsedMins}m / ${state.dailyAllowanceMins}m',
              theme: theme,
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
              value: '\$${state.totalTaxPaid.toStringAsFixed(2)}',
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

  const _StatColumn({
    required this.label,
    required this.value,
    required this.theme,
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
      ],
    );
  }
}
