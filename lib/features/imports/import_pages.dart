import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/models.dart';
import '../../core/widgets/app_widgets.dart';

class ImportControlPage extends StatefulWidget {
  const ImportControlPage({super.key});
  @override
  State<ImportControlPage> createState() => _ImportControlPageState();
}

class _ImportControlPageState extends State<ImportControlPage> {
  static const stages = [
    'Email detected',
    'Downloaded',
    'Decrypted',
    'Parsed',
    'Validated',
    'Reconciled',
    'Ledger updated',
    'Holdings updated',
    'NAV applied',
    'Portfolio valued'
  ];
  int current = 9;
  bool running = false;
  String scenario = 'Success';

  Future<void> simulate() async {
    setState(() {
      current = 0;
      running = true;
    });
    for (var i = 1; i < stages.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 260));
      if (!mounted) return;
      if (scenario == 'Failure' && i == 4) {
        setState(() {
          current = i;
          running = false;
        });
        showMessage(context, 'Validation failed • mock file quarantined');
        return;
      }
      setState(() => current = i);
    }
    setState(() => running = false);
    showMessage(
        context,
        scenario == 'Warning'
            ? 'Import applied with 3 mapping warnings • dashboard refreshed'
            : 'WBR imported successfully • dashboard refreshed');
  }

  @override
  Widget build(BuildContext context) {
    final imports = AppScope.of(context).repository.imports;
    return Scaffold(
      appBar: Navigator.canPop(context)
          ? AppBar(title: const Text('Import Control Centre'))
          : null,
      body: ScreenBody(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (!Navigator.canPop(context))
          Text('Import Control Centre',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        const Text(
            'Complete simulated lineage from mail arrival to portfolio valuation.'),
        const SizedBox(height: 14),
        const DemoBanner(),
        const SectionHeader('Configured feeds'),
        SizedBox(
            height: 176,
            child: ListView(scrollDirection: Axis.horizontal, children: const [
              _FeedCard(
                  name: 'CAMS mailback',
                  status: 'Healthy',
                  detail: '4,820 accepted • 0 rejected',
                  dataStatus: DataStatus.healthy),
              SizedBox(width: 12),
              _FeedCard(
                  name: 'KFintech mailback',
                  status: 'Warning',
                  detail: '3,904 accepted • 3 mappings',
                  dataStatus: DataStatus.warning),
              SizedBox(width: 12),
              _FeedCard(
                  name: 'NAV feed',
                  status: 'Fresh',
                  detail: '12,604 schemes • 09:37 IST',
                  dataStatus: DataStatus.healthy),
              SizedBox(width: 12),
              _FeedCard(
                  name: 'Brokerage',
                  status: 'Expected',
                  detail: 'Next delivery • 18:00 IST',
                  dataStatus: DataStatus.pending),
            ])),
        const SectionHeader('Simulated WBR pipeline'),
        Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Expanded(
                            child: Text('CAMS • WBR_20261007.zip',
                                style: TextStyle(fontWeight: FontWeight.w800))),
                        StatusChip(
                            running ? 'Processing' : scenario,
                            running
                                ? DataStatus.pending
                                : scenario == 'Failure'
                                    ? DataStatus.critical
                                    : scenario == 'Warning'
                                        ? DataStatus.warning
                                        : DataStatus.completed)
                      ]),
                      const SizedBox(height: 14),
                      ...stages.asMap().entries.map((entry) {
                        final done = entry.key <= current;
                        final failed = scenario == 'Failure' &&
                            !running &&
                            entry.key == current;
                        return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(children: [
                                CircleAvatar(
                                    radius: 14,
                                    backgroundColor: failed
                                        ? AppColors.error
                                        : done
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                    child: Icon(
                                        failed
                                            ? Icons.close
                                            : done
                                                ? Icons.check
                                                : Icons.circle_outlined,
                                        size: 15,
                                        color: done || failed
                                            ? Colors.white
                                            : null)),
                                if (entry.key != stages.length - 1)
                                  Container(
                                      width: 2,
                                      height: 20,
                                      color: done
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: .45)
                                          : Theme.of(context).dividerColor)
                              ]),
                              const SizedBox(width: 12),
                              Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(entry.value,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight:
                                              entry.key == current && running
                                                  ? FontWeight.w800
                                                  : FontWeight.normal)))
                            ]);
                      }),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                            child: DropdownButtonFormField<String>(
                                initialValue: scenario,
                                decoration: const InputDecoration(
                                    labelText: 'Demo scenario', isDense: true),
                                items: ['Success', 'Warning', 'Failure']
                                    .map((item) => DropdownMenuItem(
                                        value: item, child: Text(item)))
                                    .toList(),
                                onChanged: running
                                    ? null
                                    : (value) =>
                                        setState(() => scenario = value!))),
                        const SizedBox(width: 10),
                        Expanded(
                            child: FilledButton.icon(
                                onPressed: running ? null : simulate,
                                icon: running
                                    ? const SizedBox.square(
                                        dimension: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : const Icon(Icons.play_arrow),
                                label: Text(running
                                    ? 'Processing'
                                    : 'Simulate arrival')))
                      ]),
                      if (!running && scenario == 'Failure')
                        Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(children: [
                              OutlinedButton.icon(
                                  onPressed: simulate,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry')),
                              const SizedBox(width: 8),
                              TextButton(
                                  onPressed: () => showMessage(context,
                                      'Mock file quarantined with audit entry'),
                                  child: const Text('Quarantine')),
                              TextButton(
                                  onPressed: () => showMessage(context,
                                      'Schema field NAV_CODE is missing at row 842'),
                                  child: const Text('View error'))
                            ])),
                    ]))),
        const SectionHeader('Seven-day import health'),
        ...imports.take(7).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
                child: ListTile(
                    onTap: () => _showImport(context, item),
                    leading: CircleAvatar(child: Text(item.provider[0])),
                    title: Text('${item.provider} • ${item.id}',
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(
                        '${item.received} • ${item.records} rows • ${item.duration}'),
                    trailing: StatusChip(item.status.name, item.status))))),
      ])),
    );
  }

  void _showImport(BuildContext context, ImportRecord item) =>
      showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (sheetContext) => SafeArea(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Import ${item.id}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900)),
                        Text('${item.provider} • ${item.file}'),
                        const SizedBox(height: 16),
                        _Detail('Report code', 'WBR-TRXN'),
                        _Detail('Checksum', 'a19c••••7e2f'),
                        _Detail('Received', item.received),
                        _Detail('Processing duration', item.duration),
                        _Detail('Rows',
                            '${item.records} total • ${item.accepted} accepted • ${item.rejected} rejected'),
                        const _Detail('Duplicates / quarantined', '7 / 0'),
                        const _Detail('Parser / schema', 'v2.4.1 / 2026.09'),
                        const _Detail('Source lineage',
                            'Mailbox → attachment → staging → ledger → valuation'),
                        const SizedBox(height: 12),
                        const DemoBanner(),
                      ]))));
}

class _FeedCard extends StatelessWidget {
  const _FeedCard(
      {required this.name,
      required this.status,
      required this.detail,
      required this.dataStatus});
  final String name, status, detail;
  final DataStatus dataStatus;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: 235,
      child: Card(
          child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.mark_email_read_outlined,
                        color: Theme.of(context).colorScheme.primary),
                    const Spacer(),
                    Text(name,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    StatusChip(status, dataStatus),
                    const SizedBox(height: 5),
                    Text(detail, style: const TextStyle(fontSize: 10))
                  ]))));
}

class _Detail extends StatelessWidget {
  const _Detail(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 12))),
        Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w700)))
      ]));
}

class ReconciliationPage extends StatefulWidget {
  const ReconciliationPage({super.key});
  @override
  State<ReconciliationPage> createState() => _ReconciliationPageState();
}

class _ReconciliationPageState extends State<ReconciliationPage> {
  String filter = 'Open';
  @override
  Widget build(BuildContext context) {
    final repo = AppScope.of(context).repository;
    final cases = repo.reconciliations
        .where((item) =>
            filter == 'All' ||
            (filter == 'Open' && !item.resolved) ||
            (filter == 'Resolved' && item.resolved))
        .toList();
    return Scaffold(
        appBar: Navigator.canPop(context)
            ? AppBar(title: const Text('Reconciliation'))
            : null,
        body: ScreenBody(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!Navigator.canPop(context))
            Text('Reconciliation queue',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Open', label: Text('Open')),
                ButtonSegment(value: 'Resolved', label: Text('Resolved')),
                ButtonSegment(value: 'All', label: Text('All'))
              ],
              selected: {
                filter
              },
              onSelectionChanged: (value) =>
                  setState(() => filter = value.first)),
          const SizedBox(height: 16),
          ...cases.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                  child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                  child: Text(item.type,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w900))),
                              StatusChip(
                                  item.resolved
                                      ? 'Resolved'
                                      : item.severity.name,
                                  item.resolved
                                      ? DataStatus.completed
                                      : item.severity)
                            ]),
                            const SizedBox(height: 5),
                            Text(
                                '${item.client} • ${item.id} • ${item.importId}'),
                            const Divider(),
                            Row(children: [
                              Expanded(
                                  child: _Value(
                                      label: 'Expected', value: item.expected)),
                              Expanded(
                                  child: _Value(
                                      label: 'Actual', value: item.actual))
                            ]),
                            const SizedBox(height: 12),
                            const Text(
                                'Suggested: inspect transaction lineage and provider correction history.',
                                style: TextStyle(fontSize: 12)),
                            const SizedBox(height: 10),
                            if (!item.resolved)
                              Wrap(spacing: 8, children: [
                                OutlinedButton(
                                    onPressed: () => showMessage(context,
                                        'Case assigned to current demo operator'),
                                    child: const Text('Assign')),
                                FilledButton(
                                    onPressed: () => _resolve(context, item.id),
                                    child: const Text('Resolve')),
                                TextButton(
                                    onPressed: () => _reason(context, 'Ignore'),
                                    child: const Text('Ignore')),
                                TextButton(
                                    onPressed: () =>
                                        _reason(context, 'Escalate'),
                                    child: const Text('Escalate'))
                              ])
                          ]))))),
        ])));
  }

  Future<void> _resolve(BuildContext context, String id) async {
    if (await confirmAction(context,
        title: 'Resolve reconciliation?',
        message:
            'This updates local mock state and adds a simulated audit event.')) {
      if (!context.mounted) return;
      AppScope.of(context).repository.resolveReconciliation(id);
      setState(() {});
      showMessage(context, '$id resolved locally');
    }
  }

  void _reason(BuildContext context, String action) => showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
              title: Text('$action case'),
              content: const TextField(
                  maxLines: 3,
                  decoration: InputDecoration(labelText: 'Required reason')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      showMessage(context, '$action recorded with audit note');
                    },
                    child: const Text('Confirm'))
              ]));
}

class _Value extends StatelessWidget {
  const _Value({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800))
      ]);
}
