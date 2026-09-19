# Firebase production rollout

The repository now owns its Firestore rules, Storage rules, indexes, App Check
client setup, and emulator authorization tests. Do not paste these files into
the Console by hand; deploy the reviewed versions from Git so environments stay
reproducible.

## Safe rollout order

1. Create a separate Firebase staging project and point a non-production build
   at it. Seed representative users, team groups, legacy scout sheets, and
   photos.
2. Publish the app update before tightening production rules. Older app builds
   do not include the `allowJoin == true` join query required by the new rules.
3. Register App Check providers, but leave enforcement **off** initially:
   - iOS bundle `com.elapse.elapse-app`: App Attest with DeviceCheck fallback.
   - Android package `com.elapseapp.elapse_app`: Play Integrity.
   - Add the debug tokens printed by debug builds to the App Check Console.
   - Web and desktop App Check are not activated by this app yet. Do not enforce
     them until a reCAPTCHA provider and desktop strategy are configured.
4. Deploy rules and indexes to staging, complete the group/scouting test flows,
   then deploy them to production.
5. Watch **Security > App Check > APIs**. Enable enforcement for Firestore,
   Storage, and Authentication only after nearly all legitimate traffic is
   verified. Enforcement immediately blocks old clients without valid tokens.

## Deploy configuration

From `elapse_app/` after authenticating the Firebase CLI:

```sh
firebase login
firebase deploy --project elapse --only firestore:rules,firestore:indexes,storage
```

Deploying these targets changes backend authorization and indexes but does not
rewrite existing documents. Review the active Console rules first and save a
copy if production has rules that are not represented in this repository.

## Run authorization tests locally

Requirements: Node.js, Firebase CLI, and Java 21 or newer.

```sh
npm --prefix firebase_rules_tests install
firebase emulators:exec \
  --only firestore,storage \
  --project demo-elapse \
  "npm --prefix firebase_rules_tests test"
```

The `demo-` project name guarantees that these tests cannot contact production.

## Console hardening checklist

- Enable Authentication password policy in notify mode first, then consider
  enforcement after existing users have upgraded their passwords.
- Enable email-enumeration protection and verify the UI handles generalized
  authentication errors.
- Set budget alerts and review Firestore/Storage usage alerts. Budget alerts do
  not cap spending, so also keep quotas and abuse monitoring in place.
- If billing is enabled, turn on Firestore point-in-time recovery for the
  seven-day recovery window and add scheduled backups for longer retention.
- Restrict Firebase/Google API keys by application and API in Google Cloud,
  while remembering that Firebase client keys are identifiers rather than
  server secrets. Authorization still belongs in Rules and App Check.
- Move destructive team administration (recursive group deletion and account
  cleanup) to callable Cloud Functions before the app has large groups. Client
  batches have a 500-write limit and cannot provide reliable recursive cleanup.

## Local persistence

Firestore already uses persistent offline storage by default on Android and
Apple platforms and synchronizes queued writes when connectivity returns. Use a
separate SQLite layer only for app-owned relational data, large local datasets,
or advanced offline queries. Do not duplicate Firestore documents into SQLite
without defining conflict resolution, schema migrations, logout cleanup, and
encryption for sensitive fields.

The custom scout-template library is intentionally small and currently uses
SharedPreferences. That is appropriate for its 25-template limit. Move it to a
Firestore `teamGroups/{groupId}/scoutSheetTemplates` collection if templates
need cross-device or team-wide synchronization; the rules already reserve that
path for group members.
