import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service for managing PIN-based secure login
/// Uses flutter_secure_storage for encrypted PIN storage
class SecureLoginService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _pinKey = 'user_pin';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _isPracticeModeKey = 'practice_mode';

  /// Set the user PIN
  static Future<bool> setPin(String pin) async {
    try {
      if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
        return false; // Invalid PIN format
      }
      
      await _storage.write(key: _pinKey, value: pin);
      return true;
    } catch (e) {
      print('Error setting PIN: $e');
      return false;
    }
  }

  /// Verify the user PIN
  static Future<bool> verifyPin(String pin) async {
    try {
      final storedPin = await _storage.read(key: _pinKey);
      return storedPin == pin;
    } catch (e) {
      print('Error verifying PIN: $e');
      return false;
    }
  }

  /// Check if PIN is set
  static Future<bool> isPinSet() async {
    try {
      final pin = await _storage.read(key: _pinKey);
      return pin != null && pin.isNotEmpty;
    } catch (e) {
      print('Error checking PIN: $e');
      return false;
    }
  }

  /// Change the PIN
  static Future<bool> changePin(String oldPin, String newPin) async {
    try {
      // Verify old PIN first
      final isValid = await verifyPin(oldPin);
      if (!isValid) return false;

      // Set new PIN
      return await setPin(newPin);
    } catch (e) {
      print('Error changing PIN: $e');
      return false;
    }
  }

  /// Set login status
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    try {
      await _storage.write(key: _isLoggedInKey, value: isLoggedIn.toString());
    } catch (e) {
      print('Error setting login status: $e');
    }
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final status = await _storage.read(key: _isLoggedInKey);
      return status == 'true';
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  /// Set practice mode
  static Future<void> setPracticeMode(bool isPracticeMode) async {
    try {
      await _storage.write(key: _isPracticeModeKey, value: isPracticeMode.toString());
    } catch (e) {
      print('Error setting practice mode: $e');
    }
  }

  /// Check if practice mode is enabled
  static Future<bool> isPracticeMode() async {
    try {
      final status = await _storage.read(key: _isPracticeModeKey);
      return status == 'true';
    } catch (e) {
      print('Error checking practice mode: $e');
      return false;
    }
  }

  /// Clear all stored data (logout)
  static Future<void> clearAllData() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print('Error clearing secure storage: $e');
    }
  }

  /// Reset PIN (for first-time setup)
  static Future<void> resetPin() async {
    try {
      await _storage.delete(key: _pinKey);
    } catch (e) {
      print('Error resetting PIN: $e');
    }
  }
}

/// Provider for login state
final loginStateProvider = StateNotifierProvider<LoginStateNotifier, LoginState>((ref) {
  return LoginStateNotifier();
});

/// Login state model
class LoginState {
  final bool isLoggedIn;
  final bool isPinSet;
  final bool isPracticeMode;
  final String? error;

  LoginState({
    this.isLoggedIn = false,
    this.isPinSet = false,
    this.isPracticeMode = false,
    this.error,
  });

  LoginState copyWith({
    bool? isLoggedIn,
    bool? isPinSet,
    bool? isPracticeMode,
    String? error,
  }) {
    return LoginState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isPinSet: isPinSet ?? this.isPinSet,
      isPracticeMode: isPracticeMode ?? this.isPracticeMode,
      error: error,
    );
  }
}

/// Login state notifier
class LoginStateNotifier extends StateNotifier<LoginState> {
  LoginStateNotifier() : super(LoginState()) {
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    final isPinSet = await SecureLoginService.isPinSet();
    final isLoggedIn = await SecureLoginService.isLoggedIn();
    final isPracticeMode = await SecureLoginService.isPracticeMode();

    state = state.copyWith(
      isPinSet: isPinSet,
      isLoggedIn: isLoggedIn,
      isPracticeMode: isPracticeMode,
    );
  }

  Future<bool> login(String pin) async {
    try {
      final isValid = await SecureLoginService.verifyPin(pin);
      if (isValid) {
        await SecureLoginService.setLoggedIn(true);
        state = state.copyWith(
          isLoggedIn: true,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(error: 'Invalid PIN');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Login failed: $e');
      return false;
    }
  }

  Future<bool> setPin(String pin) async {
    try {
      final success = await SecureLoginService.setPin(pin);
      if (success) {
        state = state.copyWith(
          isPinSet: true,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(error: 'Invalid PIN format');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to set PIN: $e');
      return false;
    }
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    try {
      final success = await SecureLoginService.changePin(oldPin, newPin);
      if (success) {
        state = state.copyWith(error: null);
        return true;
      } else {
        state = state.copyWith(error: 'Failed to change PIN');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Error changing PIN: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await SecureLoginService.setLoggedIn(false);
    state = state.copyWith(isLoggedIn: false);
  }

  Future<void> togglePracticeMode() async {
    final newMode = !state.isPracticeMode;
    await SecureLoginService.setPracticeMode(newMode);
    state = state.copyWith(isPracticeMode: newMode);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
