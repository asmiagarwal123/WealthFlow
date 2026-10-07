# WealthFlow mock-data contract

## Models and relationships

| Model | Important fields | Relationships / future API |
|---|---|---|
| `ClientRecord` | ID, fictional name, masked PAN, AUM, invested value, XIRR, SIP, RM, family, risk, KYC | Parent for portfolio, SIP, goal and transaction endpoints |
| `SipRecord` | ID, client ID, scheme, amount, next date, mutable status | Client and scheme references; future mandate/order adapter |
| `ActionRecord` | type, client, impact, next step, owner, due, severity, resolved | Aggregates compliance, CRM, SIP and operations exceptions |
| `ImportRecord` | provider, filename, counts, status, timestamp, duration | Future mailbox/staging/lineage service |
| `ReconciliationRecord` | type, client, expected/actual, import ID, severity, resolved | Import and client references; future case-management API |
| `SchemeRecord` | AMC, category, risk, NAV, returns, AUM, expense ratio | Future scheme master and NAV APIs |

`MockRepository` implements `WealthRepository`. Presentation code never generates random financial values. Rahul Mehta is consistently represented with ₹32.4 lakh AUM and the same record is used in Client 360 and related views.

## Seeded volumes

- 25 clients
- 5 RMs and 8 family labels
- 8 AMCs and 30 schemes
- 40 mutable SIP records
- 14 imports
- 12 reconciliation cases
- 14 advisor actions

The remaining prototype modules represent holdings, transactions, goals, proposals, brokerage, CRM tasks, requests, notifications and audit history through deterministic UI fixtures. Future expansion should add typed records to this same repository rather than generating values inside widgets.

## Repository operations

- `clients`, `sips`, `actions`, `imports`, `reconciliations`, `schemes`
- `clientById`
- `updateSip`
- `resolveAction`
- `resolveReconciliation`
- `reset`

Future service interfaces should map authentication, session persistence, orders, valuation, statements, reports, messaging and audit separately. Sensitive source fields must remain masked in view models.

## Demonstration states

Healthy, warning, critical, pending, stale and completed status semantics are centralized. Feature screens demonstrate loading, empty, error, offline, failed SIP, KYC review, stale valuation, import warning/failure and reconciliation mismatch states.
