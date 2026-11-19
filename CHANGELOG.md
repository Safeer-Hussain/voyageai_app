# Changelog

All notable changes to VoyageAI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2026-11-19

### Added
- Sprint 4: ICAO & EU261 Flight Delay Compensation Eligibility Evaluator.
  - Multi-jurisdictional air passenger rights engine (Regulation EC No 261/2004, UK261, Montreal Convention 1999 Article 19).
  - Great-Circle Haversine distance calculator with offline global airport catalog (LHR, CDG, FRA, AMS, JFK, DXB, etc.).
  - Distance tier statutory compensation matrix (€250 / £220 for <=1500 km, €400 / £350 for 1500-3500 km or intra-EU, €600 / £520 for >3500 km with 50% delay reduction rule).
  - Disruption coverage across arrival delay, cancellation (with 7/14 day thresholds), involuntary denied boarding, and missed connecting flights.
  - Certified extraordinary circumstances evaluation (Force Majeure defense assessment vs airline maintenance carrier fault).
  - Statutory Right to Care advisory checklist (Article 9 meals, refreshments, hotel, transfers, communications).
  - Formal statutory legal claim notice generator with copy-to-clipboard and 14-day statutory reply deadline.
  - Local SQLite persistence for saved flight claims with status tracking (`DRAFT`, `SUBMITTED`, `UNDER_REVIEW`, `SETTLED`, `REJECTED`).
  - Boarding pass integration: 1-tap pre-fill from TravelDocument flight boarding passes in Document Vault.
  - Responsive two-pane master-detail landscape layout for 360dp height displays.
  - Dedicated unit and widget test suite covering Haversine distance, statutory compensation rules, and UI layout.

## [1.0.1] - 2026-11-18

### Added
- Sprint 3: Offline Currency Quick-Reference Cheat-Sheet & Multi-Merchant Tip Calculator.
  - Denomination cheat-sheet matrix across USD, EUR, GBP, JPY, PKR, AED, THB, and CHF.
  - Multi-merchant tip calculator supporting dining, taxi, porterage, and tour guide services.
  - Rounding modes (exact, round up total bill, round up per person) with multi-traveler split calculation.
  - Regional tipping etiquette advisory engine covering 8 global destinations.
  - Street cash exchange rate override with preset FX markup options (+1% to +3%).
  - SQLite persistence for saved conversion snapshots in the trip ledger.
  - Responsive two-pane master-detail landscape layout for 360dp height displays.
  - Dedicated unit and widget test suite covering matrix generation, tip calculation, and UI layout.
- GitHub Actions CI/CD release workflow (`.github/workflows/release.yml`) for automated APK generation and asset publishing on version tags.

## [1.0.0] - 2026-11-17

### Added
- Sprint 1: Interactive Packing Checklist with Weight Estimator & Baggage Allowance Optimizer.
  - Categorized packing checklist (Gear, Clothing, Electronics, Documents, Medical).
  - Dual-unit baggage weight meter with cabin and checked allowance visual warnings.
  - Quick action controls for auto-packing essentials and resetting checklist state.
- Sprint 2: Multi-Timezone Circadian Jetlag Recovery Planner & Sleep Shift Protocol.
  - Dual origin-destination synchronized circadian clock.
  - Directional circadian sleep protocol engine (melatonin timing, light exposure, caffeine cutoff).
  - Hourly sleep shift timeline schedule with phase indicators.
- Core enterprise travel suite architecture:
  - Clean Architecture + MVVM with GetX and GetIt service locator.
  - Multi-city route maps with flutter_map and OpenStreetMap vector tiles.
  - Offline encrypted boarding pass and document vault.
  - Multi-currency trip expense ledger with category charts.
  - Native expedition telemetry sensor bridge for altitude, heading, and barometer.
  - AI travel concierge with streaming responses and resilient fallback.
  - Dynamic Midnight Horizon dark and Crisp Passport light themes.
