import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../widgets/premium_primary_button.dart';
import '../providers/app_state.dart';
import '../services/stripe_service.dart';

/// The Apple-inspired Wallet screen.
/// Includes an available balance, selectable top-up amounts, and recent activity.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _selectedIndex = 0;
  bool _isDepositing = false;

  /// Handles the full Stripe deposit flow:
  /// 1. Converts the selected amount to cents.
  /// 2. Calls the Edge Function with the amount.
  /// 3. Presents the Stripe PaymentSheet.
  /// 4. On success, credits the wallet via AppState.topUpWallet().
  Future<void> _handleDeposit() async {
    if (_isDepositing) return;
    setState(() => _isDepositing = true);

    final state = context.read<AppState>();
    final amounts = [state.taxAmount * 10, state.taxAmount * 20, state.taxAmount * 40];
    final selectedAmount = amounts[_selectedIndex];
    final amountInCents = (selectedAmount * 100).round();

    try {
      final success = await StripeService.presentPaymentSheet(
        amountInCents: amountInCents,
      );

      if (!mounted) return;

      if (success) {
        await state.topUpWallet(selectedAmount);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully deposited ${state.formatPrice(selectedAmount)}',
            ),
            backgroundColor: CupertinoColors.activeGreen,
          ),
        );
      }
      // If !success, user cancelled — silently dismiss.
    } catch (e) {
      debugPrint('WalletScreen: Deposit error — $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deposit failed. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDepositing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final isDark = theme.brightness == Brightness.dark;
    final amounts = [state.taxAmount * 10, state.taxAmount * 20, state.taxAmount * 40];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                state.formatPrice(state.walletBalance),
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
                children: List.generate(amounts.length, (index) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 6,
                        right: index == amounts.length - 1 ? 0 : 6,
                      ),
                      child: _TopUpPill(
                        amount: amounts[index],
                        currencySymbol: state.currencySymbol,
                        isDark: isDark,
                        isSelected: _selectedIndex == index,
                        onTap: () => setState(() => _selectedIndex = index),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: _isDepositing
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                          ),
                        ),
                      )
                    : PremiumPrimaryButton(
                        label: 'Deposit ${state.formatPrice(amounts[_selectedIndex])}',
                        icon: CupertinoIcons.money_dollar_circle_fill,
                        onPressed: _handleDeposit,
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
                      '${t.isPositive ? '+' : '-'}${state.formatPrice(t.amount)}',
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
  final double amount;
  final String currencySymbol;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;

  const _TopUpPill({
    required this.amount,
    required this.currencySymbol,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFF1D4ED8);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.2)
              : isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? accentColor.withValues(alpha: 0.6)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            '$currencySymbol${amount % 1 == 0 ? amount.toInt() : amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? accentColor
                  : isDark
                      ? Colors.white
                      : Colors.black,
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
