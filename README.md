# VoyageAI - Enterprise Expedition & Luxury Travel Suite

[![VoyageAI CI](https://github.com/Safeer-Hussain/voyageai_app/actions/workflows/ci.yml/badge.svg)](https://github.com/Safeer-Hussain/voyageai_app/actions/workflows/ci.yml)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.47.8-02569B?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.13.7-0175C2?logo=dart)](https://dart.dev)
[![Android Target SDK](https://img.shields.io/badge/Android%20Target-SDK%2036-3DDC84?logo=android)](https://developer.android.com)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20MVVM-blueviolet)](#system-architecture)

VoyageAI is an enterprise-grade, offline-first mobile application designed for luxury travel management and high-altitude mountain expeditions. Built entirely in Flutter with strict Feature-First Clean Architecture and reactive GetX state management, VoyageAI operates completely standalone without paid external third-party APIs or Firebase dependencies.

---

## Architecture & System Design

VoyageAI enforces a strict separation of concerns across core platform infrastructure, data mapping, business domain logic, and presentation MVVM layers.

```mermaid
graph TD
    subgraph Presentation Layer
        UI[AdaptiveScaffold & Views] -->|Events| CTRL[GetX Controllers]
        CTRL -->|State Streams Rx| UI
    end

    subgraph Domain Layer
        CTRL -->|Executes| UC[Repository Interfaces & Entities]
    end

    subgraph Data Layer
        UC -->|Implemented by| REPO[Repository Implementations]
        REPO -->|Queries| DS[LocalStorageDatasource]
        REPO -->|Invokes| TB[TelemetryBridge]
    end

    subgraph Infrastructure Layer
        DS -->|Reads/Writes| SQL[(SQLite AppDatabase)]
        DS -->|Caches| PREFS[(SharedPreferences)]
        TB -->|MethodChannel| KOTLIN[Native Android Kotlin MainActivity]
        TB -->|EventChannel| SWIFT[Native iOS Swift AppDelegate]
        REPO -->|Simulates Network| DIO[Dio MockNetworkInterceptor]
    end
```

---

## Reactive State Management & GetX Flow

```mermaid
sequenceDiagram
    participant User as Traveler / User
    participant View as Presentation View (Obx)
    participant Ctrl as GetX Controller
    participant Repo as Domain Repository
    participant DB as SQLite AppDatabase

    User->>View: Tap Activity Completion Checkbox
    View->>Ctrl: toggleActivityCompleted(activityId)
    Ctrl->>Ctrl: Mutate RxList with copyWith(isCompleted: !current)
    Ctrl-->>View: Obx Triggers Re-render (0ms UI latency)
    Ctrl->>Repo: toggleActivityCompleted(activityId, isCompleted)
    Repo->>DB: UPDATE activities SET is_completed = 1
    DB-->>Repo: Acknowledged
    Repo-->>Ctrl: Persisted
```

---

## Native Expedition Sensor Bridge Architecture

VoyageAI communicates directly with native hardware sensors through synchronized platform channels, operating even in total isolation without internet connectivity:

```mermaid
sequenceDiagram
    participant DartHUD as TelemetryHudController (Dart)
    participant Channel as EventChannel (expedition_telemetry)
    participant NativeSensor as MainActivity (Kotlin) / AppDelegate (Swift)

    DartHUD->>Channel: listen() to Telemetry Stream
    Channel->>NativeSensor: onListen() Triggered
    loop Every 2000ms
        NativeSensor->>NativeSensor: Sample Barometric Altimeter & Azimuth Gyro
        NativeSensor->>Channel: Emit Map Packet (Alt m/ft, Pressure hPa, Azimuth deg, Temp C, UV)
        Channel-->>DartHUD: TelemetryPacket.fromMap(payload)
        DartHUD-->>DartHUD: Animate Compass Rose & Altimeter Gauge
    end
    DartHUD->>NativeSensor: MethodChannel calibrateAltimeter(referenceAltitude)
    NativeSensor-->>DartHUD: Return Calibrated Offset & Timestamp
```

---

## Core Enterprise Modules

| Module | Architectural Highlights | Capabilities |
|---|---|---|
| **Module 1: AI Multi-Day Itinerary Studio** | `ItineraryController`, SQLite `activities` table, dynamic synthesis engine | Multi-day trip switching, day-selector chips (Day 1..N), category filtering, 1-tap progress tracking, JSON dossier export, clipboard copying. |
| **Module 2: Interactive Route Map** | `flutter_map`, `latlong2`, OpenStreetMap vector tile rendering | Interactive waypoint pins, color-coded route polylines, category filtering, Haversine distance calculator, localized route tips. |
| **Module 3: Document & Boarding Pass Vault** | Perforated cards, `CustomPainter` vector barcode renderer, `DocumentVaultController` | Offline IATA boarding passes (`LHE -> KDU`, `DXB -> HND`), hotel vouchers, high-contrast inspection sheet, brightness boost, PNR reference copy. |
| **Module 4: Multi-Currency Expense Ledger** | `fl_chart`, multi-currency FX converter (`USD`, `PKR`, `EUR`, `JPY`, `AED`), `ExpenseLedgerController` | Real-time budget cockpit, daily safe allowance, multi-traveler cost splitting (1 to 6 people), full-width edge-to-edge category allocation charts. |
| **Module 5: AI Concierge & Expedition HUD** | Asynchronous token streaming, `CompassRosePainter`, native platform channels | Context-aware itinerary reasoning, emergency SOS satellite beacon simulator, altimeter calibration, live barometric pressure telemetry. |

---

## Responsive Landscape Design (360dp Height Viewport Safe)

VoyageAI implements full adaptive responsiveness:
- **Portrait View**: Bottom navigation bar (`NavigationBar`), full-width scrollable vertical cards, floating bottom action buttons.
- **Landscape View**: Left navigation rail (`NavigationRail`) with `minWidth: 56`, compact 36dp toolbar height app bar, two-pane master-detail layout where both left and right panes scroll independently with zero horizontal or vertical `RenderFlex` overflows.

---

## Quality Assurance & Automated Sprint Gate

The repository includes a standalone automated gatekeeper script enforcing clean builds before any commit:

```bash
dart run tool/sprint_gate.dart
```

This sequentially executes:
1. `flutter pub get` (Dependency Resolution)
2. `dart format lib test tool` (Formatting Standards)
3. `flutter analyze --no-fatal-infos --no-pub` (Cross-SDK Static Analysis)
4. `flutter test --no-pub` (Automated Unit & Widget Test Suite)
5. `adb logcat -d` (Connected Device Overflow & Hero Tag Collision Check)

---

## Clean-Room Engineering & NDA Compliance

This repository was authored from scratch in a clean-room development environment. No confidential third-party proprietary source code, internal proprietary endpoints, or private credentials were used. All branding emblems, destination assets, and mock datasets were generated programmatically or via synthetic procedural tools.
