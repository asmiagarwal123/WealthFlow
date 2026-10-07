import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../app/constants.dart';
import '../../core/widgets/app_widgets.dart';
import '../ai/assistant_sheet.dart';
import '../clients/client_pages.dart';
import '../dashboard/dashboard_pages.dart';
import '../imports/import_pages.dart';
import '../modules/module_pages.dart';
import '../workflows/workflow_pages.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _ShellItem {
  const _ShellItem(this.label, this.icon, this.page);
  final String label;
  final IconData icon;
  final Widget page;
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  List<_ShellItem> itemsFor(UserRole role) => switch (role) {
        UserRole.distributor || UserRole.relationshipManager => const [
            _ShellItem('Home', Icons.home_outlined, DashboardPage()),
            _ShellItem('Clients', Icons.people_outline, ClientDirectoryPage()),
            _ShellItem('Actions', Icons.bolt_outlined, ActionCentrePage()),
            _ShellItem('Reports', Icons.bar_chart_outlined,
                ModuleHubPage(initialModule: 'Reports Centre')),
            _ShellItem('More', Icons.grid_view_outlined, MorePage()),
          ],
        UserRole.client => const [
            _ShellItem('Home', Icons.home_outlined, DashboardPage()),
            _ShellItem('Portfolio', Icons.pie_chart_outline, PortfolioPage()),
            _ShellItem(
                'Invest', Icons.add_chart_outlined, TransactionWizardPage()),
            _ShellItem('Goals', Icons.flag_outlined, GoalsPage()),
            _ShellItem('More', Icons.grid_view_outlined, MorePage()),
          ],
        UserRole.operations => const [
            _ShellItem(
                'Overview', Icons.space_dashboard_outlined, DashboardPage()),
            _ShellItem(
                'Imports', Icons.move_to_inbox_outlined, ImportControlPage()),
            _ShellItem('Reconcile', Icons.rule_outlined, ReconciliationPage()),
            _ShellItem(
                'Alerts', Icons.warning_amber_outlined, ActionCentrePage()),
            _ShellItem('More', Icons.grid_view_outlined, MorePage()),
          ],
        UserRole.administrator => const [
            _ShellItem(
                'Overview', Icons.space_dashboard_outlined, DashboardPage()),
            _ShellItem('Users', Icons.manage_accounts_outlined,
                ModuleHubPage(initialModule: 'Users & Roles')),
            _ShellItem('Providers', Icons.hub_outlined,
                ModuleHubPage(initialModule: 'Provider Configuration')),
            _ShellItem('Audit', Icons.history_outlined,
                ModuleHubPage(initialModule: 'Audit Log')),
            _ShellItem('More', Icons.grid_view_outlined, MorePage()),
          ],
      };

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final role = app.activeRole!;
    final items = itemsFor(role);
    if (index >= items.length) index = 0;
    final wide = MediaQuery.sizeOf(context).width >= 840;

    final scaffold = Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(appName, style: TextStyle(fontWeight: FontWeight.w900)),
            Text(role.label,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Theme',
            onPressed: app.toggleTheme,
            icon: Icon(app.themeMode == ThemeMode.dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
          ),
          Badge(
            label: const Text('3'),
            child: IconButton(
              tooltip: 'Notifications',
              onPressed: () => _openPage(
                  context, const ModuleHubPage(initialModule: 'Notifications')),
              icon: const Icon(Icons.notifications_none),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              selectedIndex: index,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (value) => setState(() => index = value),
              destinations: items
                  .map((item) => NavigationRailDestination(
                      icon: Icon(item.icon), label: Text(item.label)))
                  .toList(),
            ),
          Expanded(
              child: IndexedStack(
                  index: index,
                  children: items.map((item) => item.page).toList())),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (value) {
                if ((role == UserRole.distributor ||
                        role == UserRole.relationshipManager) &&
                    value == 2) {
                  _showQuickActions(context);
                }
                setState(() => index = value);
              },
              destinations: items
                  .map((item) => NavigationDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.icon),
                      label: item.label))
                  .toList(),
            ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'assistant',
        tooltip: 'Demo AI assistant',
        onPressed: () => showAssistant(context),
        child: const Icon(Icons.auto_awesome),
      ),
    );
    return PopScope(canPop: false, child: scaffold);
  }

  void _openPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
  }

  void _showQuickActions(BuildContext context) {
    final actions = <(String, IconData, Widget)>[
      ('Add client', Icons.person_add_alt_1, const AddClientWizardPage()),
      ('Start SIP', Icons.autorenew, const SipManagementPage()),
      ('Invest', Icons.trending_up, const TransactionWizardPage()),
      (
        'Redeem',
        Icons.south_west,
        const TransactionWizardPage(initialType: 'Redemption')
      ),
      (
        'Switch',
        Icons.swap_horiz,
        const TransactionWizardPage(initialType: 'Switch')
      ),
      ('Proposal', Icons.description_outlined, const ProposalPage()),
      ('Create goal', Icons.flag_outlined, const GoalsPage(openCreate: true)),
      ('Simulate WBR', Icons.move_to_inbox_outlined, const ImportControlPage()),
    ];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quick actions',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: .9,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8),
                itemCount: actions.length,
                itemBuilder: (_, i) => InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openPage(context, actions[i].$3);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(child: Icon(actions[i].$2)),
                          const SizedBox(height: 7),
                          Text(actions[i].$1,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700))
                        ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final role = app.activeRole!;
    final modules = switch (role) {
      UserRole.distributor || UserRole.relationshipManager => [
          'Families',
          'Portfolios',
          'SIPs',
          'Transactions',
          'Fund Explorer',
          'Goals',
          'Proposals',
          'Risk & Suitability',
          'Brokerage',
          'CRM & Leads',
          'Tasks & Requests',
          'Data Imports',
          'Reconciliation',
          'Notifications',
          'Team Performance',
          'Settings'
        ],
      UserRole.client => [
          'Holdings',
          'SIPs',
          'Transactions',
          'Capital Gains',
          'Documents',
          'Service Requests',
          'Notifications',
          'Profile & Consent',
          'Settings'
        ],
      UserRole.operations => [
          'Scheme Mapping',
          'NAV Monitoring',
          'Transaction Monitoring',
          'Failed Imports',
          'Quarantine',
          'Audit Log',
          'Settings'
        ],
      UserRole.administrator => [
          'Tenants',
          'Roles & Permissions',
          'Branches & RMs',
          'Scheme Master',
          'Feature Flags',
          'System Health',
          'Notification Templates',
          'Import Schedules',
          'Security Settings',
          'Demo Data Reset'
        ],
    };
    return ScreenBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('More',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('${role.label} workspace • all remaining modules'),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.sizeOf(context).width >= 700 ? 4 : 2,
              childAspectRatio: 1.45,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: modules.length,
            itemBuilder: (context, i) => Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _openModule(context, modules[i]),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(_iconFor(modules[i]),
                            color: Theme.of(context).colorScheme.primary),
                        Text(modules[i],
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                        const Align(
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.arrow_forward, size: 17))
                      ]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: Theme.of(context).colorScheme.surface,
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            subtitle: const Text('Ends this local demo session'),
            onTap: () async {
              if (await confirmAction(context,
                  title: 'Log out?',
                  message:
                      'Your mock changes remain only for this app session.'))
                app.logout();
            },
          ),
          const SizedBox(height: 12),
          const DemoBanner(),
        ],
      ),
    );
  }

  void _openModule(BuildContext context, String module) {
    Widget page;
    if (module == 'Data Imports')
      page = const ImportControlPage();
    else if (module == 'Reconciliation')
      page = const ReconciliationPage();
    else if (module == 'SIPs')
      page = const SipManagementPage();
    else if (module == 'Transactions')
      page = const TransactionWizardPage();
    else if (module == 'Goals')
      page = const GoalsPage();
    else if (module == 'Proposals')
      page = const ProposalPage();
    else if (module == 'Fund Explorer')
      page = const FundExplorerPage();
    else if (module == 'Portfolios' || module == 'Holdings')
      page = const PortfolioPage();
    else
      page = ModuleHubPage(initialModule: module);
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
  }

  IconData _iconFor(String name) {
    if (name.contains('SIP')) return Icons.autorenew;
    if (name.contains('Import')) return Icons.move_to_inbox_outlined;
    if (name.contains('Goal')) return Icons.flag_outlined;
    if (name.contains('Setting')) return Icons.settings_outlined;
    if (name.contains('Audit')) return Icons.history;
    if (name.contains('Fund') || name.contains('Scheme')) return Icons.search;
    if (name.contains('Transaction')) return Icons.swap_horiz;
    if (name.contains('Document') || name.contains('Proposal'))
      return Icons.description_outlined;
    return Icons.dashboard_customize_outlined;
  }
}
