# Verification report — 2026-09-06

Scope: branch `codex/vex-api-stability`, application source at `802aa06`, with new regression tests. Production Firebase data and rules were not changed.

## Results

- Full Flutter suite including live VEX API: **26 passed, 1 failed**.
- Firestore/Storage emulator suite: **8 passed, 2 failed**. Reproduced both in the workspace and an isolated temporary dependency install.
- Static analysis: **231 informational findings, no errors or warnings**; the default analysis command exits nonzero for these findings.
- iOS debug simulator build: **passed**, followed by installation and launch on iPhone 17 Pro / iOS 26.5. Application `lib` contents in the temporary build copy matched the workspace.
- Simulator UI smoke test: **passed** for startup, live upcoming-event display, opening the template manager, creating a one-field custom template, saving, fully restarting the app, and reopening the persisted template list. `E2E Test Template` remains in simulator-local storage; the built-in default was not changed.
- `git diff --check`: passed.

The live API test covers team search and details, event search, tournament teams/divisions/matches/skills/awards, team awards, and world skills. The emulator lifecycle test covers profile creation, atomic group creation and membership updates, a second member joining, custom sheet persistence and teammate reload, image upload/deletion, admin handoff, access revocation, and final cleanup. It exercises Firebase SDK calls and rules, not the Flutter UI or the application's Database methods. Auth identities are emulator test contexts, not real sign-in sessions.

## Confirmed failures

1. **Deleted legacy photos return after reload.** `ScoutSheetData.fromFirestore` falls back to `properties.Specs.photos` whenever the root photo list is empty, including a migrated document whose photos were explicitly cleared. The new regression expects an empty list but receives `['old-photo']`.
2. **Joinable groups can be enumerated without a join code.** An authenticated outsider can query `teamGroups` with only `allowJoin == true`, retrieving group documents including their join codes and membership data. The negative-access regression unexpectedly succeeds.
3. **An admin can erase unrelated user memberships.** If the admin controls the first group in a user's `groupId` list, the rule allows arbitrary replacement of that whole list. The regression clears both the administered group and an unrelated group, and the write unexpectedly succeeds.

These findings apply to the checked-in rules; deployed production rules were not inspected. The failing tests are deliberately active. No application fixes or production deployments are included in this testing change.

## Reproduce

From `elapse_app` with Flutter, Node, Firebase CLI, and Java 21 available:

```sh
flutter test --dart-define=RUN_LIVE_API_TESTS=true
flutter analyze --no-pub
npm --prefix firebase_rules_tests ci
firebase emulators:exec --only firestore,storage --project demo-elapse "npm --prefix firebase_rules_tests test"
```

`RUN_LIVE_API_TESTS` opts into read-only external requests using the configured token; it does not print the token. Without the opt-in, the live API test is skipped.

## Not established by these checks

Complete UI end-to-end coverage, real email verification/password reset, production Firebase deployment/configuration, release App Check enforcement, push notifications, real camera/photo permissions, offline/concurrent edit recovery, Android builds, physical-device behavior, and performance under load remain unverified. Passing unit and emulator tests alone does not establish production readiness.
