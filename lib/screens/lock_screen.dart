import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  final VoidCallback onUnlocked;

  const LockScreen({super.key, required this.onUnlocked});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final List<String> _pin = [];
  final int _pinLength = 4;
  bool _isSettingPin = false;
  String? _firstPin;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_hospital,
                size: 64,
                color: Colors.pink,
              ),
              const SizedBox(height: 16),
              Text(
                _isSettingPin || authState == AuthState.notSetup
                    ? 'Créer votre code PIN'
                    : 'Entrer votre code PIN',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pinLength,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _pin.length
                          ? Colors.pink
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 48),
              _buildKeypad(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['1', '2', '3'].map((n) => _buildKey(n)).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['4', '5', '6'].map((n) => _buildKey(n)).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['7', '8', '9'].map((n) => _buildKey(n)).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 72),
            _buildKey('0'),
            _buildKey('⌫', isBackspace: true),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String key, {bool isBackspace = false}) {
    return SizedBox(
      width: 72,
      height: 72,
      child: ElevatedButton(
        onPressed: () => _onKeyPressed(key, isBackspace: isBackspace),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.grey.shade100,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        child: Text(
          key,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  void _onKeyPressed(String key, {bool isBackspace = false}) async {
    setState(() {
      _errorMessage = null;
    });

    if (isBackspace) {
      if (_pin.isNotEmpty) {
        setState(() {
          _pin.removeLast();
        });
      }
      return;
    }

    if (_pin.length < _pinLength) {
      setState(() {
        _pin.add(key);
      });
    }

    if (_pin.length == _pinLength) {
      final enteredPin = _pin.join();
      final authNotifier = ref.read(authStateProvider.notifier);
      final authState = ref.read(authStateProvider);

      if (_isSettingPin || authState == AuthState.notSetup) {
        if (_firstPin == null) {
          setState(() {
            _firstPin = enteredPin;
            _pin.clear();
          });
        } else {
          if (_firstPin == enteredPin) {
            await authNotifier.setupPin(enteredPin);
            widget.onUnlocked();
          } else {
            setState(() {
              _errorMessage = 'Les codes ne correspondent pas';
              _firstPin = null;
              _pin.clear();
            });
          }
        }
      } else {
        final isValid = await authNotifier.verifyPin(enteredPin);
        if (isValid) {
          widget.onUnlocked();
        } else {
          setState(() {
            _errorMessage = 'Code PIN incorrect';
            _pin.clear();
          });
        }
      }
    }
  }
}