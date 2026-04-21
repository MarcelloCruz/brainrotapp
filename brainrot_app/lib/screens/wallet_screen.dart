import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Up Wallet')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              const Text(
                'Current Balance: \$5.00',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              const Text(
                'Select Top-Up Amount:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _TopUpButton(amount: 5),
                  _TopUpButton(amount: 10),
                  _TopUpButton(amount: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopUpButton extends StatelessWidget {
  final int amount;

  const _TopUpButton({required this.amount});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully topped up \$$amount! (Mocked)')),
        );
      },
      child: Text('\$$amount', style: const TextStyle(fontSize: 18)),
    );
  }
}
