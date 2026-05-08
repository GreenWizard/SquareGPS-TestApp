# SquareGPS-TestAPP

### Setup

* Clone this repo
* Open SquareGPS-TestApp.xcodeproj in Xcode 26.2+
* Build or Run

### Feautures
* Application consists of Tracker List, Auth pop-up and Tracker details pop-up
* All data is stored using SwiftData. Local data is always available.
* Tracker List supports pull-to-refresh
* Auth related data stored using Keychain
* Authomatic sign off on recieveing 401 on any request. Local data still available to work with.

### Technical limitations
* Navigation is simplified.
* Dependency management is simplified.
* Networking only supports POST with non-empty body and response
* Application will crash if data base fails to initialize

### Notes (non-obvious behavior)
* **Refresh coalescing**: `TrackerServiceImpl.reloadTrackers()` collapses concurrent refresh calls: if a refresh is already running, later calls await its completion and return the same success/error.
* **Date parsing**: JSON dates are decoded using a small set of ISO8601 variants (with/without fractional seconds, date-only).
