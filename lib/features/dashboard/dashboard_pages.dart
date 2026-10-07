import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/formatters.dart';
import '../../core/models.dart';
import '../../core/widgets/app_widgets.dart';
import '../clients/client_pages.dart';
import '../imports/import_pages.dart';
import '../modules/module_pages.dart';
import '../workflows/workflow_pages.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return switch (app.activeRole!) {
      UserRole.client => const _ClientDashboard(),
      UserRole.operations => const _OperationsDashboard(),
      UserRole.administrator => const _AdminDashboard(),
      UserRole.distributor ||
      UserRole.relationshipManager =>
        const _DistributorDashboard(),
    };
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              const Wrap(
                spacing: 8,
                runSpacing: 5,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusChip('Fresh', DataStatus.healthy),
                  Text('Last synced 09:42 IST', style: TextStyle(fontSize: 11)),
                ],
              ),
            ]),
          ),
          const CircleAvatar(radius: 24, child: Text('AM')),
        ],
      );
}

class _DistributorDashboard extends StatefulWidget {
  const _DistributorDashboard();
  @override
  State<_DistributorDashboard> createState() => _DistributorDashboardState();
}

class _DistributorDashboardState extends State<_DistributorDashboard> {
  String period = '6M';
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final clients = app.repository.clients;
    return RefreshIndicator(
      onRefresh: () async {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (context.mounted)
          showMessage(
              context, 'Dashboard refreshed from local mock repository');
      },
      child: ScreenBody(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _DashboardHeader(
            title: 'Good morning, Arjun',
            subtitle: 'Your distribution business is moving steadily today.'),
        const SizedBox(height: 16),
        const DemoBanner(),
        const SectionHeader('Business pulse'),
        SizedBox(
            height: 126,
            child: ListView(scrollDirection: Axis.horizontal, children: const [
              MetricCard(
                  label: 'Total AUM',
                  value: '₹84.62 Cr',
                  detail: '1.8% today',
                  icon: Icons.account_balance_outlined,
                  positive: true),
              SizedBox(width: 12),
              MetricCard(
                  label: 'Net inflow',
                  value: '₹1.24 Cr',
                  detail: 'October',
                  icon: Icons.south_west,
                  positive: true),
              SizedBox(width: 12),
              MetricCard(
                  label: 'Clients',
                  value: '1,248',
                  detail: '32 new',
                  icon: Icons.people_outline,
                  positive: true),
              SizedBox(width: 12),
              MetricCard(
                  label: 'SIP book',
                  value: '₹2.84 Cr',
                  detail: '3,482 active',
                  icon: Icons.autorenew),
              SizedBox(width: 12),
              MetricCard(
                  label: 'Net brokerage',
                  value: '₹8.46 L',
                  detail: '4.2% vs Sep',
                  icon: Icons.currency_rupee,
                  positive: true),
            ])),
        const SizedBox(height: 18),
        Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Expanded(
                            child: Text('AUM trend',
                                style: TextStyle(fontWeight: FontWeight.w800))),
                        DropdownButton<String>(
                            value: period,
                            underline: const SizedBox(),
                            items: ['1M', '3M', '6M', '1Y', '3Y', 'All']
                                .map((item) => DropdownMenuItem(
                                    value: item, child: Text(item)))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => period = value!))
                      ]),
                      const Text('Valuation as of 07 Oct 2026 • simulated',
                          style: TextStyle(fontSize: 11)),
                      const Sparkline(),
                    ]))),
        const SectionHeader('Needs attention'),
        ...app.repository.actions
            .where((item) => !item.resolved)
            .take(4)
            .map((action) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                    child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: (action.severity == DataStatus.critical
                              ? AppColors.error
                              : AppColors.warning)
                          .withValues(alpha: .12),
                      child: Icon(
                          action.severity == DataStatus.critical
                              ? Icons.error_outline
                              : Icons.warning_amber,
                          color: action.severity == DataStatus.critical
                              ? AppColors.error
                              : AppColors.warning)),
                  title: Text(action.type,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${action.client} • ${action.problem}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                          builder: (_) => const ActionCentrePage())),
                )))),
        SectionHeader('Top clients',
            action: 'View all',
            onAction: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                    builder: (_) => const ClientDirectoryPage()))),
        ...clients.take(4).map((client) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(child: Text(client.name[0])),
            title: Text(client.name),
            subtitle: Text(
                '${client.family} • ${client.xirr.toStringAsFixed(1)}% XIRR'),
            trailing: Text(formatInr(client.aum, compact: true),
                style: const TextStyle(fontWeight: FontWeight.w800)),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                    builder: (_) => Client360Page(clientId: client.id))))),
        const SectionHeader('Quick actions'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          ActionChip(
              avatar: const Icon(Icons.person_add_alt, size: 18),
              label: const Text('Add client'),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                      builder: (_) => const AddClientWizardPage()))),
          ActionChip(
              avatar: const Icon(Icons.autorenew, size: 18),
              label: const Text('Start SIP'),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                      builder: (_) => const SipManagementPage()))),
          ActionChip(
              avatar: const Icon(Icons.description_outlined, size: 18),
              label: const Text('Proposal'),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                      builder: (_) => const ProposalPage()))),
          ActionChip(
              avatar: const Icon(Icons.move_to_inbox_outlined, size: 18),
              label: const Text('WBR import'),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                      builder: (_) => const ImportControlPage()))),
        ]),
      ])),
    );
  }
}

class _ClientDashboard extends StatelessWidget {
  const _ClientDashboard();
  @override
  Widget build(BuildContext context) => ScreenBody(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _DashboardHeader(
            title: 'Good morning, Aditi',
            subtitle: 'Your household wealth, explained simply.'),
        const SizedBox(height: 16),
        const DemoBanner(),
        const SectionHeader('Your wealth'),
        SizedBox(
            height: 126,
            child: ListView(scrollDirection: Axis.horizontal, children: const [
              MetricCard(
                  label: 'Current value',
                  value: '₹28.46 L',
                  detail: 'Valued 07 Oct',
                  icon: Icons.account_balance_wallet_outlined),
              SizedBox(width: 12),
              MetricCard(
                  label: 'Invested value',
                  value: '₹23.10 L',
                  detail: 'Net contribution',
                  icon: Icons.savings_outlined),
              SizedBox(width: 12),
              MetricCard(
                  label: 'Today’s movement',
                  value: '+₹18,420',
                  detail: 'Market +₹20,920',
                  icon: Icons.trending_up,
                  positive: true),
              SizedBox(width: 12),
              MetricCard(
                  label: 'Net cash flow',
                  value: '-₹2,500',
                  detail: 'Withdrawal today',
                  icon: Icons.swap_vert,
                  positive: false),
            ])),
        const SizedBox(height: 18),
        Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Portfolio performance',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      Text('1Y • XIRR 12.8% • Benchmark 11.2%',
                          style: TextStyle(fontSize: 11)),
                      Sparkline()
                    ]))),
        const SectionHeader('Goals'),
        _GoalTile(
            name: 'Retirement',
            progress: .62,
            value: '₹18.4 L of ₹30 L',
            status: 'On track'),
        const SizedBox(height: 10),
        _GoalTile(
            name: 'Child education',
            progress: .38,
            value: '₹7.6 L of ₹20 L',
            status: 'Review suggested'),
        const SectionHeader('Next SIP'),
        Card(
            child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.autorenew)),
                title: const Text('HDFC Flexi Cap Fund',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: const Text('₹10,000 • 12 Oct 2026'),
                trailing: TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                            builder: (_) => const SipManagementPage())),
                    child: const Text('View')))),
        const SectionHeader('Your advisor'),
        Card(
            child: ListTile(
                leading: const CircleAvatar(child: Text('AN')),
                title: const Text('Ananya Sharma'),
                subtitle: const Text(
                    'Mutual Fund Distributor • Last spoke 3 days ago'),
                trailing: IconButton(
                    onPressed: () => showMessage(context,
                        'Contact request recorded • no message was sent'),
                    icon: const Icon(Icons.chat_outlined)))),
      ]));
}

class _GoalTile extends StatelessWidget {
  const _GoalTile(
      {required this.name,
      required this.progress,
      required this.value,
      required this.status});
  final String name, value, status;
  final double progress;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w800))),
              Text('${(progress * 100).round()}%')
            ]),
            const SizedBox(height: 10),
            LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(9)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(value, style: const TextStyle(fontSize: 12)),
              Text(status,
                  style: TextStyle(
                      fontSize: 11,
                      color: status == 'On track'
                          ? AppColors.success
                          : AppColors.warning,
                      fontWeight: FontWeight.w700))
            ])
          ])));
}

class _OperationsDashboard extends StatelessWidget {
  const _OperationsDashboard();
  @override
  Widget build(BuildContext context) => ScreenBody(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _DashboardHeader(
            title: 'Operations control',
            subtitle: 'Exceptions first. Every number links to lineage.'),
        const SizedBox(height: 16),
        const DemoBanner(),
        const SectionHeader('Today’s processing'),
        SizedBox(
            height: 126,
            child: ListView(scrollDirection: Axis.horizontal, children: const [
              MetricCard(
                  label: 'Imports',
                  value: '14',
                  detail: '12 successful',
                  icon: Icons.move_to_inbox_outlined),
              SizedBox(width: 12),
              MetricCard(
                  label: 'Quarantined',
                  value: '1',
                  detail: 'Review required',
                  icon: Icons.inventory_2_outlined,
                  positive: false),
              SizedBox(width: 12),
              MetricCard(
                  label: 'Reconciliation',
                  value: '12',
                  detail: '3 critical',
                  icon: Icons.rule_outlined),
              SizedBox(width: 12),
              MetricCard(
                  label: 'Missing NAV',
                  value: '7',
                  detail: '2 stale portfolios',
                  icon: Icons.timeline,
                  positive: false)
            ])),
        const SectionHeader('Provider health'),
        ...[
          ('CAMS mailback', 'Healthy', DataStatus.healthy),
          ('KFintech mailback', 'Mapping warning', DataStatus.warning),
          ('NAV feed', 'Fresh 09:37 IST', DataStatus.healthy),
          ('Brokerage feed', 'Expected 18:00', DataStatus.pending)
        ].map((row) => Card(
            child: ListTile(
                leading: const Icon(Icons.hub_outlined),
                title: Text(row.$1),
                trailing: StatusChip(row.$2, row.$3)))),
        const SizedBox(height: 14),
        FilledButton.icon(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                    builder: (_) => const ImportControlPage())),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Open Import Control Centre')),
      ]));
}

class _AdminDashboard extends StatelessWidget {
  const _AdminDashboard();
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return ScreenBody(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _DashboardHeader(
          title: 'Platform governance',
          subtitle: 'Demo tenants, access, providers and security.'),
      const SizedBox(height: 16),
      const DemoBanner(),
      const SectionHeader('System overview'),
      SizedBox(
          height: 126,
          child: ListView(scrollDirection: Axis.horizontal, children: const [
            MetricCard(
                label: 'Tenants',
                value: '12',
                detail: '11 active',
                icon: Icons.business_outlined),
            SizedBox(width: 12),
            MetricCard(
                label: 'Users',
                value: '86',
                detail: '64 active today',
                icon: Icons.manage_accounts_outlined),
            SizedBox(width: 12),
            MetricCard(
                label: 'Sessions',
                value: '42',
                detail: 'All verified',
                icon: Icons.devices_outlined),
            SizedBox(width: 12),
            MetricCard(
                label: 'Security events',
                value: '2',
                detail: 'Low severity',
                icon: Icons.shield_outlined)
          ])),
      const SectionHeader('Governance controls'),
      ...[
        'Role & permission matrix',
        'Provider configuration',
        'Scheme master',
        'Feature flags',
        'Notification templates',
        'Import schedules',
        'Security settings'
      ].map((name) => Card(
          child: ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Local demonstration configuration'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showMessage(context, '$name opened in demo mode')))),
      const SizedBox(height: 16),
      OutlinedButton.icon(
          onPressed: () async {
            if (await confirmAction(context,
                title: 'Reset demo data?',
                message: 'This restores all locally simulated statuses.')) {
              app.resetDemo();
              if (context.mounted)
                showMessage(context, 'Demo data reset successfully');
            }
          },
          icon: const Icon(Icons.restart_alt),
          label: const Text('Reset demo data')),
    ]));
  }
}
