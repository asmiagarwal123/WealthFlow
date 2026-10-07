import 'package:flutter/material.dart';

import '../../core/widgets/app_widgets.dart';

void showAssistant(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) =>
        const FractionallySizedBox(heightFactor: .82, child: _AssistantSheet()),
  );
}

class _AssistantSheet extends StatefulWidget {
  const _AssistantSheet();
  @override
  State<_AssistantSheet> createState() => _AssistantSheetState();
}

class _AssistantSheetState extends State<_AssistantSheet> {
  String? question;
  bool loading = false;
  static const questions = [
    'Show clients with failed SIPs above ₹10,000',
    'Why did Rahul’s portfolio change today?',
    'Summarize today’s reconciliation failures',
    'Which portfolios have high small-cap concentration?',
    'Draft a polite failed-SIP message',
    'Show goals that are off track',
  ];

  Future<void> ask(String value) async {
    setState(() {
      question = value;
      loading = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (mounted) setState(() => loading = false);
  }

  String response() {
    final value = question ?? '';
    if (value.contains('Rahul'))
      return 'Rahul’s portfolio increased by ₹18,420. Mock NAV movement added ₹22,460 while net withdrawals reduced value by ₹4,040.';
    if (value.contains('reconciliation'))
      return 'There are 3 critical and 9 warning cases. Unit mismatch is the largest category; CAMS import IMP-5003 contributes 4 affected records.';
    if (value.contains('message'))
      return 'Hello, your scheduled SIP could not be processed. Please review the mandate or contact us for help. No action has been taken automatically.';
    if (value.contains('goals'))
      return 'Child education and home purchase are off track in the mock dataset. Both need a human review of monthly contributions.';
    if (value.contains('small-cap'))
      return 'Three fictional portfolios exceed the 20% small-cap review threshold: Rahul Mehta, Priya Nair and Kunal Sethi.';
    return 'Neha Kapoor and Vikram Malhotra have failed SIPs above ₹10,000. Both are assigned to Ananya for human follow-up.';
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                CircleAvatar(child: const Icon(Icons.auto_awesome)),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('WealthFlow Assistant',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900)),
                      const Text('DEMO AI • deterministic local responses',
                          style: TextStyle(fontSize: 10))
                    ]))
              ]),
              const SizedBox(height: 14),
              Expanded(
                child: ListView(
                  children: [
                    const Text('Try a question',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 9),
                    ...questions.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: OutlinedButton(
                            onPressed: () => ask(item),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(item))))),
                    if (question != null) ...[
                      const SizedBox(height: 12),
                      Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  borderRadius: BorderRadius.circular(16)),
                              child: Text(question!))),
                      const SizedBox(height: 10),
                      Card(
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: loading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                          const Text('DEMO AI RESPONSE',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900)),
                                          const SizedBox(height: 8),
                                          Text(response()),
                                          const Divider(),
                                          const Text(
                                              'Data timestamp: 07 Oct 2026, 09:42 IST\nSources: mock clients, SIPs, portfolios and reconciliation repository\nHuman review required • No autonomous transaction placement',
                                              style: TextStyle(fontSize: 10))
                                        ]))),
                    ],
                  ],
                ),
              ),
              const DemoBanner(),
            ],
          ),
        ),
      );
}
