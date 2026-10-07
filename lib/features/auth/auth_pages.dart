import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../app/constants.dart';
import '../../core/widgets/app_widgets.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF242252), Color(0xFF4F46C8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
          ),
          child: const SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_graph_rounded, color: Colors.white, size: 72),
                SizedBox(height: 18),
                Text(appName,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w900)),
                SizedBox(height: 8),
                Text('Wealth operations, flowing intelligently',
                    style: TextStyle(color: Color(0xFFD7D5F4))),
                SizedBox(height: 42),
                SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5)),
              ],
            ),
          ),
        ),
      );
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController pageController;
  static const pages = [
    (
      Icons.donut_large,
      'Complete wealth overview',
      'See AUM, cash flows, SIPs, goals and exceptions in one coherent view.'
    ),
    (
      Icons.sync_rounded,
      'Automated portfolio data',
      'Follow CAMS and KFintech mailbacks from receipt through reconciliation and valuation.'
    ),
    (
      Icons.flag_outlined,
      'Goals and SIPs, connected',
      'Track progress, contribution gaps and review actions with clear timestamps.'
    ),
    (
      Icons.handshake_outlined,
      'Secure collaboration',
      'Give teams and clients role-appropriate experiences backed by an auditable demo workflow.'
    ),
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: controller.finishOnboarding,
                  child: const Text('Skip')),
            ),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: pages.length,
                onPageChanged: controller.setOnboardingPage,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              shape: BoxShape.circle),
                          child: Icon(page.$1,
                              size: 72,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(height: 38),
                        Text(page.$2,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 16),
                        Text(page.$3,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(height: 1.5)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        pages.length,
                        (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.all(4),
                              height: 8,
                              width:
                                  controller.onboardingPage == index ? 24 : 8,
                              decoration: BoxDecoration(
                                  color: controller.onboardingPage == index
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .outlineVariant,
                                  borderRadius: BorderRadius.circular(8)),
                            )),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (controller.onboardingPage > 0)
                        TextButton(
                            onPressed: () => pageController.previousPage(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut),
                            child: const Text('Back')),
                      const Spacer(),
                      FilledButton(
                        onPressed: () {
                          if (controller.onboardingPage == pages.length - 1)
                            controller.finishOnboarding();
                          else
                            pageController.nextPage(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut);
                        },
                        child: Text(
                            controller.onboardingPage == pages.length - 1
                                ? 'Get started'
                                : 'Next'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController(text: UserRole.distributor.email);
  final password = TextEditingController(text: demoPassword);
  bool obscure = true;
  bool remember = true;
  bool loading = false;
  String? error;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    setState(() {
      loading = true;
      error = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    final ok = AppScope.of(context).login(email.text, password.text);
    if (!ok)
      setState(() {
        loading = false;
        error =
            'Invalid demo credentials. Use the selected role account and demo123.';
      });
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.auto_graph_rounded,
                      color: Color(0xFF4F46C8), size: 48),
                  const SizedBox(height: 12),
                  Text(appName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  const Text('Choose a demo workspace',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: UserRole.values
                        .map((role) => ChoiceChip(
                              label: Text(role.label),
                              selected: controller.selectedRole == role,
                              onSelected: (_) {
                                controller.selectRole(role);
                                email.text = role.email;
                                setState(() => error = null);
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.mail_outline))),
                  const SizedBox(height: 12),
                  TextField(
                      controller: password,
                      obscureText: obscure,
                      onSubmitted: (_) => signIn(),
                      decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => obscure = !obscure),
                              icon: Icon(obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined)))),
                  Row(
                    children: [
                      Checkbox(
                          value: remember,
                          onChanged: (value) =>
                              setState(() => remember = value ?? false)),
                      const Text('Remember me'),
                      const Spacer(),
                      TextButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (_) => const RecoveryPage())),
                          child: const Text('Forgot password?')),
                    ],
                  ),
                  if (error != null)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(error!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error))),
                  FilledButton.icon(
                      onPressed: loading ? null : signIn,
                      icon: loading
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.login),
                      label: Text(loading ? 'Signing in…' : 'Sign in')),
                  const SizedBox(height: 18),
                  const Text('One-tap demo login',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  ...UserRole.values.map((role) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: OutlinedButton(
                            onPressed: () => controller.demoLogin(role),
                            child: Text('Continue as ${role.label}')),
                      )),
                  const SizedBox(height: 12),
                  const DemoBanner(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RecoveryPage extends StatefulWidget {
  const RecoveryPage({super.key});
  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  int step = 0;
  final otp = TextEditingController();
  @override
  void dispose() {
    otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password recovery')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      step == 2
                          ? Icons.verified_outlined
                          : Icons.password_outlined,
                      size: 54,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      step == 0
                          ? 'Find your demo account'
                          : step == 1
                              ? 'Enter six-digit OTP'
                              : 'Password reset complete',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      step == 0
                          ? 'No message is sent. This flow is entirely simulated.'
                          : step == 1
                              ? 'Use mock OTP 123456. You can resend in 00:30.'
                              : 'Your demo password remains demo123.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 22),
                    if (step == 0)
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'Email or mobile',
                          prefixIcon: Icon(Icons.person_search_outlined),
                        ),
                      ),
                    if (step == 1)
                      TextField(
                        controller: otp,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Mock OTP'),
                      ),
                    if (step < 2)
                      FilledButton(
                        onPressed: () {
                          if (step == 1 && otp.text != '123456') {
                            showMessage(
                                context, 'Incorrect mock OTP. Use 123456.');
                            return;
                          }
                          setState(() => step++);
                        },
                        child: Text(
                            step == 0 ? 'Send mock OTP' : 'Verify and reset'),
                      ),
                    if (step == 2)
                      FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Return to sign in'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
