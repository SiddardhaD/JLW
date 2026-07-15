# JLW Approvals

A Flutter mobile app for approving or rejecting JD Edwards (JDE) Purchase Orders
and Purchase Requisitions on the go. Built for JLW as an internal enterprise
approvals tool, backed by JDE Orchestrator REST endpoints.

## Features

- **Username/password login** against the JDE token-request API.
- **Biometric sign-in** (Face ID / Touch ID / Android biometrics) — opt-in after
  a successful password login. Credentials are encrypted at rest
  (`flutter_secure_storage`, backed by Android Keystore / iOS Keychain) and
  replayed against the real login API on each biometric unlock, so every
  sign-in gets a fresh token rather than reusing a stale one.
- **Two approval dashboards** picked right after login:
  - **PO Dashboard** — Purchase Order approvals.
  - **PR Dashboard** — Purchase Requisition approvals.
  Both share the same orders/lines/responsible-persons/document APIs; only the
  approve/reject endpoints (and on-screen wording) differ.
- **Order details**: line items awaiting approval, collapsible responsible
  persons list, and all attached order documents (downloaded and rendered as
  PDFs, one viewer per document).
- **Approve / reject workflow** with a confirmation step; rejection requires a
  mandatory comment that's sent to the backend as the rejection note.
- **Session handling**: automatic session-expired detection, and an explicit
  logout that clears the session *and* any saved biometric credentials (no
  biometric prompt after an explicit logout).
- **Global "no internet" banner** — a slim Facebook-style bar pinned to the top
  of every screen, showing offline status and a brief "Back Online" flash on
  reconnect. Backed by a real DNS-reachability check, not just Wi-Fi/adapter
  state.
- **Multi-flavor builds** (dev / staging / prod) with per-flavor API endpoints
  loaded from `.env` files that are never committed to git.

## Tech stack

| Concern              | Package                                            |
|-----------------------|----------------------------------------------------|
| State management      | `provider`                                          |
| HTTP                  | `http`                                              |
| Secure storage         | `flutter_secure_storage`                            |
| Biometrics             | `local_auth`                                        |
| Device identifier      | `android_id` (Android `ANDROID_ID`), `device_info_plus` (iOS `identifierForVendor`) |
| PDF rendering           | `pdfx`                                              |
| PDF generation (legacy/mock) | `pdf`                                         |
| Env config             | `flutter_dotenv`                                    |
| Connectivity           | `connectivity_plus`                                 |
| Sharing                | `share_plus`                                        |

## Project structure

```
lib/
  config/
    flavor_config.dart        # Flavor enum + singleton (dev/staging/prod, base URL)
  constants.dart               # JLWColors — corporate palette
  main.dart                    # App widget + default entry point (defaults to dev)
  main_dev.dart                # Dev flavor entry point
  main_staging.dart            # Staging flavor entry point
  main_prod.dart                # Prod flavor entry point
  models/                      # Request/response DTOs for each JDE endpoint
  network/
    api_config.dart            # Endpoint URLs, built from FlavorConfig.baseUrl
    approvals_api_service.dart # All HTTP calls + response parsing
  providers/
    approvals_provider.dart    # Single ChangeNotifier holding all app state
  screens/
    login_screen.dart          # Password + biometric login
    flow_selection_screen.dart # PO/PR dashboard picker
    dashboard_screen.dart      # Orders list for the active flow
    order_details_screen.dart  # Lines, responsible persons, documents, approve/reject
  services/
    secure_storage_service.dart   # Encrypted session + biometric credential storage
    device_info_service.dart     # Per-device identifier sent to the API as deviceName
    connectivity_service.dart    # Online/offline detection
  widgets/
    network_status_overlay.dart  # Global top banner (wired via MaterialApp.builder)
    order_document_section.dart  # Legacy/unused — superseded by the PDF viewer in order_details_screen
  utils/
    order_pdf_generator.dart     # Legacy/unused — mock PDF generator from an earlier iteration
```

## Environment setup (`.env` files)

API base URLs are kept out of source control. Each flavor loads its own `.env`
file at startup via `flutter_dotenv`:

| Flavor    | File             | Loaded by            |
|-----------|------------------|-----------------------|
| dev       | `.env.dev`       | `main_dev.dart` (and default `main.dart`) |
| staging   | `.env.staging`   | `main_staging.dart`   |
| prod      | `.env.prod`       | `main_prod.dart`      |

These files are **git-ignored**. On a fresh clone, copy `.env.example` to each
of the three filenames and fill in the real `BASE_URL`:

```
cp .env.example .env.dev
cp .env.example .env.staging
cp .env.example .env.prod
```

Each file just needs:

```
BASE_URL=http://your-jde-host/jderest
```

`.env.prod` currently points at the same host as staging with a `TODO` —
update it once the real production endpoint is available.

## Running the app

```bash
flutter pub get

# Dev
flutter run --flavor dev -t lib/main_dev.dart

# Staging
flutter run --flavor staging -t lib/main_staging.dart

# Prod
flutter run --flavor prod -t lib/main_prod.dart
```

Plain `flutter run` (no flags — e.g. an IDE's default "Run" button) falls back
to `lib/main.dart`, which defaults to the dev flavor.

Android product flavors (`dev`/`staging`/`prod`) are configured in
`android/app/build.gradle.kts`. `dev` and `staging` use an
`applicationIdSuffix`, so all three can be installed on the same device at
once for side-by-side testing.

> **iOS flavors**: only the Dart/Android side is wired up. iOS flavor builds
> additionally need matching Xcode schemes/build configurations, which must be
> set up in Xcode on a Mac.

## Building release artifacts

```bash
flutter build apk --flavor prod -t lib/main_prod.dart --release
flutter build appbundle --flavor prod -t lib/main_prod.dart --release
```

## Architecture notes

- **State**: a single `ApprovalsProvider` (`ChangeNotifier`) holds auth state,
  the active `ApprovalFlow` (PO vs PR), orders, line details, responsible
  persons, PDF documents, and biometric preferences. Screens read it via
  `provider`/`context.watch`.
- **Networking**: `ApprovalsApiService` wraps every JDE Orchestrator call.
  Approve/reject calls take an `ApprovalFlow` and route to the matching
  PO or PR endpoint. A `SessionExpiredException` bubbles up on HTTP 401 and
  is handled centrally by the provider to show the session-expired dialog.
  Every request sends a `deviceName` field populated by `DeviceInfoService`
  (a real per-device identifier, not a hardcoded platform string).
- **Security**: session tokens and (if biometrics are enabled) the user's
  username/password are stored via `flutter_secure_storage`, which is
  backed by the Android Keystore / iOS Keychain — not plaintext prefs.
