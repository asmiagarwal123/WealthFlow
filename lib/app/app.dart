import 'dart:async';

import 'package:flutter/material.dart';

import '../features/auth/auth_pages.dart';
import '../features/shell/app_shell.dart';
import 'app_state.dart';
import 'constants.dart';
import 'theme.dart';

class WealthFlowApp extends StatefulWidget {
  const WealthFlowApp({super.key, this.controller});

  final AppController? controller;

  @override
  State<WealthFlowApp> createState() => _WealthFlowAppState();
}

class _WealthFlowAppState extends State<WealthFlowApp> {
  late final AppController controller = widget.controller ?? AppController();
  Timer? splashTimer;

  @override
  void initState() {
    super.initState();
    if (controller.stage == EntryStage.splash) {
      splashTimer =
          Timer(const Duration(milliseconds: 900), controller.finishSplash);
    }
  }

  @override
  void dispose() {
    splashTimer?.cancel();
    if (widget.controller == null) controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => MaterialApp(
          title: appName,
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: controller.themeMode,
          home: switch (controller.stage) {
            EntryStage.splash => const SplashPage(),
            EntryStage.onboarding => const OnboardingPage(),
            EntryStage.login => const LoginPage(),
            EntryStage.authenticated => const AppShell(),
          },
          onUnknownRoute: (_) => MaterialPageRoute<void>(
            builder: (_) => const NotFoundPage(),
          ),
        ),
      ),
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.explore_off_outlined, size: 58),
              const SizedBox(height: 16),
              Text('Page not found',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      );
}
