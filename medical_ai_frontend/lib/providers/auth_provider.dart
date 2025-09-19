import 'package:flutter/material.dart';

enum UserRole { nurse, doctor, admin }
enum AuthState { initial, loading, authenticated, unauthenticated, twoFactorRequired }
enum AuthMethod { password, sso, twoFactor }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? profileImage;
  final String? hospitalId;
  final String? department;
  final List<String> languages;
  final bool isFirstLogin;
  final bool hasTwoFactorEnabled;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? preferences;
  final bool hasCompletedOnboarding;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
    this.hospitalId,
    this.department,
    this.languages = const ['en'],
    this.isFirstLogin = false,
    this.hasTwoFactorEnabled = false,
    this.lastLoginAt,
    this.preferences,
    this.hasCompletedOnboarding = false,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? profileImage,
    String? hospitalId,
    String? department,
    List<String>? languages,
    bool? isFirstLogin,
    bool? hasTwoFactorEnabled,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
    bool? hasCompletedOnboarding,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      hospitalId: hospitalId ?? this.hospitalId,
      department: department ?? this.department,
      languages: languages ?? this.languages,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      hasTwoFactorEnabled: hasTwoFactorEnabled ?? this.hasTwoFactorEnabled,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString(),
      'profileImage': profileImage,
      'hospitalId': hospitalId,
      'department': department,
      'languages': languages,
      'isFirstLogin': isFirstLogin,
      'hasTwoFactorEnabled': hasTwoFactorEnabled,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'preferences': preferences,
      'hasCompletedOnboarding': hasCompletedOnboarding,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == json['role'],
        orElse: () => UserRole.nurse,
      ),
      profileImage: json['profileImage'],
      hospitalId: json['hospitalId'],
      department: json['department'],
      languages: List<String>.from(json['languages'] ?? ['en']),
      isFirstLogin: json['isFirstLogin'] ?? false,
      hasTwoFactorEnabled: json['hasTwoFactorEnabled'] ?? false,
      lastLoginAt: json['lastLoginAt'] != null 
        ? DateTime.parse(json['lastLoginAt']) 
        : null,
      preferences: json['preferences'],
      hasCompletedOnboarding: json['hasCompletedOnboarding'] ?? false,
    );
  }
}

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  AuthState _authState = AuthState.initial;
  AuthMethod? _lastAuthMethod;
  bool _requiresOnboarding = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthState get authState => _authState;
  AuthMethod? get lastAuthMethod => _lastAuthMethod;
  bool get requiresOnboarding => _requiresOnboarding;

  // Demo users for different roles
  final List<User> _demoUsers = [
    User(
      id: '1',
      name: 'Dr. Sarah Ahmad',
      email: 'sarah.ahmad@hospital.my',
      role: UserRole.doctor,
      hospitalId: 'HKL001',
      department: 'Cardiology',
      languages: ['en', 'ms'],
      isFirstLogin: false,
      hasTwoFactorEnabled: true,
      hasCompletedOnboarding: true,
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    User(
      id: '2',
      name: 'Ahmad bin Ali',
      email: 'ahmad.ali@email.com',
      role: UserRole.nurse,
      languages: ['ms', 'en'],
      isFirstLogin: true,
      hasTwoFactorEnabled: false,
      hasCompletedOnboarding: false,
    ),
    User(
      id: '3',
      name: 'Admin User',
      email: 'admin@hospital.my',
      role: UserRole.admin,
      hospitalId: 'HKL001',
      department: 'Administration',
      languages: ['en', 'ms', 'zh', 'ta'],
      isFirstLogin: false,
      hasTwoFactorEnabled: true,
      hasCompletedOnboarding: true,
      lastLoginAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  // Authentication Methods
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Demo login - find user by email
      final user = _demoUsers.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
        orElse: () => throw Exception('User not found'),
      );

      // For demo purposes, accept any password for valid emails
      if (password.isNotEmpty) {
        _currentUser = user;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        throw Exception('Password is required');
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String name, String email, String password, UserRole role) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Check if email already exists
      final existingUser = _demoUsers.where(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );

      if (existingUser.isNotEmpty) {
        throw Exception('Email already exists');
      }

      // Create new user
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        role: role,
        languages: ['en'],
      );

      _demoUsers.add(newUser);
      _currentUser = newUser;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Check if email exists
      final userExists = _demoUsers.any(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );

      if (!userExists) {
        throw Exception('Email not found');
      }

      // In real app, this would send an email
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile(User updatedUser) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Set current user (for SSO login)
  void setCurrentUser(User user) {
    _currentUser = user;
    _isAuthenticated = true;
    _authState = AuthState.authenticated;
    _lastAuthMethod = AuthMethod.sso;
    _requiresOnboarding = !user.hasCompletedOnboarding;
    _clearError();
    notifyListeners();
  }

  // Check if user requires onboarding
  bool get shouldShowOnboarding => _requiresOnboarding && _currentUser?.isFirstLogin == true;

  // Mark onboarding as completed
  void completeOnboarding() {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        hasCompletedOnboarding: true,
        isFirstLogin: false,
      );
      _requiresOnboarding = false;
      notifyListeners();
    }
  }

  // Check authentication status (e.g., on app start)
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    
    try {
      // Simulate checking stored token/session
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo, we'll keep user logged out on restart
      _isAuthenticated = false;
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get role-specific dashboard route
  String getDashboardRoute() {
    if (!_isAuthenticated || _currentUser == null) {
      return '/login';
    }
    
    switch (_currentUser!.role) {
      case UserRole.nurse:
        return '/nurse/dashboard';
      case UserRole.doctor:
        return '/doctor/dashboard';
      case UserRole.admin:
        return '/admin/dashboard';
    }
  }

  // Get role display name
  String getRoleDisplayName() {
    if (_currentUser == null) return '';
    
    switch (_currentUser!.role) {
      case UserRole.nurse:
        return 'Registered Nurse';
      case UserRole.doctor:
        return 'Healthcare Professional';
      case UserRole.admin:
        return 'Administrator';
    }
  }
}
