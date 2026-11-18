# Changelog

All notable changes to VoyageAI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1+2] - 2026-11-18

### Added
- Offline Currency Quick-Reference Cheat-Sheet & Multi-Merchant Tip Calculator (Sprint 3).
- Dual-column denomination quick conversion matrix supporting reciprocal mode and bank spread margin adjustment.
- Multi-merchant tipping cockpit with country-specific dining, transit, porter, and hospitality etiquette rules.
- Bill splitting counter (1 to 10 travelers) with nearest integer paper note round-up calculator.
- SQLite offline rate persistence with local calibration sheet for manual exchange rate overrides.
- Entry points in Trip Itinerary header actions and Expense Ledger summary cockpit.
- Comprehensive unit and widget tests for currency entities, controller, and cheat sheet UI.
- Automated release workflow `.github/workflows/release.yml` for automated APK publishing.

## [1.0.0+1] - 2026-11-18

### Added
- Initial enterprise release of VoyageAI.
- Multi-city route map with offline tile caching and interactive waypoints.
- Offline boarding pass and document vault with barcode rendering.
- Multi-currency trip expense ledger with category charts.
- Native expedition sensor suite (altitude, barometer, compass, speed).
- Interactive packing checklist with baggage allowance optimizer (Sprint 1).
- Multi-timezone circadian jetlag recovery planner (Sprint 2).
- Adaptive master-detail layout optimized for 360dp landscape height viewports.
