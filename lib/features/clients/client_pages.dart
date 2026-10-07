import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/formatters.dart';
import '../../core/models.dart';
import '../../core/widgets/app_widgets.dart';
import '../workflows/workflow_pages.dart';

class ClientDirectoryPage extends StatefulWidget {
  const ClientDirectoryPage({super.key});
  @override
  State<ClientDirectoryPage> createState() => _ClientDirectoryPageState();
}

class _ClientDirectoryPageState extends State<ClientDirectoryPage> {
  String query = '';
  String filter = 'All';
  bool cards = true;

  @override
  Widget build(BuildContext context) {
    final clients = AppScope.of(context).repository.clients.where((client) {
      final matches = client.name.toLowerCase().contains(query.toLowerCase()) ||
          client.maskedPan.toLowerCase().contains(query.toLowerCase());
      final filtered = filter == 'All' ||
          (filter == 'KYC review' && client.kycStatus != 'Verified') ||
          (filter == 'Has alert' && client.alert != null) ||
          (filter == client.risk);
      return matches && filtered;
    }).toList();
    return ScreenBody(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Clients',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900)),
          Text('${clients.length} of 25 fictional client records')
        ])),
        IconButton(
            tooltip: cards ? 'List view' : 'Card view',
            onPressed: () => setState(() => cards = !cards),
            icon: Icon(
                cards ? Icons.view_list_outlined : Icons.grid_view_outlined)),
        IconButton(
            tooltip: 'Sort',
            onPressed: () =>
                setState(() => clients.sort((a, b) => b.aum.compareTo(a.aum))),
            icon: const Icon(Icons.sort))
      ]),
      const SizedBox(height: 14),
      TextField(
          onChanged: (value) => setState(() => query = value),
          decoration: const InputDecoration(
              hintText: 'Search name or masked PAN',
              prefixIcon: Icon(Icons.search),
              suffixIcon: Icon(Icons.tune))),
      const SizedBox(height: 12),
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              children: [
            'All',
            'Has alert',
            'KYC review',
            'Low',
            'Moderate',
            'High'
          ]
                  .map((item) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                          label: Text(item),
                          selected: filter == item,
                          onSelected: (_) => setState(() => filter = item))))
                  .toList())),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(
            child: OutlinedButton.icon(
                onPressed: () => _showFilters(context),
                icon: const Icon(Icons.filter_alt_outlined),
                label: const Text('Advanced filters'))),
        const SizedBox(width: 10),
        Expanded(
            child: FilledButton.icon(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                        builder: (_) => const AddClientWizardPage())),
                icon: const Icon(Icons.person_add_alt),
                label: const Text('Add client')))
      ]),
      const SizedBox(height: 16),
      if (clients.isEmpty)
        const _EmptyClients()
      else
        ...clients.map((client) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ClientCard(client: client, compact: !cards))),
    ]));
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (sheetContext) => SafeArea(
            child: Padding(
                padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: MediaQuery.viewInsetsOf(sheetContext).bottom + 24),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Filter clients',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                          initialValue: 'All RMs',
                          decoration: InputDecoration(
                              labelText: 'Relationship manager'),
                          items: [
                            DropdownMenuItem(
                                value: 'All RMs', child: Text('All RMs')),
                            DropdownMenuItem(
                                value: 'Ananya', child: Text('Ananya'))
                          ],
                          onChanged: null),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                          initialValue: 'Any AUM',
                          decoration: InputDecoration(labelText: 'AUM range'),
                          items: [
                            DropdownMenuItem(
                                value: 'Any AUM', child: Text('Any AUM')),
                            DropdownMenuItem(
                                value: '25L+',
                                child: Text('₹25 lakh and above'))
                          ],
                          onChanged: null),
                      const SizedBox(height: 12),
                      SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: true,
                          onChanged: (_) {},
                          title: const Text('Review due only')),
                      FilledButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            setState(() => filter = 'KYC review');
                          },
                          child: const Text('Apply demo filters')),
                    ]))));
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.client, required this.compact});
  final ClientRecord client;
  final bool compact;
  @override
  Widget build(BuildContext context) => Card(
      child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                  builder: (_) => Client360Page(clientId: client.id))),
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      CircleAvatar(
                          child: Text(client.name
                              .split(' ')
                              .map((part) => part[0])
                              .take(2)
                              .join())),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(client.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900)),
                            Text('${client.maskedPan} • ${client.rm}',
                                style: const TextStyle(fontSize: 11))
                          ])),
                      StatusChip(
                          client.kycStatus,
                          client.kycStatus == 'Verified'
                              ? DataStatus.healthy
                              : DataStatus.warning)
                    ]),
                    if (!compact) ...[
                      const Divider(height: 24),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _Mini(
                                label: 'AUM',
                                value: formatInr(client.aum, compact: true)),
                            _Mini(
                                label: 'XIRR',
                                value: '${client.xirr.toStringAsFixed(1)}%'),
                            _Mini(
                                label: 'Monthly SIP',
                                value:
                                    formatInr(client.monthlySip, compact: true))
                          ]),
                      const SizedBox(height: 14),
                      Row(children: [
                        Chip(label: Text('${client.risk} risk')),
                        const SizedBox(width: 8),
                        if (client.alert != null)
                          Chip(
                              avatar: const Icon(Icons.warning_amber,
                                  size: 16, color: AppColors.warning),
                              label: Text(client.alert!)),
                        const Spacer(),
                        const Icon(Icons.chevron_right)
                      ])
                    ],
                  ]))));
}

class _Mini extends StatelessWidget {
  const _Mini({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800))
      ]);
}

class _EmptyClients extends StatelessWidget {
  const _EmptyClients();
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(children: [
            const Icon(Icons.person_search_outlined, size: 48),
            const SizedBox(height: 12),
            const Text('No clients match these filters',
                style: TextStyle(fontWeight: FontWeight.w800)),
            TextButton(
                onPressed: () =>
                    showMessage(context, 'Clear the search or select All'),
                child: const Text('Clear filters'))
          ])));
}

class Client360Page extends StatefulWidget {
  const Client360Page({super.key, required this.clientId});
  final String clientId;
  @override
  State<Client360Page> createState() => _Client360PageState();
}

class _Client360PageState extends State<Client360Page> {
  int tab = 0;
  static const tabs = [
    'Overview',
    'Holdings',
    'Transactions',
    'SIPs',
    'Goals',
    'Capital Gains',
    'Documents',
    'Family',
    'Notes',
    'Communications',
    'Requests',
    'Compliance',
    'Audit'
  ];
  @override
  Widget build(BuildContext context) {
    final client = AppScope.of(context).repository.clientById(widget.clientId);
    return Scaffold(
        appBar: AppBar(title: const Text('Client 360')),
        body: ScreenBody(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(radius: 30, child: Text(client.name[0])),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(client.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900)),
                  Text('${client.maskedPan} • +91 ••••• 4821'),
                  const SizedBox(height: 7),
                  Wrap(spacing: 7, runSpacing: 6, children: [
                    StatusChip(
                        client.kycStatus,
                        client.kycStatus == 'Verified'
                            ? DataStatus.healthy
                            : DataStatus.warning),
                    StatusChip('${client.risk} risk', DataStatus.pending),
                    const StatusChip('Fresh 09:42', DataStatus.healthy)
                  ])
                ]))
          ]),
          const SizedBox(height: 16),
          const DemoBanner(),
          const SectionHeader('Portfolio summary'),
          SizedBox(
              height: 126,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                MetricCard(
                    label: 'Current value',
                    value: formatInr(client.aum, compact: true),
                    detail: 'Valued 07 Oct',
                    icon: Icons.account_balance_wallet_outlined),
                const SizedBox(width: 12),
                MetricCard(
                    label: 'Invested value',
                    value: formatInr(client.invested, compact: true),
                    detail: 'Net cash flow',
                    icon: Icons.savings_outlined),
                const SizedBox(width: 12),
                MetricCard(
                    label: 'Gain / loss',
                    value:
                        formatInr(client.aum - client.invested, compact: true),
                    detail: '${client.xirr.toStringAsFixed(1)}% XIRR',
                    icon: Icons.trending_up,
                    positive: true),
                const SizedBox(width: 12),
                MetricCard(
                    label: 'Monthly SIP',
                    value: formatInr(client.monthlySip),
                    detail: '4 active',
                    icon: Icons.autorenew)
              ])),
          const SizedBox(height: 16),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<int>(
                  segments: List.generate(tabs.length,
                      (i) => ButtonSegment(value: i, label: Text(tabs[i]))),
                  selected: {tab},
                  onSelectionChanged: (value) =>
                      setState(() => tab = value.first),
                  multiSelectionEnabled: false,
                  showSelectedIcon: false)),
          const SizedBox(height: 16),
          _ClientTabContent(tab: tabs[tab], client: client),
          const SectionHeader('Quick actions'),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ActionChip(
                label: const Text('Invest'),
                avatar: const Icon(Icons.add_chart, size: 17),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                        builder: (_) => const TransactionWizardPage()))),
            ActionChip(
                label: const Text('Start SIP'),
                avatar: const Icon(Icons.autorenew, size: 17),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                        builder: (_) => const SipManagementPage()))),
            ActionChip(
                label: const Text('Proposal'),
                avatar: const Icon(Icons.description_outlined, size: 17),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                        builder: (_) => const ProposalPage()))),
            ActionChip(
                label: const Text('Add note'),
                avatar: const Icon(Icons.note_add_outlined, size: 17),
                onPressed: () => _noteSheet(context)),
          ]),
        ])));
  }

  void _noteSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Add client note',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                const TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                        hintText: 'Type a fictional demo note')),
                const SizedBox(height: 12),
                FilledButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      showMessage(context,
                          'Client note saved locally and audit entry added');
                    },
                    child: const Text('Save note'))
              ])));
}

class _ClientTabContent extends StatelessWidget {
  const _ClientTabContent({required this.tab, required this.client});
  final String tab;
  final ClientRecord client;
  @override
  Widget build(BuildContext context) {
    if (tab == 'Overview')
      return Card(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Explainable portfolio movement',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    const Sparkline(height: 120),
                    const Divider(),
                    const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading:
                            Icon(Icons.trending_up, color: AppColors.success),
                        title: Text('Market movement'),
                        trailing: Text('+₹22,460',
                            style: TextStyle(fontWeight: FontWeight.w800))),
                    const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.swap_vert),
                        title: Text('Investment cash flow'),
                        trailing: Text('-₹4,040',
                            style: TextStyle(fontWeight: FontWeight.w800)))
                  ])));
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$tab for ${client.name}',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(
                  'A complete $tab workspace is represented with coherent local demo data, timestamps and action feedback.'),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                  onPressed: () => showMessage(
                      context, '$tab detail opened in demonstration mode'),
                  icon: const Icon(Icons.open_in_new),
                  label: Text('Open $tab detail'))
            ])));
  }
}

class AddClientWizardPage extends StatefulWidget {
  const AddClientWizardPage({super.key});
  @override
  State<AddClientWizardPage> createState() => _AddClientWizardPageState();
}

class _AddClientWizardPageState extends State<AddClientWizardPage> {
  int step = 0;
  final formKey = GlobalKey<FormState>();
  static const steps = [
    'Personal information',
    'Contact information',
    'PAN and KYC',
    'FATCA / CRS',
    'Bank summary',
    'Nominee',
    'Risk profile',
    'Family mapping',
    'Documents',
    'Review'
  ];
  final name = TextEditingController(text: 'Sample Investor');
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Add demo client'), actions: [
        TextButton(
            onPressed: () => showMessage(context, 'Draft saved locally'),
            child: const Text('Save draft'))
      ]),
      body: SafeArea(
          child: Form(
              key: formKey,
              child: Column(children: [
                LinearProgressIndicator(value: (step + 1) / steps.length),
                Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      CircleAvatar(child: Text('${step + 1}')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(steps[step],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900)),
                            Text('Step ${step + 1} of ${steps.length}',
                                style: const TextStyle(fontSize: 11))
                          ]))
                    ])),
                Expanded(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _formFor(step))),
                Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      if (step > 0)
                        Expanded(
                            child: OutlinedButton(
                                onPressed: () => setState(() => step--),
                                child: const Text('Back'))),
                      if (step > 0) const SizedBox(width: 10),
                      Expanded(
                          child: FilledButton(
                              onPressed: _next,
                              child: Text(step == steps.length - 1
                                  ? 'Submit demo client'
                                  : 'Continue')))
                    ]))
              ]))));
  Widget _formFor(int index) {
    if (index == 0)
      return Column(children: [
        TextFormField(
            controller: name,
            validator: (v) => v == null || v.trim().length < 3
                ? 'Enter a fictional name'
                : null,
            decoration: const InputDecoration(labelText: 'Full name')),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
            initialValue: 'Individual',
            decoration: InputDecoration(labelText: 'Client type'),
            items: [
              DropdownMenuItem(value: 'Individual', child: Text('Individual')),
              DropdownMenuItem(value: 'Joint', child: Text('Joint')),
              DropdownMenuItem(
                  value: 'Minor', child: Text('Minor with guardian')),
              DropdownMenuItem(value: 'NRI', child: Text('NRI')),
              DropdownMenuItem(value: 'HUF', child: Text('HUF'))
            ],
            onChanged: null)
      ]);
    if (index == 2)
      return Column(children: [
        TextField(
            decoration: InputDecoration(
                labelText: 'Masked demo PAN', hintText: 'ABCDE••42K')),
        SizedBox(height: 12),
        DropdownButtonFormField<String>(
            initialValue: 'Pending mock verification',
            decoration: InputDecoration(labelText: 'KYC status'),
            items: [
              DropdownMenuItem(
                  value: 'Pending mock verification',
                  child: Text('Pending mock verification'))
            ],
            onChanged: null),
        SizedBox(height: 16),
        DemoBanner()
      ]);
    if (index == 6)
      return Column(children: [
        const Text(
            'How comfortable is the client with short-term market decline?'),
        Slider(value: .55, onChanged: (_) {}),
        const ListTile(
            leading: Icon(Icons.analytics_outlined),
            title: Text('Indicative risk band'),
            subtitle: Text('Moderate • demonstration only'))
      ]);
    if (index == 9)
      return Card(
          child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name.text,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 18)),
                    const SizedBox(height: 8),
                    const Text('Individual • KYC pending • Moderate risk'),
                    const Divider(),
                    const Text(
                        'All entered values are fictional and remain in this local demo session.'),
                    const SizedBox(height: 12),
                    const DemoBanner()
                  ])));
    return Column(children: [
      TextField(
          decoration:
              InputDecoration(labelText: '${steps[index]} sample field')),
      const SizedBox(height: 12),
      TextField(
          decoration: const InputDecoration(labelText: 'Optional demo detail')),
      const SizedBox(height: 16),
      const Text(
          'This step intentionally collects only fake demonstration information.',
          style: TextStyle(fontSize: 12))
    ]);
  }

  void _next() {
    if (step == 0 && !(formKey.currentState?.validate() ?? false)) return;
    if (step == steps.length - 1) {
      showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
                  icon: const Icon(Icons.check_circle_outline,
                      color: AppColors.success, size: 48),
                  title: const Text('Demo client created'),
                  content: const Text(
                      'No real KYC, PAN, bank or investor record was created.'),
                  actions: [
                    FilledButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          Navigator.pop(context);
                        },
                        child: const Text('Done'))
                  ]));
    } else
      setState(() => step++);
  }
}
