import 'package:flutter/material.dart';

enum UserRole { patient, doctor, admin }
enum SupportedLanguage { english, malay, mandarin, tamil }

class AppProvider extends ChangeNotifier {
  // App Theme
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Language Settings
  SupportedLanguage _currentLanguage = SupportedLanguage.english;
  SupportedLanguage get currentLanguage => _currentLanguage;

  void changeLanguage(SupportedLanguage language) {
    _currentLanguage = language;
    notifyListeners();
  }

  String getLanguageCode() {
    switch (_currentLanguage) {
      case SupportedLanguage.english:
        return 'en';
      case SupportedLanguage.malay:
        return 'ms';
      case SupportedLanguage.mandarin:
        return 'zh';
      case SupportedLanguage.tamil:
        return 'ta';
    }
  }

  String getLanguageName() {
    switch (_currentLanguage) {
      case SupportedLanguage.english:
        return 'English';
      case SupportedLanguage.malay:
        return 'Bahasa Melayu';
      case SupportedLanguage.mandarin:
        return '中文';
      case SupportedLanguage.tamil:
        return 'தமிழ்';
    }
  }

  // Loading States
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Error Handling
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Navigation
  int _currentPageIndex = 0;
  int get currentPageIndex => _currentPageIndex;

  void setCurrentPageIndex(int index) {
    _currentPageIndex = index;
    notifyListeners();
  }

  // App Configuration
  bool _showOnboarding = true;
  bool get showOnboarding => _showOnboarding;

  void completeOnboarding() {
    _showOnboarding = false;
    notifyListeners();
  }

  // Network Status
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  void setNetworkStatus(bool online) {
    _isOnline = online;
    notifyListeners();
  }
}
