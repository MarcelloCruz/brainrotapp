import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

/// Hidden "God Mode" Dev Panel.
///
/// Features a dark, premium hacker-console aesthetic with neon accents.
/// Allows developers to quickly manipulate time and funds for testing.
class DevPanel extends StatefulWidget {
  const DevPanel({super.key});

  /// Displays the Dev Panel as a modal bottom sheet.
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const DevPanel(),
    );
  }

  @override
  State<DevPanel> createState() => _DevPanelState();
}

class _DevPanelState extends State<DevPanel> {
  double _sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize slider with current time
    _sliderValue = context.read<AppState>().timeUsedMins.toDouble().clamp(0.0, 120.0);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            left: 24,
            right: 24,
            top: 24,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D16).withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: Colors.greenAccent.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(
                    Icons.terminal,
                    color: Colors.greenAccent,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'GOD MODE',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Manual Time Set ──
              Text(
                'TIME MANIPULATION',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: Colors.greenAccent,
                        inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                        thumbColor: Colors.greenAccent,
                        overlayColor: Colors.greenAccent.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: _sliderValue.clamp(0.0, 120.0),
                        min: 0,
                        max: 120,
                        divisions: 120,
                        label: '${_sliderValue.toInt()}m',
                        onChanged: (val) {
                          setState(() => _sliderValue = val);
                        },
                        onChangeEnd: (val) {
                          state.setDebugTimeUsed(val.toInt());
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(
                      '${_sliderValue.toInt()}m',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Reset Wallet ──
              Text(
                'DATABASE INJECTION',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _HackerButton(
                      label: 'SET \$0.00',
                      icon: CupertinoIcons.money_dollar,
                      onPressed: () => state.setWalletBalance(0.0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _HackerButton(
                      label: 'SET \$10.00',
                      icon: CupertinoIcons.money_dollar_circle_fill,
                      onPressed: () => state.setWalletBalance(10.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Payment Status Toggle ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PAYMENT STATUS',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    state.isTaxPaid ? 'PAID / UNLIMITED' : 'PENDING / LOCKED',
                    style: TextStyle(
                      color: state.isTaxPaid ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _HackerButton(
                  label: 'TOGGLE PAID STATE',
                  icon: CupertinoIcons.arrow_2_squarepath,
                  color: Colors.blueAccent,
                  onPressed: () => state.toggleDebugPaidState(),
                ),
              ),
              const SizedBox(height: 24),

              // ── Trigger Block ──
              Text(
                'UI OVERRIDE',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _HackerButton(
                  label: 'FORCE TRIGGER OVERLAY',
                  icon: CupertinoIcons.exclamationmark_triangle_fill,
                  color: Colors.redAccent,
                  onPressed: () {
                    Navigator.pop(context); // Close Dev Panel
                    Navigator.pushNamed(context, '/block'); // Push overlay
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HackerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const _HackerButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color = Colors.greenAccent,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
