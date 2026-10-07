# WealthFlow UI screen inventory

All data sources below are local `MockRepository` fixtures or deterministic UI fixtures.

| Screen / workspace | Role | Route concept | Major sections and actions | Status |
|---|---|---|---|---|
| Splash | All | `/splash` | Brand, tagline, timed loading | Complete |
| Onboarding (4 pages) | All | `/onboarding` | Skip, next, back, indicators, get started | Complete; persistence deferred |
| Role selection and login | All | `/login` | Five roles, validation, loading, remember UI, one-tap login | Complete |
| OTP/password recovery | All | `/recovery` | Identity, mock OTP 123456, reset confirmation | Complete |
| Distributor dashboard | Distributor/RM | `/distributor/home` | Freshness, metrics, AUM chart, alerts, clients, quick actions | Complete |
| Advisor Action Centre | Distributor/RM/Ops | `/actions` | Category filter, impact, owner, resolve, snooze, dismiss | Complete |
| Client directory | Distributor/RM | `/clients` | Search, chips, advanced filter sheet, sort/view toggle | Complete |
| Add-client wizard | Distributor/RM | `/clients/new` | Ten steps, validation, draft and success | Complete prototype |
| Client 360 | Distributor/RM | `/clients/:id` | Identity, portfolio metrics, 13 tabs, note and quick actions | Complete prototype |
| Families | Distributor/RM | `/families` | Household summary, member and shared-goal cards | Complete shared workspace |
| Portfolio | Distributor/Client | `/portfolio` | Value, cash-flow split, chart, allocation, holdings, intelligence | Complete |
| Holding details | Distributor/Client | `/portfolio/holding/:id` | NAV, value, units, XIRR, performance, actions | Complete |
| SIP management | Distributor/Client | `/sips` | Status filters, pause/modify/retry/contact with confirmation | Complete |
| Transaction wizard | Distributor/Client | `/transactions/new` | Seven-step mock order and timeline | Complete |
| Fund Explorer | Distributor/RM | `/funds` | Search, filters, watchlist, compare, details and invest | Complete prototype |
| Goals | Distributor/Client | `/goals` | Progress cards and four-stage creation sheet | Complete prototype |
| Proposal generator | Distributor/RM | `/proposals/new` | Eight stages, suitability, preview, PDF/share simulation | Complete |
| Risk & suitability | Distributor/RM | `/suitability` | Result, disclaimer, history/action patterns | Complete shared workspace |
| Brokerage | Distributor | `/brokerage` | Gross/net summary, breakdowns and adjustment history | Complete shared workspace |
| CRM & leads | Distributor/RM | `/crm` | Pipeline, follow-ups and stage actions | Complete shared workspace |
| Tasks & service requests | All applicable | `/tasks` | Priority, SLA, status, simulated action | Complete shared workspace |
| Reports Centre | Distributor/RM | `/reports` | Report categories, generation/export feedback and states | Complete shared workspace |
| Import Control Centre | Operations/Distributor | `/operations/imports` | Feeds, ten-stage WBR simulation, scenarios and history | Complete |
| Import detail | Operations | `/operations/imports/:id` | Counts, checksum, parser/schema and lineage | Complete bottom sheet |
| Reconciliation | Operations | `/operations/reconciliation` | Filters, expected/actual, assign/resolve/ignore/escalate | Complete |
| NAV monitoring | Operations | `/operations/nav` | Fresh/stale/missing and action states | Complete shared workspace |
| Scheme mapping | Operations/Admin | `/operations/mappings` | Codes, confidence and simulated actions | Complete shared workspace |
| Operations dashboard | Operations | `/operations/home` | Imports, quarantine, cases, NAV and provider health | Complete |
| Client home | Client | `/client/home` | Wealth, movement split, goals, SIP and advisor | Complete |
| Client secondary modules | Client | `/client/*` | Capital gains, documents, requests, consent and profile | Complete shared workspaces |
| Administrator dashboard | Admin | `/admin/home` | Tenants, users, sessions, security and controls | Complete |
| Admin secondary modules | Admin | `/admin/*` | Users, providers, roles, scheme master, flags and audit | Complete shared workspaces |
| Notifications/communication | All | `/notifications` | Types, status, demo action | Complete shared workspace |
| Demo AI assistant | All | bottom sheet | Suggested prompts, deterministic answer, timestamp and sources | Complete |
| Settings | All | `/settings` | Theme, sessions, privacy, consent, reset/logout | Complete shared workspace |
| Loading/empty/error/offline | All | per module | Retry and visible state feedback | Complete |
| Not found | All | fallback | Back action | Complete |
