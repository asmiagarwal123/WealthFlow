# WealthFlow

WealthFlow is a mobile-first, UI-only Flutter demonstration of an automation-first operating system for mutual-fund distributors, relationship managers, operations teams, administrators, and clients.

The app uses deterministic fictional data and simulated workflows. It does not connect to an RTA, exchange, bank, mailbox, KYC service, payment system, messaging service, production database, authentication server, or AI API. It never places a real financial transaction and is not investment advice.

## Supported targets

- Android: runner generated and debug APK compiled successfully.
- Web/Chrome: generated and successfully compiled with `flutter build web`.
- iPhone-sized preview: use Chrome responsive mode at 320, 375, 390, and 430 px. Shared Flutter code is platform-neutral.
- Native iOS: not generated or compiled on Windows. Generate/sign on a Mac with Xcode using `flutter create --platforms=ios .`.

## Architecture

```text
lib/
  main.dart
  app/                 # App controller, constants, theme and entry switching
  core/
    models.dart        # Domain-shaped mock entities
    mock_repository.dart
    formatters.dart
    widgets/           # Shared cards, status, charts, dialogs
  features/
    auth/              # Splash, onboarding, login, OTP recovery
    shell/             # Role-aware bottom navigation / desktop rail
    dashboard/         # Distributor, client, operations and admin dashboards
    clients/           # Directory, Client 360 and add-client wizard
    workflows/         # Portfolio, SIP, transactions, goals, proposals, funds
    imports/           # WBR control centre and reconciliation
    modules/           # Action Centre and secondary module workspaces
    ai/                # Deterministic local assistant
```

State is held by `AppController`; presentation reads from `MockRepository` through `AppScope`. Repository interfaces establish a replacement boundary for future APIs.

## Packages

- Flutter Material 3
- `cupertino_icons`
- `flutter_test` and `flutter_lints` for development

No production or networking package is required.

## Setup and run

```powershell
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run -d chrome
```

For Android, start an emulator or connect a device, check its exact ID, then run:

```powershell
flutter devices
flutter run -d YOUR_ACTUAL_DEVICE_ID
```

For iPhone-sized web preview, run Chrome, open DevTools device emulation, and test portrait widths 320, 375, 390, and 430 px.

## Demo accounts

All accounts use password `demo123`.

| Role | Email |
|---|---|
| Distributor | `distributor@demo.com` |
| Relationship Manager | `rm@demo.com` |
| Operations | `ops@demo.com` |
| Administrator | `admin@demo.com` |
| Client | `client@demo.com` |

Mock OTP: `123456`.

## Major working flows

- Splash, four-page onboarding, role selection, fake login, invalid feedback and OTP recovery
- Role-specific bottom navigation and wide-screen navigation rail
- Distributor/client/operations/admin dashboards
- Client search, filter, Client 360 tabs, notes and 10-step add-client wizard
- Portfolio movement split into market movement and cash flow
- Holding details, SIP status changes and transaction order timeline
- Goal creation and proposal/PDF/share simulation
- Fund search, watchlist and compare selection
- Advisor Action Centre with resolve/snooze/dismiss
- Animated CAMS/KFintech WBR scenarios: success, warning and failure
- Reconciliation resolution and audit feedback
- Deterministic local assistant with sources and human-review reminder
- Light/dark theme, mock downloads, loading/empty/error/offline states and demo reset

## Known limitations

- Secondary modules use a reusable interactive workspace pattern rather than unique production-depth screens.
- Onboarding/session preferences are in memory; persistence is intentionally deferred with the backend/session layer.
- Charts are lightweight responsive custom painters rather than production analytics charts.
- No native iOS build can be produced or signed on Windows.
- No Android emulator was connected during verification; the debug APK was compiled but not launched on a device.
- Browser-control screenshots were unavailable because no browser automation connection was present; web compilation and responsive widget tests passed.

## Future integration boundaries

Replace `MockRepository` and `AppController` adapters with authentication/session, client master, transaction/order, RTA ingestion, reconciliation, NAV, document, notification, suitability, audit, reporting, messaging, and governed-assistant services. Keep masking, timestamps, lineage, confirmations and disclaimers in the presentation contract.
