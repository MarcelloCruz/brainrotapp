import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../widgets/premium_primary_button.dart';
import '../providers/app_state.dart';

/// The Apple-inspired Wallet screen.
/// Includes an available balance, quick top-up options, and recent activity.
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // ── Balance Header ──
              Text(
                'Available Balance',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${state.walletBalance.toStringAsFixed(2)}',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 56,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 48),

              // ── Top-Up Section ──
              Text(
                'Add Funds',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TopUpPill(amount: 5, isDark: isDark),
                  const SizedBox(width: 12),
                  _TopUpPill(amount: 10, isDark: isDark),
                  const SizedBox(width: 12),
                  _TopUpPill(amount: 20, isDark: isDark),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PremiumPrimaryButton(
                  label: 'Deposit via Apple/Google Pay',
                  icon: CupertinoIcons.money_dollar_circle_fill,
                  onPressed: () {
                    // TODO: integrate with payment gateway
                  },
                ),
              ),
              const SizedBox(height: 48),

              // ── Recent Activity ──
              Text(
                'Recent Activity',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              ...state.recentActivity.map(
                (t) => _TransactionItem(
                  amount:
                      '${t.isPositive ? '+' : '-'}\$${t.amount.toStringAsFixed(2)}',
                  isPositive: t.isPositive,
                  title: t.title,
                  subtitle: t.subtitle,
                  date: t.date,
                  isDark: isDark,
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopUpPill extends StatelessWidget {
  final int amount;
  final bool isDark;

  const _TopUpPill({required this.amount, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          context.read<AppState>().addFunds(amount.toDouble());
        },
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: Text(
              '\$$amount',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String amount;
  final bool isPositive;
  final String title;
  final String subtitle;
  final String date;
  final bool isDark;

  const _TransactionItem({
    required this.amount,
    required this.isPositive,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPositive
                      ? CupertinoIcons.arrow_down_right
                      : CupertinoIcons.arrow_up_right,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isPositive
                          ? CupertinoColors.activeGreen
                          : CupertinoColors.destructiveRed,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 64),
          child: Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }
}
