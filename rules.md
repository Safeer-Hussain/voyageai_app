# VoyageAI Autonomous Engineering Rules

When the user prompts "run daily sprint" or asks to proceed with backlog development, strictly follow this mandatory 6-phase autonomous workflow:

## Phase 1: Pre-Flight Verification
1. Inspect `docs/AUTONOMOUS_BACKLOG.md` to identify the first unfinished item matching `- [ ] Sprint N: ...`.
2. Verify git status is clean and local branch is synchronized with `origin main`.
3. Check `tool/sprint_gate.dart` exists and can run cleanly.

## Phase 2: Domain Modeling & Architectural Design
1. Adhere strictly to Feature-First Clean Architecture + MVVM:
   - Domain entity & repository contracts in `lib/domain/`.
   - Data models with `fromMap`, `toMap`, `copyWith` and repository implementations in `lib/data/`.
   - Presentation controllers in `lib/presentation/<feature>/controllers/` using GetX (`GetxController`, `RxList`, `Rxn`).
   - UI views and custom widgets in `lib/presentation/<feature>/views/`.
2. NEVER use emojis anywhere in source code, UI strings, debug logs, or commit messages. Use vector Material / Cupertino icons exclusively.
3. NEVER leave `// TODO` placeholders or tutorial comments. Implement 100% functional components.
4. ZERO hardcoded colors. Always resolve via `Theme.of(context).colorScheme`.
5. Ensure every new FAB has an explicit, unique `heroTag`.
6. Ensure 360dp landscape height viewport safety.

## Phase 3: Implementation & Local Storage Binding
1. Wire new features directly into `AppDatabase` (SQLite) or `SharedPreferences`.
2. Provide realistic pre-seeded data or dynamic user generation modal with strict form validation.
3. Handle feedback using `AppFeedback` (`showSuccess`, `showWarning`, `showError`, `showInfo`).

## Phase 4: Automated Testing
1. Add minimum 2 unit tests covering the new controller logic.
2. Add a widget test verifying zero overflows and clean rendering.
3. Ensure total test count only increases and all previous tests pass.

## Phase 5: Sprint Gate Enforcement
1. Execute `dart run tool/sprint_gate.dart`.
2. The gate sequentially runs:
   - `flutter pub get`
   - `dart format lib test tool`
   - `flutter analyze --no-fatal-infos --no-pub`
   - `flutter test --no-pub`
   - Connected physical device check (if available)
3. If any step fails, fix the code immediately and re-run until it exits with code 0.

## Phase 6: Autonomous Commit, Backlog Update & Remote Push
1. In `docs/AUTONOMOUS_BACKLOG.md`, change `- [ ] Sprint N: ...` to `- [x] Sprint N: ...`.
2. Stage all modified and created files (`git add .`).
3. Commit with a conventional semantic message (e.g., `feat(expedition): implement interactive packing checklist and baggage optimizer`).
4. Push to `origin main` (`git push origin main`).
5. Run `git log origin/main..HEAD` and confirm it is completely empty.
