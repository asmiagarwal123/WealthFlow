import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/formatters.dart';
import '../../core/models.dart';
import '../../core/widgets/app_widgets.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});
  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  String period = '1Y';
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: Navigator.canPop(context)
          ? AppBar(title: const Text('Portfolio'))
          : null,
      body: ScreenBody(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (!Navigator.canPop(context))
          Text('Portfolio',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        const Text('Valuation as of 07 Oct 2026 • Last synced 09:42 IST'),
        const SizedBox(height: 14),
        SizedBox(
            height: 126,
            child: ListView(scrollDirection: Axis.horizontal, children: const [
              MetricCard(
                  label: 'Current value',
                  value: '₹28.46 L',
                  detail: '12.8% XIRR',
                  icon: Icons.account_balance_wallet_outlined,
                  positive: true),
              SizedBox(width: 12),
              MetricCard(
                  label: 'Invested',
                  value: '₹23.10 L',
                  detail: 'Net cash flow',
                  icon: Icons.savings_outlined),
              SizedBox(width: 12),
              MetricCard(
                  label: 'Total gain',
                  value: '₹5.36 L',
                  detail: '23.2% absolute',
                  icon: Icons.trending_up,
                  positive: true),
              SizedBox(width: 12),
              MetricCard(
                  label: 'Today',
                  value: '+₹18,420',
                  detail: 'Market +₹20,920',
                  icon: Icons.show_chart,
                  positive: true)
            ])),
        const SizedBox(height: 16),
        Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Expanded(
                            child: Text('Performance vs benchmark',
                                style: TextStyle(fontWeight: FontWeight.w800))),
                        DropdownButton<String>(
                            value: period,
                            underline: const SizedBox(),
                            items: [
                              '1D',
                              '1W',
                              '1M',
                              '6M',
                              '1Y',
                              '3Y',
                              '5Y',
                              'All'
                            ]
                                .map((item) => DropdownMenuItem(
                                    value: item, child: Text(item)))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => period = value!))
                      ]),
                      const Sparkline(),
                      const Row(children: [
                        Icon(Icons.circle, size: 9, color: AppColors.primary),
                        Text(' Portfolio 12.8%  '),
                        Icon(Icons.circle, size: 9, color: AppColors.secondary),
                        Text(' Benchmark 11.2%')
                      ])
                    ]))),
        const SectionHeader('Explain today’s change'),
        Card(
            child: Column(children: const [
          ListTile(
              leading: Icon(Icons.trending_up, color: AppColors.success),
              title: Text('Market movement'),
              subtitle: Text('Value change caused by NAV movement'),
              trailing: Text('+₹20,920')),
          Divider(height: 1),
          ListTile(
              leading: Icon(Icons.swap_vert),
              title: Text('Net cash flow'),
              subtitle: Text('Investments less withdrawals'),
              trailing: Text('-₹2,500'))
        ])),
        const SectionHeader('Allocation'),
        Wrap(spacing: 8, runSpacing: 8, children: const [
          Chip(label: Text('Equity 56%')),
          Chip(label: Text('Debt 28%')),
          Chip(label: Text('Hybrid 11%')),
          Chip(label: Text('Other 5%'))
        ]),
        const SectionHeader('Holdings'),
        ...AppScope.of(context).repository.schemes.take(6).map((scheme) =>
            Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                    child: ListTile(
                        onTap: () => _holding(context, scheme),
                        leading: CircleAvatar(child: Text(scheme.amc[0])),
                        title: Text(scheme.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text(
                            '${scheme.category} • NAV ₹${scheme.nav.toStringAsFixed(2)} • 07 Oct'),
                        trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                  formatInr(260000 + scheme.nav * 1000,
                                      compact: true),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800)),
                              Text('+${scheme.return1y.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                      color: AppColors.success, fontSize: 11))
                            ]))))),
        const SectionHeader('Portfolio intelligence • simulated'),
        Card(
            child: Column(children: const [
          ListTile(
              leading: Icon(Icons.warning_amber, color: AppColors.warning),
              title: Text('Small-cap concentration'),
              subtitle: Text('18% exposure • review suggested')),
          Divider(height: 1),
          ListTile(
              leading: Icon(Icons.layers_outlined),
              title: Text('Scheme overlap'),
              subtitle: Text('24% common top holdings')),
          Divider(height: 1),
          ListTile(
              leading: Icon(Icons.shield_outlined),
              title: Text('Diversification score'),
              subtitle: Text('74 / 100 • Moderate'))
        ])),
        const SizedBox(height: 16),
        OutlinedButton.icon(
            onPressed: () => showMessage(context,
                'Portfolio statement generated locally (mock download)'),
            icon: const Icon(Icons.download_outlined),
            label: const Text('Download mock statement')),
        const SizedBox(height: 12),
        const DemoBanner(),
      ])));
  void _holding(BuildContext context, SchemeRecord scheme) => Navigator.push(
      context,
      MaterialPageRoute<void>(
          builder: (_) => HoldingDetailPage(scheme: scheme)));
}

class HoldingDetailPage extends StatelessWidget {
  const HoldingDetailPage({super.key, required this.scheme});
  final SchemeRecord scheme;
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Holding details')),
      body: ScreenBody(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(scheme.name,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w900)),
        Text('${scheme.amc} • ${scheme.category} • ${scheme.risk} risk'),
        const SizedBox(height: 14),
        const DemoBanner(),
        const SectionHeader('Holding value'),
        Row(children: [
          Expanded(child: _Info('Current value', '₹4.82 L')),
          const SizedBox(width: 10),
          Expanded(child: _Info('Invested', '₹3.91 L'))
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _Info('Units', '1,824.442')),
          const SizedBox(width: 10),
          Expanded(child: _Info('XIRR', '13.6%'))
        ]),
        const SectionHeader('Performance'),
        const Card(
            child: Padding(padding: EdgeInsets.all(16), child: Sparkline())),
        const SectionHeader('NAV & folio'),
        Card(
            child: Column(children: [
          ListTile(
              title: const Text('Current NAV'),
              trailing: Text('₹${scheme.nav.toStringAsFixed(2)}')),
          const ListTile(title: Text('Average NAV'), trailing: Text('₹42.16')),
          const ListTile(
              title: Text('NAV date'), trailing: Text('07 Oct 2026')),
          const ListTile(
              title: Text('Masked folio'), trailing: Text('•••••7842'))
        ])),
        const SectionHeader('Actions'),
        Wrap(spacing: 8, children: [
          FilledButton(
              onPressed: () => showMessage(context, 'Invest-more flow opened'),
              child: const Text('Invest more')),
          OutlinedButton(
              onPressed: () =>
                  showMessage(context, 'Redemption simulation opened'),
              child: const Text('Redeem')),
          OutlinedButton(
              onPressed: () => showMessage(context, 'Switch simulation opened'),
              child: const Text('Switch'))
        ]),
        const SizedBox(height: 14),
        const Text(
            'Exit-load and tax-lot values are placeholders. Source: local mock repository • 07 Oct 2026.',
            style: TextStyle(fontSize: 11))
      ])));
}

class _Info extends StatelessWidget {
  const _Info(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(15),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 11)),
            const SizedBox(height: 5),
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 18))
          ])));
}

class SipManagementPage extends StatefulWidget {
  const SipManagementPage({super.key});
  @override
  State<SipManagementPage> createState() => _SipManagementPageState();
}

class _SipManagementPageState extends State<SipManagementPage> {
  String filter = 'All';
  @override
  Widget build(BuildContext context) {
    final repo = AppScope.of(context).repository;
    final sips = repo.sips
        .where((sip) => filter == 'All' || sip.status == filter)
        .toList();
    return Scaffold(
        appBar: AppBar(title: const Text('SIP management')),
        body: ScreenBody(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('40 SIPs • Monthly book ₹4.28 L',
              style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: [
                'All',
                'Active',
                'Failed',
                'Paused',
                'Upcoming',
                'Cancelled',
                'Step-up eligible'
              ]
                      .map((item) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                              label: Text(item),
                              selected: filter == item,
                              onSelected: (_) =>
                                  setState(() => filter = item))))
                      .toList())),
          const SizedBox(height: 14),
          ...sips.take(20).map((sip) {
            final client = repo.clientById(sip.clientId);
            return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                    child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                    child: Text(sip.scheme,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w900))),
                                StatusChip(
                                    sip.status,
                                    sip.status == 'Failed'
                                        ? DataStatus.critical
                                        : sip.status == 'Paused'
                                            ? DataStatus.warning
                                            : DataStatus.healthy)
                              ]),
                              Text(
                                  '${client.name} • ${formatInr(sip.amount)} • Monthly'),
                              const SizedBox(height: 5),
                              Text(
                                  'Next: ${sip.nextDate} • Mandate active • Ref •••${sip.id.substring(sip.id.length - 3)}',
                                  style: const TextStyle(fontSize: 11)),
                              const SizedBox(height: 10),
                              Wrap(spacing: 7, children: [
                                if (sip.status == 'Failed')
                                  FilledButton(
                                      onPressed: () => _action(context, sip,
                                          'Active', 'Retry failed SIP'),
                                      child: const Text('Retry')),
                                if (sip.status == 'Active')
                                  OutlinedButton(
                                      onPressed: () => _action(
                                          context, sip, 'Paused', 'Pause SIP'),
                                      child: const Text('Pause')),
                                OutlinedButton(
                                    onPressed: () => _action(
                                        context, sip, sip.status, 'Modify SIP'),
                                    child: const Text('Modify')),
                                TextButton(
                                    onPressed: () => showMessage(context,
                                        'Mock contact request created'),
                                    child: const Text('Contact'))
                              ])
                            ]))));
          }).toList(),
        ])));
  }

  Future<void> _action(
      BuildContext context, SipRecord sip, String status, String action) async {
    if (await confirmAction(context,
        title: '$action?',
        message:
            'No mandate or bank instruction will be changed. This is a local simulation.')) {
      if (!context.mounted) return;
      setState(() => sip.status = status);
      showMessage(context, '$action completed • status is now $status');
    }
  }
}

class TransactionWizardPage extends StatefulWidget {
  const TransactionWizardPage({super.key, this.initialType = 'Purchase'});
  final String initialType;
  @override
  State<TransactionWizardPage> createState() => _TransactionWizardPageState();
}

class _TransactionWizardPageState extends State<TransactionWizardPage> {
  int step = 0;
  late String type = widget.initialType;
  bool submitted = false;
  static const titles = [
    'Client & folio',
    'Scheme & transaction',
    'Amount',
    'Suitability',
    'Payment placeholder',
    'Review',
    'Status'
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Simulated transaction')),
      body: SafeArea(
          child: Column(children: [
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            color: AppColors.warning.withValues(alpha: .12),
            child: const Text(
                'DEMO ONLY • No order, payment or mandate instruction will be sent.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900))),
        LinearProgressIndicator(value: (step + 1) / titles.length),
        Expanded(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titles[step],
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 16),
                      _transactionStep(context)
                    ]))),
        Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              if (step > 0 && !submitted)
                Expanded(
                    child: OutlinedButton(
                        onPressed: () => setState(() => step--),
                        child: const Text('Back'))),
              if (step > 0 && !submitted) const SizedBox(width: 10),
              Expanded(
                  child: FilledButton(
                      onPressed:
                          submitted ? () => Navigator.pop(context) : _next,
                      child: Text(submitted
                          ? 'Done'
                          : step == 5
                              ? 'Confirm simulation'
                              : 'Continue')))
            ]))
      ])));
  Widget _transactionStep(BuildContext context) => switch (step) {
        0 => Column(children: [
            DropdownButtonFormField<String>(
                initialValue: 'Rahul Mehta',
                decoration: InputDecoration(labelText: 'Client'),
                items: [
                  DropdownMenuItem(
                      value: 'Rahul Mehta',
                      child: Text('Rahul Mehta • ABCDE••20K'))
                ],
                onChanged: null),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
                initialValue: 'Folio ••••7842',
                decoration: InputDecoration(labelText: 'Folio'),
                items: [
                  DropdownMenuItem(
                      value: 'Folio ••••7842', child: Text('Folio ••••7842'))
                ],
                onChanged: null)
          ]),
        1 => Column(children: [
            DropdownButtonFormField<String>(
                initialValue: type,
                decoration:
                    const InputDecoration(labelText: 'Transaction type'),
                items: [
                  'Purchase',
                  'Additional purchase',
                  'Redemption',
                  'Switch',
                  'Start SIP'
                ]
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) => setState(() => type = value!)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
                initialValue: 'HDFC Flexi Cap Fund',
                decoration: InputDecoration(labelText: 'Scheme'),
                items: [
                  DropdownMenuItem(
                      value: 'HDFC Flexi Cap Fund',
                      child: Text('HDFC Flexi Cap Fund'))
                ],
                onChanged: null)
          ]),
        2 =>
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₹ ',
                    helperText: 'Minimum ₹500')),
            SizedBox(height: 12),
            Text('Latest NAV ₹84.72 • NAV date 07 Oct 2026',
                style: TextStyle(fontSize: 12))
          ]),
        3 => const Card(
            child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusChip('Suitable', DataStatus.healthy),
                      SizedBox(height: 10),
                      Text(
                          'Client risk: Moderate • Scheme risk: Moderate to high'),
                      SizedBox(height: 8),
                      Text(
                          'This demonstration is not a regulatory suitability certification or investment recommendation.',
                          style: TextStyle(fontSize: 11))
                    ]))),
        4 => Column(children: [
            DropdownButtonFormField<String>(
                initialValue: 'Demo mandate ••••2391',
                decoration:
                    InputDecoration(labelText: 'Payment / mandate placeholder'),
                items: [
                  DropdownMenuItem(
                      value: 'Demo mandate ••••2391',
                      child: Text('Demo mandate ••••2391'))
                ],
                onChanged: null),
            SizedBox(height: 14),
            DemoBanner()
          ]),
        5 => Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(type,
                          style: const TextStyle(
                              fontSize: 19, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      const Text('Rahul Mehta • Folio ••••7842'),
                      const Text('HDFC Flexi Cap Fund • ₹25,000'),
                      const Divider(),
                      CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: true,
                          onChanged: (_) {},
                          title: const Text(
                              'I understand this is a UI simulation only.'))
                    ]))),
        _ => Card(
            child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(children: [
                  const Icon(Icons.check_circle_outline,
                      color: AppColors.success, size: 54),
                  const SizedBox(height: 10),
                  const Text('Mock order successful',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  const Text('Internal ID WF-ORD-20261007-42'),
                  const SizedBox(height: 16),
                  ...[
                    'Created',
                    'Submitted',
                    'Acknowledged',
                    'Processing',
                    'Successful'
                  ].map((item) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.check_circle,
                          color: AppColors.success),
                      title: Text(item),
                      trailing: const Text('Simulated',
                          style: TextStyle(fontSize: 10))))
                ]))),
      };
  Future<void> _next() async {
    if (step == 5) {
      final ok = await confirmAction(context,
          title: 'Submit mock order?',
          message: 'This does not place a real mutual-fund transaction.');
      if (!ok) return;
      setState(() {
        step = 6;
        submitted = true;
      });
      return;
    }
    setState(() => step++);
  }
}

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key, this.openCreate = false});
  final bool openCreate;
  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  @override
  void initState() {
    super.initState();
    if (widget.openCreate)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _create(context);
      });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar:
          Navigator.canPop(context) ? AppBar(title: const Text('Goals')) : null,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _create(context),
          icon: const Icon(Icons.add),
          label: const Text('New goal')),
      body: ScreenBody(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (!Navigator.canPop(context))
          Text('Goals',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const DemoBanner(),
        const SectionHeader('Your goals'),
        _goal('Retirement', '₹18.4 L of ₹30 L', .62, 'On track',
            DataStatus.healthy),
        const SizedBox(height: 10),
        _goal('Child education', '₹7.6 L of ₹20 L', .38, 'Review suggested',
            DataStatus.warning),
        const SizedBox(height: 10),
        _goal('Emergency fund', '₹4.1 L of ₹5 L', .82, 'On track',
            DataStatus.healthy)
      ])));
  Widget _goal(String name, String value, double progress, String status,
          DataStatus ds) =>
      Card(
          child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => showMessage(context,
                  '$name goal details opened • projected range is an estimate'),
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                              child: Text(name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900))),
                          StatusChip(status, ds)
                        ]),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(8)),
                        const SizedBox(height: 8),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(value),
                              Text('${(progress * 100).round()}%')
                            ]),
                        const SizedBox(height: 5),
                        const Text(
                            'Required monthly SIP ₹18,500 • projected range is an estimate',
                            style: TextStyle(fontSize: 10))
                      ]))));
  void _create(BuildContext context) {
    var wizardStep = 0;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create mock goal • ${wizardStep + 1}/4',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 15),
              if (wizardStep == 0)
                DropdownButtonFormField<String>(
                  initialValue: 'Retirement',
                  decoration: InputDecoration(labelText: 'Goal type'),
                  items: [
                    DropdownMenuItem(
                        value: 'Retirement', child: Text('Retirement')),
                    DropdownMenuItem(
                        value: 'Education', child: Text('Child education')),
                    DropdownMenuItem(
                        value: 'Home', child: Text('Home purchase')),
                    DropdownMenuItem(value: 'Custom', child: Text('Custom')),
                  ],
                  onChanged: null,
                ),
              if (wizardStep == 1)
                const Column(
                  children: [
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: 'Target amount', prefixText: '₹ '),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Target date',
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                  ],
                ),
              if (wizardStep == 2)
                const Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                          labelText: 'Current savings', prefixText: '₹ '),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                          labelText: 'Expected inflation', suffixText: '%'),
                    ),
                  ],
                ),
              if (wizardStep == 3)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Text(
                      'Estimated allocation: Equity 60% • Debt 35% • Other 5%\n'
                      'Required monthly SIP: ₹18,500\n'
                      'Projections are estimates and not guaranteed.',
                    ),
                  ),
                ),
              const SizedBox(height: 15),
              FilledButton(
                onPressed: () {
                  if (wizardStep < 3) {
                    setSheetState(() => wizardStep++);
                  } else {
                    Navigator.pop(sheetContext);
                    showMessage(this.context, 'Mock goal saved successfully');
                  }
                },
                child: Text(wizardStep == 3 ? 'Save mock goal' : 'Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProposalPage extends StatefulWidget {
  const ProposalPage({super.key});
  @override
  State<ProposalPage> createState() => _ProposalPageState();
}

class _ProposalPageState extends State<ProposalPage> {
  int step = 0;
  static const labels = [
    'Client',
    'Goal',
    'Amount & horizon',
    'Allocation',
    'Schemes',
    'Suitability',
    'Note',
    'Preview'
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Proposal generator')),
      body: SafeArea(
          child: Column(children: [
        LinearProgressIndicator(value: (step + 1) / labels.length),
        Expanded(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(labels[step],
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 15),
                      _body()
                    ]))),
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
                      onPressed: () {
                        if (step < labels.length - 1)
                          setState(() => step++);
                        else
                          _generate(context);
                      },
                      child: Text(step == labels.length - 1
                          ? 'Generate mock PDF'
                          : 'Continue')))
            ]))
      ])));
  Widget _body() {
    if (step == 0)
      return DropdownButtonFormField<String>(
          initialValue: 'Rahul Mehta',
          decoration: InputDecoration(labelText: 'Client'),
          items: [
            DropdownMenuItem(value: 'Rahul Mehta', child: Text('Rahul Mehta'))
          ],
          onChanged: null);
    if (step == 1)
      return DropdownButtonFormField<String>(
          initialValue: 'Retirement',
          decoration: InputDecoration(labelText: 'Goal'),
          items: [
            DropdownMenuItem(value: 'Retirement', child: Text('Retirement'))
          ],
          onChanged: null);
    if (step == 2)
      return Column(children: [
        TextField(
            decoration: InputDecoration(
                labelText: 'Investment amount', prefixText: '₹ ')),
        SizedBox(height: 10),
        DropdownButtonFormField<String>(
            initialValue: '5-7 years',
            decoration: InputDecoration(labelText: 'Horizon'),
            items: [
              DropdownMenuItem(value: '5-7 years', child: Text('5-7 years'))
            ],
            onChanged: null)
      ]);
    if (step == 3)
      return const Column(children: [
        ListTile(
            leading: Icon(Icons.pie_chart_outline),
            title: Text('Balanced growth'),
            subtitle: Text('Equity 60% • Debt 35% • Other 5%'),
            trailing: Icon(Icons.check_circle, color: AppColors.success)),
        DemoBanner()
      ]);
    if (step == 4)
      return const Column(children: [
        CheckboxListTile(
            value: true, onChanged: null, title: Text('HDFC Flexi Cap Fund')),
        CheckboxListTile(
            value: true,
            onChanged: null,
            title: Text('ICICI Prudential Corporate Bond Fund')),
        CheckboxListTile(
            value: true,
            onChanged: null,
            title: Text('SBI Balanced Advantage Fund'))
      ]);
    if (step == 5)
      return const Card(
          child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusChip('Suitable', DataStatus.healthy),
                    SizedBox(height: 10),
                    Text(
                        'Moderate client risk aligns with the illustrative balanced allocation.'),
                    SizedBox(height: 8),
                    Text(
                        'Demonstration workflow, not regulatory certification or investment advice.',
                        style: TextStyle(fontSize: 11))
                  ])));
    if (step == 6)
      return const TextField(
          maxLines: 4,
          decoration: InputDecoration(
              labelText: 'Distributor note',
              hintText: 'Add a fictional note for the client'));
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.auto_graph_rounded),
                SizedBox(width: 8),
                Text('WEALTHFLOW PROPOSAL',
                    style: TextStyle(fontWeight: FontWeight.w900))
              ]),
              const Divider(),
              const Text('Prepared for Rahul Mehta',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const Text('Retirement • 5–7 years • ₹5,00,000'),
              const SizedBox(height: 14),
              const Text('Illustrative allocation',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              const LinearProgressIndicator(value: .6, minHeight: 14),
              const SizedBox(height: 8),
              const Text('Equity 60% • Debt 35% • Other 5%'),
              const Divider(),
              const Text(
                  'Estimated outcomes are not guaranteed. This mock proposal is not investment advice.',
                  style: TextStyle(fontSize: 10))
            ])));
  }

  void _generate(BuildContext context) => showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 48),
              title: const Text('Mock proposal generated'),
              content: const Text(
                  'Version 1 saved locally. Sharing by email or WhatsApp is simulated only.'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      showMessage(
                          context, 'Mock share recorded • no message sent');
                    },
                    child: const Text('Simulate share')),
                FilledButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                    child: const Text('Done'))
              ]));
}

class FundExplorerPage extends StatefulWidget {
  const FundExplorerPage({super.key});
  @override
  State<FundExplorerPage> createState() => _FundExplorerPageState();
}

class _FundExplorerPageState extends State<FundExplorerPage> {
  String query = '';
  final selected = <String>{};
  @override
  Widget build(BuildContext context) {
    final schemes = AppScope.of(context)
        .repository
        .schemes
        .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return Scaffold(
        appBar: AppBar(title: const Text('Fund Explorer'), actions: [
          Badge(
              label: Text('${selected.length}'),
              child: IconButton(
                  onPressed: selected.length < 2
                      ? null
                      : () => showMessage(context,
                          'Comparing ${selected.length} schemes • simulated metrics'),
                  icon: const Icon(Icons.compare_arrows)))
        ]),
        body: ScreenBody(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
              onChanged: (v) => setState(() => query = v),
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search scheme or AMC')),
          const SizedBox(height: 10),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: [
                'All',
                'Equity',
                'Debt',
                'Hybrid',
                'Low risk',
                'Expense < 1%'
              ]
                      .map((e) => Padding(
                          padding: const EdgeInsets.only(right: 7),
                          child: FilterChip(
                              label: Text(e),
                              onSelected: (_) {},
                              selected: e == 'All')))
                      .toList())),
          const SizedBox(height: 14),
          ...schemes
              .map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                      child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Expanded(
                                      child: Text(s.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w900))),
                                  IconButton(
                                      onPressed: () => showMessage(context,
                                          '${s.name} added to watchlist'),
                                      icon: const Icon(Icons.bookmark_border))
                                ]),
                                Text(
                                    '${s.category} • ${s.risk} risk • NAV ₹${s.nav.toStringAsFixed(2)}'),
                                const SizedBox(height: 8),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _MiniFund('1Y',
                                          '${s.return1y.toStringAsFixed(1)}%'),
                                      _MiniFund('3Y',
                                          '${s.return3y.toStringAsFixed(1)}%'),
                                      _MiniFund('AUM',
                                          '₹${s.aumCrore.toStringAsFixed(0)} Cr'),
                                      _MiniFund('Expense',
                                          '${s.expenseRatio.toStringAsFixed(2)}%')
                                    ]),
                                const SizedBox(height: 8),
                                Row(children: [
                                  Checkbox(
                                      value: selected.contains(s.id),
                                      onChanged: (v) => setState(() {
                                            if (v == true &&
                                                selected.length < 4)
                                              selected.add(s.id);
                                            else
                                              selected.remove(s.id);
                                          })),
                                  const Text('Compare'),
                                  const Spacer(),
                                  TextButton(
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute<void>(
                                              builder: (_) => HoldingDetailPage(
                                                  scheme: s))),
                                      child: const Text('Details')),
                                  FilledButton(
                                      onPressed: () => showMessage(
                                          context, 'Mock invest flow opened'),
                                      child: const Text('Invest'))
                                ])
                              ])))))
              .toList(),
          const DemoBanner()
        ])));
  }
}

class _MiniFund extends StatelessWidget {
  const _MiniFund(this.l, this.v);
  final String l, v;
  @override
  Widget build(BuildContext c) => Column(children: [
        Text(l, style: const TextStyle(fontSize: 10)),
        Text(v, style: const TextStyle(fontWeight: FontWeight.w800))
      ]);
}
