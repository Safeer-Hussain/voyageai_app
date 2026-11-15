# VoyageAI - Gemini Engineering Reference & Autonomous Execution Engine

This repository hosts **VoyageAI**, an Enterprise AI-Powered Travel Itinerary Planner, Interactive Multi-City Route Map, Offline Boarding Pass & Document Vault, Multi-Currency Trip Expense Ledger, and Native Expedition Sensor Suite in Flutter.

## Core Mandates
1. Remote: `origin` points to `https://github.com/Safeer-Hussain/voyageai` (or authenticated token remote).
2. Android SDK 36: Explicitly set `compileSdk = 36`, `targetSdk = 36`, and `minSdk = 21` in `android/app/build.gradle.kts`.
3. Architecture: Feature-First Clean Architecture + MVVM (`core/`, `data/`, `domain/`, `presentation/`).
4. State Management: GetX (`get`, `GetxController`, `Obx`) with `get_it` service locator.
5. Storage: Zero external paid services or Firebase; pure local `sqflite` (SQLite 3.5+) and `shared_preferences`.
6. Telemetry: Native Android Kotlin `MainActivity.kt` and iOS Swift `AppDelegate.swift` MethodChannel & EventChannel bridges.
7. Anti-AI Hygiene: ZERO emojis anywhere in code, strings, logs, or commit messages. Vector Material Symbols exclusively. ZERO `// TODO` tutorial placeholders.

## Autonomous Sprint Execution
When prompted "run daily sprint":
- Read `docs/AUTONOMOUS_BACKLOG.md` for the next unfinished sprint `- [ ]`.
- Build the feature cleanly following MVVM + Clean Architecture.
- Add comprehensive unit & widget tests.
- Run `dart run tool/sprint_gate.dart`.
- Mark `- [x]` in `docs/AUTONOMOUS_BACKLOG.md`.
- Commit with conventional commit message and push to `origin main`.
