# SquareGPS-TestAPP

### Setup

* Clone this repository.
* Open `SquareGPS-TestApp.xcodeproj` in Xcode 26.2 or later.
* Build or run the app.

### Features
* The application consists of a tracker list, an authentication sheet, and a tracker-details sheet.
* All data is stored using SwiftData. Local data is always available.
* The tracker list supports pull-to-refresh.
* Authentication-related data is stored in the Keychain.
* Automatic sign-off when any request returns HTTP 401. Local data remains available.

### Technical limitations

* Navigation is simplified.
* Dependency management is simplified.
* Networking only supports POST with a non-empty body and response.
* The application will crash if the database fails to initialize.

### Notes (non-obvious behavior)

* **Refresh coalescing**: `TrackerServiceImpl.reloadTrackers()` collapses concurrent refresh calls: if a refresh is already running, later calls await its completion and return the same success/error.
* **Date parsing**: JSON dates are decoded using a small set of ISO8601 variants (with/without fractional seconds, date-only).
