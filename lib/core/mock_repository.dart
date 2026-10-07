import 'models.dart';

abstract interface class WealthRepository {
  List<ClientRecord> get clients;
  List<SipRecord> get sips;
  List<ActionRecord> get actions;
  List<ImportRecord> get imports;
  List<ReconciliationRecord> get reconciliations;
  List<SchemeRecord> get schemes;
  void reset();
}

class MockRepository implements WealthRepository {
  MockRepository.seeded() {
    reset();
  }

  static const _names = [
    'Rahul Mehta',
    'Neha Kapoor',
    'Aarav Shah',
    'Priya Nair',
    'Vikram Malhotra',
    'Isha Desai',
    'Kabir Singh',
    'Ananya Rao',
    'Rohan Joshi',
    'Meera Iyer',
    'Arjun Bhatia',
    'Kavya Menon',
    'Dev Patel',
    'Sanya Gupta',
    'Nikhil Jain',
    'Tara Reddy',
    'Aditya Bose',
    'Riya Kulkarni',
    'Kunal Sethi',
    'Pooja Khanna',
    'Siddharth Roy',
    'Aditi Mishra',
    'Varun Pillai',
    'Naina Arora',
    'Yash Verma',
  ];
  static const _rms = ['Ananya', 'Ritesh', 'Maya', 'Karan', 'Devika'];
  static const _amcs = [
    'HDFC',
    'ICICI Prudential',
    'SBI',
    'Axis',
    'Kotak',
    'Nippon India',
    'Mirae Asset',
    'DSP'
  ];
  static const _funds = [
    'Flexi Cap Fund',
    'Balanced Advantage Fund',
    'Corporate Bond Fund',
    'Large & Mid Cap Fund',
    'Liquid Fund'
  ];

  @override
  late List<ClientRecord> clients;
  @override
  late List<SipRecord> sips;
  @override
  late List<ActionRecord> actions;
  @override
  late List<ImportRecord> imports;
  @override
  late List<ReconciliationRecord> reconciliations;
  @override
  late List<SchemeRecord> schemes;

  @override
  void reset() {
    clients = List.generate(25, (i) {
      final aum = i == 0 ? 3240000.0 : 850000.0 + i * 137000;
      return ClientRecord(
        id: 'CL-${1001 + i}',
        name: _names[i],
        maskedPan: 'ABCDE••${20 + i}K',
        aum: aum,
        invested: aum * .82,
        xirr: 8.6 + (i % 8) * .7,
        monthlySip: 5000.0 + (i % 7) * 2500,
        rm: _rms[i % _rms.length],
        family: 'Family ${i % 8 + 1}',
        risk: ['Low', 'Moderate', 'High'][i % 3],
        kycStatus: i % 9 == 0 ? 'Review due' : 'Verified',
        lastInteraction: '${i % 12 + 1} days ago',
        alert: i % 7 == 0 ? 'SIP attention' : null,
      );
    });
    schemes = List.generate(
        30,
        (i) => SchemeRecord(
              id: 'SCH-${2001 + i}',
              name: '${_amcs[i % 8]} ${_funds[i % 5]}',
              amc: _amcs[i % 8],
              category: [
                'Equity',
                'Debt',
                'Hybrid',
                'Solution oriented'
              ][i % 4],
              risk: ['Low', 'Moderate', 'High', 'Very High'][i % 4],
              nav: 18.4 + i * 3.17,
              return1y: 5.2 + (i % 9) * 1.4,
              return3y: 7.8 + (i % 8) * 1.2,
              aumCrore: 920 + i * 264,
              expenseRatio: .32 + (i % 7) * .11,
            ));
    sips = List.generate(
        40,
        (i) => SipRecord(
              id: 'SIP-${3001 + i}',
              clientId: clients[i % clients.length].id,
              scheme: schemes[i % schemes.length].name,
              amount: 2500.0 + (i % 9) * 2500,
              nextDate: '${10 + i % 18} Oct 2026',
              status: i % 13 == 0
                  ? 'Failed'
                  : i % 11 == 0
                      ? 'Paused'
                      : 'Active',
            ));
    actions = List.generate(
        14,
        (i) => ActionRecord(
              id: 'ACT-${4001 + i}',
              type: [
                'Failed SIP',
                'KYC pending',
                'Goal off-track',
                'Reconciliation mismatch',
                'Missing NAV',
                'Review overdue'
              ][i % 6],
              client: clients[i % clients.length].name,
              problem: [
                'Debit rejected by bank',
                'Review evidence missing',
                'Funding is below plan',
                'Units differ from RTA',
                'Valuation is stale',
                'Annual review is due'
              ][i % 6],
              impact: i % 2 == 0
                  ? '₹${12 + i},500 affected'
                  : 'Portfolio data may be incomplete',
              nextStep: [
                'Contact client and retry',
                'Collect updated declaration',
                'Review monthly contribution',
                'Investigate source lineage',
                'Retry NAV mapping',
                'Schedule client review'
              ][i % 6],
              owner: _rms[i % 5],
              due: i < 4 ? 'Today' : '${i - 2} days',
              severity: i % 5 == 0
                  ? DataStatus.critical
                  : i % 2 == 0
                      ? DataStatus.warning
                      : DataStatus.pending,
            ));
    imports = List.generate(
        14,
        (i) => ImportRecord(
              id: 'IMP-${5001 + i}',
              provider: i.isEven ? 'CAMS' : 'KFintech',
              file:
                  'WBR_202610${(7 - i % 7).toString().padLeft(2, '0')}_${i.isEven ? 'CAMS' : 'KFIN'}.zip',
              records: 3800 + i * 71,
              accepted: 3788 + i * 70,
              rejected: i % 5,
              status: i == 2
                  ? DataStatus.warning
                  : i == 9
                      ? DataStatus.critical
                      : DataStatus.completed,
              received:
                  '${7 - i % 7} Oct • 08:${(12 + i).toString().padLeft(2, '0')}',
              duration: '${38 + i}s',
            ));
    reconciliations = List.generate(
        12,
        (i) => ReconciliationRecord(
              id: 'REC-${6001 + i}',
              type: [
                'Unit mismatch',
                'Missing scheme mapping',
                'Duplicate transaction',
                'Provider correction'
              ][i % 4],
              client: clients[i % clients.length].name,
              expected: '${1200 + i * 21}.42 units',
              actual: '${1196 + i * 21}.10 units',
              importId: imports[i % imports.length].id,
              severity: i % 4 == 0 ? DataStatus.critical : DataStatus.warning,
            ));
  }

  ClientRecord clientById(String id) =>
      clients.firstWhere((item) => item.id == id);
  void updateSip(String id, String status) =>
      sips.firstWhere((item) => item.id == id).status = status;
  void resolveAction(String id) =>
      actions.firstWhere((item) => item.id == id).resolved = true;
  void resolveReconciliation(String id) =>
      reconciliations.firstWhere((item) => item.id == id).resolved = true;
}
