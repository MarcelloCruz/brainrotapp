import 'package:flutter/material.dart';
import 'overlay_screen.dart';
import 'wallet_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dopamine Tax Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your Wallet: \$5.00',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // For demo purposes, we manually show the overlay
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OverlayScreen(),
                  ),
                );
              },
              child: const Text('Simulate App Block (TikTok)'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WalletScreen()),
          );
        },
        child: const Icon(Icons.wallet),
      ),
    );
  }
}
