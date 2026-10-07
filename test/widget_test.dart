import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/app/app.dart';
import 'package:wealthflow/app/app_state.dart';
import 'package:wealthflow/core/formatters.dart';
import 'package:wealthflow/core/mock_repository.dart';
import 'package:wealthflow/features/imports/import_pages.dart';
import 'package:wealthflow/features/workflows/workflow_pages.dart';

void main() {
  AppController controllerAt(EntryStage stage) {
    final controller = AppController();
    controller.stage = stage;
    return controller;
  }

  Future<void> setSurface(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('app launches on splash and moves to onboarding', (tester) async {
    await tester.pumpWidget(const WealthFlowApp());
    expect(find.text('WealthFlow'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Complete wealth overview'), findsOneWidget);
  });

  testWidgets('onboarding navigates to login', (tester) async {
    final controller = controllerAt(EntryStage.onboarding);
    await tester.pumpWidget(WealthFlowApp(controller: controller));
    await tester.tap(find.text('Skip'));
    await tester.pump();
    expect(find.text('Choose a demo workspace'), findsOneWidget);
  });

  testWidgets('distributor demo login renders dashboard', (tester) async {
    final controller = controllerAt(EntryStage.login);
    await tester.pumpWidget(WealthFlowApp(controller: controller));
    await tester.ensureVisible(find.text('Continue as Distributor'));
    await tester.tap(find.text('Continue as Distributor'));
    await tester.pumpAndSettle();
    expect(find.text('Good morning, Arjun'), findsOneWidget);
    expect(find.text('Total AUM'), findsOneWidget);
  });

  testWidgets('client demo login renders client wealth', (tester) async {
    final controller = controllerAt(EntryStage.login);
    await tester.pumpWidget(WealthFlowApp(controller: controller));
    await tester.ensureVisible(find.text('Continue as Client'));
    await tester.tap(find.text('Continue as Client'));
    await tester.pumpAndSettle();
    expect(find.text('Good morning, Aditi'), findsOneWidget);
    expect(find.text('Current value'), findsWidgets);
  });

  testWidgets('invalid login displays feedback', (tester) async {
    final controller = controllerAt(EntryStage.login);
    await tester.pumpWidget(WealthFlowApp(controller: controller));
    final passwordField = find.byType(TextField).at(1);
    await tester.enterText(passwordField, 'wrong');
    await tester.tap(find.text('Sign in'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('Invalid demo credentials'), findsOneWidget);
  });

  testWidgets('client search filters directory', (tester) async {
    final controller = controllerAt(EntryStage.authenticated)
      ..activeRole = UserRole.distributor;
    await tester.pumpWidget(WealthFlowApp(controller: controller));
    await tester.tap(find.byType(NavigationDestination).at(1));
    await tester.pumpAndSettle();
    expect(find.text('Rahul Mehta'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Meera');
    await tester.pump();
    expect(find.text('Meera Iyer'), findsOneWidget);
    expect(find.text('Rahul Mehta'), findsNothing);
  });

  testWidgets('theme toggle changes theme mode', (tester) async {
    final controller = controllerAt(EntryStage.authenticated)
      ..activeRole = UserRole.client;
    await tester.pumpWidget(WealthFlowApp(controller: controller));
    expect(controller.themeMode, ThemeMode.light);
    await tester.tap(find.byTooltip('Theme'));
    await tester.pump();
    expect(controller.themeMode, ThemeMode.dark);
  });

  testWidgets('narrow distributor dashboard has no exception', (tester) async {
    await setSurface(tester, const Size(320, 720));
    final controller = controllerAt(EntryStage.authenticated)
      ..activeRole = UserRole.distributor;
    await tester.pumpWidget(WealthFlowApp(controller: controller));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('wide operations layout uses navigation rail', (tester) async {
    await setSurface(tester, const Size(1100, 800));
    final controller = controllerAt(EntryStage.authenticated)
      ..activeRole = UserRole.operations;
    await tester.pumpWidget(WealthFlowApp(controller: controller));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('WBR success simulation reaches completion feedback',
      (tester) async {
    final controller = controllerAt(EntryStage.authenticated)
      ..activeRole = UserRole.operations;
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: ImportControlPage()),
      ),
    );
    await tester.ensureVisible(find.text('Simulate arrival'));
    await tester.tap(find.text('Simulate arrival'));
    await tester.pump(const Duration(seconds: 3));
    expect(find.textContaining('WBR imported successfully'), findsOneWidget);
  });

  testWidgets('reconciliation resolution updates local state', (tester) async {
    final controller = controllerAt(EntryStage.authenticated)
      ..activeRole = UserRole.operations;
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: ReconciliationPage()),
      ),
    );
    await tester.ensureVisible(find.text('Resolve').first);
    await tester.tap(find.text('Resolve').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm simulation').last);
    await tester.pumpAndSettle();
    expect(controller.repository.reconciliations.first.resolved, isTrue);
  });

  testWidgets('transaction journey produces mock order timeline',
      (tester) async {
    final controller = controllerAt(EntryStage.authenticated)
      ..activeRole = UserRole.distributor;
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: TransactionWizardPage()),
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Continue'));
      await tester.pump();
    }
    await tester.tap(find.text('Confirm simulation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm simulation').last);
    await tester.pumpAndSettle();
    expect(find.text('Mock order successful'), findsOneWidget);
    expect(find.text('Successful'), findsOneWidget);
  });

  test('Indian currency formatting is correct', () {
    expect(formatInr(1250000), '₹12,50,000');
    expect(formatInr(3240000, compact: true), '₹32.4 L');
    expect(formatInr(-2500), '-₹2,500');
  });

  test('mock repository is coherent and actions update locally', () {
    final repository = MockRepository.seeded();
    expect(repository.clients, hasLength(25));
    expect(repository.schemes, hasLength(30));
    expect(repository.sips, hasLength(40));
    expect(repository.imports, hasLength(14));
    expect(repository.reconciliations, hasLength(12));
    final firstSip = repository.sips.first;
    expect(repository.clients.any((client) => client.id == firstSip.clientId),
        isTrue);
    repository.updateSip(firstSip.id, 'Paused');
    expect(firstSip.status, 'Paused');
  });
}
