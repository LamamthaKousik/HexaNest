import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app localization
/// Supports English, Hindi, and Telugu languages
class LocalizationService {
  static const String _languageKey = 'app_language';
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('hi', 'IN'), // Hindi
    Locale('te', 'IN'), // Telugu
  ];

  /// Initialize localization
  static Future<void> initialize() async {
    await EasyLocalization.ensureInitialized();
  }

  /// Get current language code
  static Future<String> getCurrentLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_languageKey) ?? 'en';
    } catch (e) {
      print('Error getting current language: $e');
      return 'en';
    }
  }

  /// Set app language
  static Future<bool> setLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      return true;
    } catch (e) {
      print('Error setting language: $e');
      return false;
    }
  }

  /// Get supported languages
  static List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'en', 'name': 'English', 'nativeName': 'English'},
      {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिन्दी'},
      {'code': 'te', 'name': 'Telugu', 'nativeName': 'తెలుగు'},
    ];
  }

  /// Get language name by code
  static String getLanguageName(String code) {
    final languages = getSupportedLanguages();
    final language = languages.firstWhere(
      (lang) => lang['code'] == code,
      orElse: () => {'name': 'English', 'nativeName': 'English'},
    );
    return language['name']!;
  }

  /// Get native language name by code
  static String getNativeLanguageName(String code) {
    final languages = getSupportedLanguages();
    final language = languages.firstWhere(
      (lang) => lang['code'] == code,
      orElse: () => {'name': 'English', 'nativeName': 'English'},
    );
    return language['nativeName']!;
  }
}

/// Provider for localization state
final localizationProvider = StateNotifierProvider<LocalizationNotifier, LocalizationState>((ref) {
  return LocalizationNotifier();
});

/// Localization state model
class LocalizationState {
  final String currentLanguage;
  final bool isLoading;
  final String? error;

  LocalizationState({
    this.currentLanguage = 'en',
    this.isLoading = false,
    this.error,
  });

  LocalizationState copyWith({
    String? currentLanguage,
    bool? isLoading,
    String? error,
  }) {
    return LocalizationState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Localization state notifier
class LocalizationNotifier extends StateNotifier<LocalizationState> {
  LocalizationNotifier() : super(LocalizationState()) {
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    state = state.copyWith(isLoading: true);
    try {
      final currentLang = await LocalizationService.getCurrentLanguage();
      state = state.copyWith(
        currentLanguage: currentLang,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load language: $e',
      );
    }
  }

  Future<bool> changeLanguage(String languageCode, BuildContext context) async {
    state = state.copyWith(isLoading: true);
    try {
      final success = await LocalizationService.setLanguage(languageCode);
      if (success) {
        // Change the app locale
        await context.setLocale(Locale(languageCode));
        
        state = state.copyWith(
          currentLanguage: languageCode,
          isLoading: false,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to change language',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error changing language: $e',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Extension for easy translation access
extension LocalizationExtension on String {
  String tr([List<String>? args, Map<String, String>? namedArgs]) {
    return this.tr(args: args, namedArgs: namedArgs);
  }
}
