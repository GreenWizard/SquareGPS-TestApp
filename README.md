# SquareGPS-TestAPP

### Setup

* Clone this repository.
* Open `SquareGPS-TestApp.xcodeproj` in Xcode 26.2 or later.
* Build or run the app.

### Features
* The application consists of a tracker list, an authentication sheet, and a tracker details sheet.
* The tracker details sheet includes a map when position data is available.
* All data is stored using SwiftData. Local data is always available.
* The tracker list supports pull-to-refresh.
* Authentication-related data is stored in the Keychain.
* Users are signed out automatically when any request returns HTTP 401. Locally cached data remains available.
* The app continuously polls for tracker positions.

### Technical limitations

* Navigation is simplified.
* Dependency management is simplified.
* Networking only supports POST with a non-empty body and response.
* The application will crash if the database fails to initialize.

### Notes (non-obvious behavior)

* **Refresh coalescing**: `TrackerServiceImpl.reloadTrackers()` collapses concurrent refresh calls: if a refresh is already running, later calls await its completion and receive the same outcome (success or failure).
* **Date parsing**: JSON dates are decoded using a small set of ISO8601 variants (with/without fractional seconds, date-only).
