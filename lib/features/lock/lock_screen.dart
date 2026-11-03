import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../data/services/biometric_service.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const LockScreen({super.key, required this.onUnlocked});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _triggerAuth();
  }

  Future<void> _triggerAuth() async {
    setState(() => _isAuthenticating = true);
    final success = await BiometricService.instance.authenticate();
    if (mounted) {
      setState(() => _isAuthenticating = false);
      if (success) {
        widget.onUnlocked();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2C),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.lock_shield_fill,
                    size: 48,
                    color: Color(0xFFE2C999),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'HandCraft Collectibles',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your private collection is protected',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isAuthenticating ? null : _triggerAuth,
                    icon: const Icon(CupertinoIcons.lock_open),
                    label: Text(
                      _isAuthenticating ? 'Authenticating...' : 'Unlock Vault',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE2C999),
                      foregroundColor: const Color(0xFF0F1B2C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
