import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
});

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthStateNotifier(secureStorage);
});

enum AuthState {
  locked,
  unlocked,
  notSetup,
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final FlutterSecureStorage _secureStorage;
  static const String _pinKey = 'user_pin';
  static const String _biometricEnabledKey = 'biometric_enabled';

  AuthStateNotifier(this._secureStorage) : super(AuthState.notSetup) {
    _checkAuthSetup();
  }

  Future<void> _checkAuthSetup() async {
    final pin = await _secureStorage.read(key: _pinKey);
    if (pin == null) {
      state = AuthState.notSetup;
    } else {
      state = AuthState.locked;
    }
  }

  Future<void> setupPin(String pin) async {
    await _secureStorage.write(key: _pinKey, value: pin);
    state = AuthState.locked;
  }

  Future<bool> verifyPin(String pin) async {
    final storedPin = await _secureStorage.read(key: _pinKey);
    if (storedPin == pin) {
      state = AuthState.unlocked;
      return true;
    }
    return false;
  }

  Future<void> unlock() async {
    state = AuthState.unlocked;
  }

  Future<void> lock() async {
    state = AuthState.locked;
  }

  Future<bool> isPinSetup() async {
    final pin = await _secureStorage.read(key: _pinKey);
    return pin != null;
  }

  Future<void> changePin(String newPin) async {
    await _secureStorage.write(key: _pinKey, value: newPin);
  }

  Future<void> clearAuth() async {
    await _secureStorage.delete(key: _pinKey);
    await _secureStorage.delete(key: _biometricEnabledKey);
    state = AuthState.notSetup;
  }
}

final isPinSetupProvider = FutureProvider<bool>((ref) async {
  final authNotifier = ref.watch(authStateProvider.notifier);
  return await authNotifier.isPinSetup();
});