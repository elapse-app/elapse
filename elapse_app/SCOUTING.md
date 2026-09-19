# Scouting

## Create a sheet

1. Open **Scout → Start scouting**, or choose **Use template** from the template library.
2. Enter a team number (the placeholder example is **1523W**) and choose the result.
3. Select the event. If needed, sign in and create a group for yourself or join your teammates using their invite code. A group is the shared storage location, not a robot/team being scouted.
4. Tap **Create Scout Sheet**, enter observations, and tap **Save sheet**. The creation flow returns directly to Scout.

Each sheet belongs to one team and one event. Templates define the questions; they are not filled-in sheets. Existing sheets retain their original template.

## Review and compare

Open **Scout → My scout sheets**. Choose **List** or **Table**; the view preference is remembered on this device. The table includes the team, event, template, update date, and answer columns. Scroll horizontally for more columns, and tap a row to open that exact sheet. Long text can be read in the sheet or its tooltip. Blank values show a dash; `false` and `0` remain **No** and **0**.

Sheets load in pages of 25, newest first. **Load more** retrieves the next page. Filtering and team sorting apply to the pages currently loaded. The view contains the selected group's sheets, not only local bookmarks. If event metadata cannot be resolved, its event ID is shown instead.

## Verification

The group, navigation, table, and header regression suite contains 15 passing tests. A full Flutter run on 2026-09-07 passed 41 tests and failed the previously reported legacy-photo deletion regression. That failure and the previously reported Firebase security-rule findings are separate from these usability changes; this is not a production-security sign-off.

The final iOS simulator build succeeded. During manual checking, the existing 10K sheet was saved with a clearly marked test note, and an existing 1523A sheet was reopened without overwriting its answers. Final on-simulator table/restart verification was delayed by simulator boot/install hangs; automated table tests are not a substitute for that remaining check.
