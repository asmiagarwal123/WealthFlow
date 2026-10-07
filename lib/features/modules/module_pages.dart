import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/models.dart';
import '../../core/widgets/app_widgets.dart';

class ActionCentrePage extends StatefulWidget {
  const ActionCentrePage({super.key});
  @override
  State<ActionCentrePage> createState() => _ActionCentrePageState();
}

class _ActionCentrePageState extends State<ActionCentrePage> {
  String filter = 'Critical';
  @override
  Widget build(BuildContext context) {
    final repo = AppScope.of(context).repository;
    var actions = repo.actions.where((item) => !item.resolved).toList();
    if (filter == 'Critical')
      actions = actions
          .where((item) => item.severity == DataStatus.critical)
          .toList();
    if (filter == 'Resolved')
      actions = repo.actions.where((item) => item.resolved).toList();
    return Scaffold(
      appBar: Navigator.canPop(context)
          ? AppBar(title: const Text('Advisor Action Centre'))
          : null,
      body: ScreenBody(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (!Navigator.canPop(context))
          Text('Advisor Action Centre',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        const Text('Prioritized exceptions with a suggested human next step.'),
        const SizedBox(height: 14),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: [
              'Critical',
              'Today',
              'Upcoming',
              'Overdue',
              'Resolved'
            ]
                    .map((item) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                            label: Text(item),
                            selected: filter == item,
                            onSelected: (_) => setState(() => filter = item))))
                    .toList())),
        const SizedBox(height: 16),
        if (actions.isEmpty)
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(children: [
                    const Icon(Icons.task_alt,
                        size: 44, color: AppColors.success),
                    const SizedBox(height: 10),
                    Text(filter == 'Resolved'
                        ? 'No resolved actions yet'
                        : 'No actions in this category'),
                    const SizedBox(height: 6),
                    const Text('Try another filter.',
                        style: TextStyle(fontSize: 12))
                  ])))
        else
          ...actions.map((action) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              StatusChip(
                                  action.severity == DataStatus.critical
                                      ? 'Critical'
                                      : 'Attention',
                                  action.severity),
                              const Spacer(),
                              Text(action.due,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700))
                            ]),
                            const SizedBox(height: 10),
                            Text(action.type,
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w900)),
                            Text('${action.client} • Owner ${action.owner}'),
                            const Divider(),
                            Text(action.problem),
                            const SizedBox(height: 7),
                            Text('Impact: ${action.impact}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 7),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.lightbulb_outline, size: 18),
                                  const SizedBox(width: 7),
                                  Expanded(
                                      child: Text(action.nextStep,
                                          style: const TextStyle(fontSize: 12)))
                                ]),
                            const SizedBox(height: 12),
                            if (!action.resolved)
                              Wrap(spacing: 8, children: [
                                FilledButton(
                                    onPressed: () =>
                                        _resolve(context, action.id),
                                    child: const Text('Resolve')),
                                OutlinedButton(
                                    onPressed: () => showMessage(context,
                                        '${action.id} snoozed until tomorrow'),
                                    child: const Text('Snooze')),
                                TextButton(
                                    onPressed: () =>
                                        _dismiss(context, action.id),
                                    child: const Text('Dismiss'))
                              ])
                            else
                              const StatusChip(
                                  'Audit entry recorded', DataStatus.completed),
                          ]))))),
      ])),
    );
  }

  Future<void> _resolve(BuildContext context, String id) async {
    if (await confirmAction(context,
        title: 'Resolve action?',
        message:
            'This changes local mock status and records a demonstration audit event.')) {
      if (!context.mounted) return;
      AppScope.of(context).repository.resolveAction(id);
      setState(() {});
      showMessage(context, '$id resolved');
    }
  }

  void _dismiss(BuildContext context, String id) => showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
              title: const Text('Dismiss with reason'),
              content: const TextField(
                  maxLines: 3,
                  decoration: InputDecoration(labelText: 'Reason required')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      AppScope.of(context).repository.resolveAction(id);
                      Navigator.pop(dialogContext);
                      setState(() {});
                      showMessage(context, 'Dismissed with audit note');
                    },
                    child: const Text('Dismiss'))
              ]));
}

class ModuleHubPage extends StatefulWidget {
  const ModuleHubPage({super.key, required this.initialModule});
  final String initialModule;
  @override
  State<ModuleHubPage> createState() => _ModuleHubPageState();
}

class _ModuleHubPageState extends State<ModuleHubPage> {
  bool loading = false;
  String? state;
  @override
  Widget build(BuildContext context) {
    final content = _content(widget.initialModule);
    return Scaffold(
        appBar: AppBar(title: Text(widget.initialModule)),
        body: RefreshIndicator(
            onRefresh: () async {
              setState(() => loading = true);
              await Future<void>.delayed(const Duration(milliseconds: 500));
              if (mounted) setState(() => loading = false);
            },
            child: ScreenBody(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(content.$1,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(content.$2),
                  const SizedBox(height: 14),
                  const DemoBanner(),
                  const SectionHeader('Overview'),
                  if (loading)
                    ...List.generate(
                        3,
                        (_) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                                height: 88,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(18)))))
                  else
                    ...content.$3.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Card(
                            child: ListTile(
                                leading: CircleAvatar(child: Icon(item.$2)),
                                title: Text(item.$1,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800)),
                                subtitle: Text(item.$3),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _detail(context, item.$1))))),
                  const SectionHeader('Demonstration states'),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    ActionChip(
                        label: const Text('Loading'),
                        onPressed: () async {
                          setState(() => loading = true);
                          await Future<void>.delayed(
                              const Duration(milliseconds: 700));
                          if (mounted) setState(() => loading = false);
                        }),
                    ActionChip(
                        label: const Text('Empty'),
                        onPressed: () => setState(() => state =
                            'No matching records. Adjust the filters and retry.')),
                    ActionChip(
                        label: const Text('Error'),
                        onPressed: () => setState(() => state =
                            'Mock service unavailable. Your data is safe.')),
                    ActionChip(
                        label: const Text('Offline'),
                        onPressed: () => setState(() =>
                            state = 'Offline mode • showing cached demo data.'))
                  ]),
                  if (state != null)
                    Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Card(
                            child: ListTile(
                                leading: const Icon(Icons.info_outline),
                                title: Text(state!),
                                trailing: TextButton(
                                    onPressed: () =>
                                        setState(() => state = null),
                                    child: const Text('Retry'))))),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                      onPressed: () => _simulate(context),
                      icon: const Icon(Icons.bolt),
                      label: Text('Run ${widget.initialModule} demo action')),
                ]))));
  }

  (String, String, List<(String, IconData, String)>) _content(String name) {
    if (name.contains('Reports'))
      return (
        'Reports Centre',
        'Preview and generate business, client and management reports.',
        [
          ('AUM growth report', Icons.trending_up, 'Ready • PDF / XLSX / CSV'),
          (
            'Client portfolio report',
            Icons.person_outline,
            '25 clients • Last generated yesterday'
          ),
          (
            'Brokerage report',
            Icons.currency_rupee,
            'October 2026 • Reconciled'
          ),
          ('RM performance', Icons.groups_outlined, '5 relationship managers')
        ]
      );
    if (name.contains('Family'))
      return (
        'Families & households',
        'Consolidated wealth, goals and permissions across eight households.',
        [
          ('Mehta family', Icons.family_restroom, '₹54.2 L • 3 members'),
          ('Kapoor family', Icons.family_restroom, '₹41.8 L • 2 members'),
          ('Shared goals', Icons.flag_outlined, '7 active • 2 reviews due')
        ]
      );
    if (name.contains('Brokerage'))
      return (
        'Brokerage intelligence',
        'Gross ₹10.4 L • trail ₹8.9 L • clawback ₹0.3 L • net ₹8.46 L.',
        [
          ('AMC-wise', Icons.business_outlined, '8 AMCs • reconciled'),
          ('Client-wise', Icons.people_outline, '1,248 clients'),
          ('Adjustment history', Icons.history, '3 entries this month')
        ]
      );
    if (name.contains('CRM') || name.contains('Lead'))
      return (
        'CRM & leads',
        'Manage a fictional pipeline from first contact to converted client.',
        [
          ('New leads', Icons.person_add_alt, '12 • ₹1.8 Cr estimated'),
          ('Follow-ups', Icons.call_outlined, '8 due today'),
          (
            'Pipeline',
            Icons.filter_alt_outlined,
            'New → Contacted → Qualified → Proposal → Converted'
          )
        ]
      );
    if (name.contains('Setting'))
      return (
        'Settings',
        'Control appearance, notifications, privacy and this demonstration session.',
        [
          ('Theme', Icons.palette_outlined, 'Light / dark'),
          ('Device sessions', Icons.devices_outlined, '2 mock sessions'),
          (
            'Privacy & consent',
            Icons.privacy_tip_outlined,
            'All demo choices recorded'
          ),
          ('About', Icons.info_outline, 'WealthFlow UI prototype')
        ]
      );
    return (
      name,
      'Interactive mobile workspace backed by deterministic local mock data.',
      [
        ('Summary', Icons.analytics_outlined, 'Healthy • updated 09:42 IST'),
        (
          'Attention required',
          Icons.warning_amber,
          '3 items need human review'
        ),
        ('History', Icons.history, 'Complete simulated audit timeline'),
        ('Preferences', Icons.tune, 'Role-aware defaults')
      ]
    );
  }

  void _detail(BuildContext context, String title) =>
      showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (sheetContext) => SafeArea(
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 10),
                        const Text(
                            'This detail uses fictional values, a visible data timestamp and an audit-ready action pattern.'),
                        const SizedBox(height: 14),
                        FilledButton(
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              showMessage(
                                  context, '$title action completed locally');
                            },
                            child: const Text('Complete demo action'))
                      ]))));
  Future<void> _simulate(BuildContext context) async {
    final ok = await confirmAction(context,
        title: 'Run simulated action?',
        message:
            'No external service or real financial system will be contacted.');
    if (ok && context.mounted)
      showMessage(context, '${widget.initialModule} simulation completed');
  }
}
