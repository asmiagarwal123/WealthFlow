import 'package:flutter/material.dart';

import '../core/mock_repository.dart';

enum UserRole {
  distributor,
  relationshipManager,
  operations,
  administrator,
  client
}

extension UserRoleX on UserRole {
  String get label => switch (this) {
        UserRole.distributor => 'Distributor',
        UserRole.relationshipManager => 'Relationship Manager',
        UserRole.operations => 'Operations',
        UserRole.administrator => 'Administrator',
        UserRole.client => 'Client',
      };

  String get email => switch (this) {
        UserRole.distributor => 'distributor@demo.com',
        UserRole.relationshipManager => 'rm@demo.com',
        UserRole.operations => 'ops@demo.com',
        UserRole.administrator => 'admin@demo.com',
        UserRole.client => 'client@demo.com',
      };
}

enum EntryStage { splash, onboarding, login, authenticated }

class AppController extends ChangeNotifier {
  AppController({MockRepository? repository})
      : repository = repository ?? MockRepository.seeded();

  final MockRepository repository;
  EntryStage stage = EntryStage.splash;
  UserRole selectedRole = UserRole.distributor;
  UserRole? activeRole;
  ThemeMode themeMode = ThemeMode.light;
  int onboardingPage = 0;

  void finishSplash() {
    stage = EntryStage.onboarding;
    notifyListeners();
  }

  void setOnboardingPage(int value) {
    onboardingPage = value;
    notifyListeners();
  }

  void finishOnboarding() {
    stage = EntryStage.login;
    notifyListeners();
  }

  void selectRole(UserRole role) {
    selectedRole = role;
    notifyListeners();
  }

  bool login(String email, String password) {
    if (email.trim().toLowerCase() != selectedRole.email ||
        password != 'demo123') {
      return false;
    }
    activeRole = selectedRole;
    stage = EntryStage.authenticated;
    notifyListeners();
    return true;
  }

  void demoLogin(UserRole role) {
    selectedRole = role;
    activeRole = role;
    stage = EntryStage.authenticated;
    notifyListeners();
  }

  void logout() {
    activeRole = null;
    stage = EntryStage.login;
    notifyListeners();
  }

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void resetDemo() {
    repository.reset();
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope was not found in this context');
    return scope!.notifier!;
  }
}
