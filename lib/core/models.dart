enum DataStatus { healthy, warning, critical, stale, pending, completed }

class ClientRecord {
  const ClientRecord({
    required this.id,
    required this.name,
    required this.maskedPan,
    required this.aum,
    required this.invested,
    required this.xirr,
    required this.monthlySip,
    required this.rm,
    required this.family,
    required this.risk,
    required this.kycStatus,
    required this.lastInteraction,
    this.alert,
  });

  final String id;
  final String name;
  final String maskedPan;
  final double aum;
  final double invested;
  final double xirr;
  final double monthlySip;
  final String rm;
  final String family;
  final String risk;
  final String kycStatus;
  final String lastInteraction;
  final String? alert;
}

class SipRecord {
  SipRecord({
    required this.id,
    required this.clientId,
    required this.scheme,
    required this.amount,
    required this.nextDate,
    required this.status,
  });

  final String id;
  final String clientId;
  final String scheme;
  final double amount;
  final String nextDate;
  String status;
}

class ActionRecord {
  ActionRecord({
    required this.id,
    required this.type,
    required this.client,
    required this.problem,
    required this.impact,
    required this.nextStep,
    required this.owner,
    required this.due,
    required this.severity,
    this.resolved = false,
  });

  final String id;
  final String type;
  final String client;
  final String problem;
  final String impact;
  final String nextStep;
  final String owner;
  final String due;
  final DataStatus severity;
  bool resolved;
}

class ImportRecord {
  ImportRecord({
    required this.id,
    required this.provider,
    required this.file,
    required this.records,
    required this.accepted,
    required this.rejected,
    required this.status,
    required this.received,
    required this.duration,
  });

  final String id;
  final String provider;
  final String file;
  final int records;
  final int accepted;
  final int rejected;
  DataStatus status;
  final String received;
  final String duration;
}

class ReconciliationRecord {
  ReconciliationRecord({
    required this.id,
    required this.type,
    required this.client,
    required this.expected,
    required this.actual,
    required this.importId,
    required this.severity,
    this.resolved = false,
  });

  final String id;
  final String type;
  final String client;
  final String expected;
  final String actual;
  final String importId;
  final DataStatus severity;
  bool resolved;
}

class SchemeRecord {
  const SchemeRecord({
    required this.id,
    required this.name,
    required this.amc,
    required this.category,
    required this.risk,
    required this.nav,
    required this.return1y,
    required this.return3y,
    required this.aumCrore,
    required this.expenseRatio,
  });

  final String id;
  final String name;
  final String amc;
  final String category;
  final String risk;
  final double nav;
  final double return1y;
  final double return3y;
  final double aumCrore;
  final double expenseRatio;
}
