# Product Requirements Document (PRD) - VoyageAI Enterprise

## 1. Executive Summary
VoyageAI is an enterprise-grade, offline-first mobile application designed for luxury travel and high-altitude expedition management. It combines on-device generative travel synthesis, multi-city interactive topological route mapping, encrypted offline travel document vaulting, multi-currency ledger tracking, and hardware telemetry streaming (barometric altitude, atmospheric pressure, and compass heading).

## 2. Target Persona & Use Cases
- High-Altitude Expedition Leaders: Requiring zero-connectivity route telemetry, barometric trend monitoring, and emergency SOS broadcasting.
- Luxury International Travelers: Requiring multi-currency expense ledgering, offline boarding pass retrieval with brightness boost, and flight gate status tracking.
- Technical Evaluators: Demanding clean-room architecture, zero emoji hygiene, reactive GetX state management, and 100% test coverage with automated gatekeepers.

## 3. System Architecture & Tech Stack
- Framework: Flutter SDK 3.47+ / Dart 3.13+
- Target SDK: Android SDK 36 (minSdk 21)
- State Management: GetX (Reactive MVVM with `RxList`, `Rxn`, `Obx`, and custom bindings)
- Dependency Injection: `get_it` service locator
- Local Persistence: `sqflite` (SQLite 3.5+) and `shared_preferences`
- Networking: Custom `Dio` mock interceptor with 400-850ms latency simulation and HTTP status code triggers
- Map Canvas: `flutter_map` with `latlong2` vector math (OpenStreetMap zero-billing integration)
- Analytics Visualization: `fl_chart` with full-bleed responsive layouts
- Hardware Bridge: Kotlin & Swift MethodChannels (`com.safeer.voyageai/navigation_sensors`) and EventChannels (`com.safeer.voyageai/expedition_telemetry`)

## 4. Database Schema Specification

### 4.1. Table: `trips`
| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | TEXT | PRIMARY KEY | Unique expedition identifier |
| `title` | TEXT | NOT NULL | Human-readable expedition name |
| `destination` | TEXT | NOT NULL | Target geographic destination |
| `duration_days`| INTEGER | NOT NULL | Total scheduled days |
| `pace` | TEXT | NOT NULL | Travel tempo (Relaxed/Balanced/Packed) |
| `budget_tier` | TEXT | NOT NULL | Financial tier (Backpacker/Explorer/Luxury) |
| `total_budget_usd` | REAL | NOT NULL | Total financial allocation in USD |
| `image_asset` | TEXT | NOT NULL | Bundled horizon asset path |
| `created_at` | INTEGER | NOT NULL | Milliseconds epoch |

### 4.2. Table: `activities`
| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | TEXT | PRIMARY KEY | Activity identifier |
| `trip_id` | TEXT | NOT NULL, FK | Reference to `trips.id` |
| `day_number` | INTEGER | NOT NULL | Day index (1 to N) |
| `time_slot` | TEXT | NOT NULL | Formatted time window (e.g. 08:00 - 10:00) |
| `title` | TEXT | NOT NULL | Activity headline |
| `description`| TEXT | NOT NULL | Tactical notes & instructions |
| `category` | TEXT | NOT NULL | Flight, Hotel, Landmark, Dining, Transit |
| `cost_usd` | REAL | NOT NULL | Projected expense in USD |
| `is_completed`| INTEGER | NOT NULL | Completion flag (0 or 1) |
| `latitude` | REAL | NOT NULL | GPS latitude |
| `longitude`| REAL | NOT NULL | GPS longitude |

### 4.3. Table: `waypoints`
| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | TEXT | PRIMARY KEY | Waypoint identifier |
| `trip_id` | TEXT | NOT NULL, FK | Reference to `trips.id` |
| `day_number` | INTEGER | NOT NULL | Day scheduled |
| `name` | TEXT | NOT NULL | Geographic stop or checkpoint name |
| `latitude` | REAL | NOT NULL | Coordinate latitude |
| `longitude`| REAL | NOT NULL | Coordinate longitude |
| `category` | TEXT | NOT NULL | Category classification |
| `altitude_meters` | REAL | NOT NULL | Elevation in meters AMSL |
| `local_tips` | TEXT | NOT NULL | Route intelligence tip |
| `transit_duration_mins` | INTEGER | NOT NULL | Transit time from prior point |

### 4.4. Table: `documents`
| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | TEXT | PRIMARY KEY | Document identifier |
| `trip_id` | TEXT | NOT NULL, FK | Reference to `trips.id` |
| `type` | TEXT | NOT NULL | Flight, Hotel, Rail, Passport |
| `title` | TEXT | NOT NULL | Document title |
| `origin_iata`| TEXT | NOT NULL | Origin 3-letter IATA code |
| `destination_iata` | TEXT | NOT NULL | Destination 3-letter IATA code |
| `flight_or_booking_number` | TEXT | NOT NULL | Carrier route or reservation code |
| `gate` | TEXT | NOT NULL | Terminal departure gate |
| `seat` | TEXT | NOT NULL | Assigned seat number |
| `boarding_time` | TEXT | NOT NULL | Boarding time string |
| `pnr_code` | TEXT | NOT NULL | 6-character PNR booking reference |
| `carrier_name` | TEXT | NOT NULL | Operating airline or transport authority |
| `qr_payload` | TEXT | NOT NULL | IATA BCBP payload string |
| `notes` | TEXT | NOT NULL | Special service notes |

### 4.5. Table: `expenses`
| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | TEXT | PRIMARY KEY | Expense transaction identifier |
| `trip_id` | TEXT | NOT NULL, FK | Reference to `trips.id` |
| `title` | TEXT | NOT NULL | Merchant or item description |
| `category` | TEXT | NOT NULL | Flights, Stays, Food, Transport, Gear |
| `original_amount` | REAL | NOT NULL | Amount in merchant currency |
| `currency_code` | TEXT | NOT NULL | 3-letter currency (USD, PKR, EUR, etc.) |
| `amount_usd` | REAL | NOT NULL | Normalized base USD amount |
| `split_count` | INTEGER | NOT NULL | Number of travelers splitting cost (1-6) |
| `timestamp` | INTEGER | NOT NULL | Transaction timestamp |

## 5. Non-Functional Requirements
- Visual Safety: Zero hardcoded colors. 100% theme parity between Midnight Horizon Dark and Crisp Passport Light.
- Viewport Safety: Flawless two-pane landscape layout at 800x360 with zero RenderFlex overflow stripes.
- Hero Uniqueness: Guaranteed unique string tags on all FloatingActionButtons across all tabs.
- Keyboard Docking: Zero-gap software keyboard docking using resizeToAvoidBottomInset without double-padding.
