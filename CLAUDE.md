# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Frej is a SwiftUI weather app that renders weather as an artistic clock face: 24 hours of forecast laid out around the dial as colored rays, sun/star fields, clouds, rain, snow, lightning, fog, and wind. Targets iOS, watchOS, and macCatalyst from a single codebase.

Note the naming: the **scheme and bundle target** are still called `SunHail` (legacy name visible in `FrejApp.swift` and `xcodebuild -list`), while the **app, source folder, and product** are `Frej`. Use `-scheme SunHail` for command-line builds.

## Development Commands

The canonical workflow is Xcode (Build/Run/Test/Archive via the IDE). For headless invocation:

```sh
# Build
xcodebuild -project Frej.xcodeproj -scheme SunHail -destination 'generic/platform=iOS' build

# Test (unit + UI)
xcodebuild -project Frej.xcodeproj -scheme SunHail -destination 'platform=iOS Simulator,name=iPhone 15' test

# Run a single test
xcodebuild -project Frej.xcodeproj -scheme SunHail \
    -destination 'platform=iOS Simulator,name=iPhone 15' \
    -only-testing:FrejTests/FrejTests/testExample test

# List schemes/targets/configs
xcodebuild -project Frej.xcodeproj -list
```

Deployment target: iOS 17. Targeted device family: iPhone + iPad (`1,2`).

## Architecture

### Entry point and view tree
`FrejApp.swift` (`@main SunHailApp`) → `ContentView` → `FrejView`. Everything visible is composed inside `FrejView`, which owns all state. There is no separate view-model layer — `FrejView` directly holds weather, sunrise/sunset, location, and UI state as `@State`/`@StateObject`.

### Single-file UI core
`Frej/FrejView.swift` (~1500 lines) contains the bulk of the app: the main `FrejView`, the per-location `Foo` view, and the building blocks `Clock`, `Daylight`, `Night`, `Temperature`, `Rays`, `ColoredRays`, `StarRays`, `Bolt`, `ClockDial`. Visual constants (densities, diameters, color literals) sit at the top of this file as private `let`s — not in a separate config. When tweaking visuals, edit those constants in place.

### Per-location data sharding
The app supports multiple saved locations plus a GPS location, swipeable as vertical pages. State is keyed by `SavedLocation.id` (UUID):

- `weatherByLocation: [UUID: [Date: Weather]]`
- `sunriseByLocation` / `sunsetByLocation: [UUID: [NaiveDate: Date]]`
- `utcOffsetByLocation: [UUID: Int]`
- `lastFetchedByLocation: [UUID: Date]` — drives the 1-hour cache check in `fetchWeatherForLocation`

`allLocations` prepends the GPS location (if available) to `userSettings.savedLocations`; `selectedLocationIndex` indexes into that combined list.

### Persistence
`UserSettings` (an `ObservableObject` defined inline in `FrejView.swift`) is the single persistence layer — it mirrors UserDefaults via `didSet` for `unit`, `hasChosenUnit`, `savedLocations` (JSON-encoded), `selectedLocationIndex`, and `showUVRays`. There is no Core Data, no file storage, no Keychain.

### Weather pipeline
1. `LocationProvider` (third-party, see `LocationProvider-LICENSE`) publishes `CLLocation`.
2. `fetchWeatherForLocation(_:)` builds an Open-Meteo URL, decodes `OMWeatherData` (`OMHourly` + `OMDaily` + `utc_offset_seconds`), checks the 1-hour cache.
3. The Open-Meteo `weathercode` integer is mapped to the local `WeatherType` enum in a `switch` inside the fetch closure (clear/mainlyClear/lightCloud/cloud/rain/snow/lightning/fog). When adding a weather type, the mapping must be updated *and* `Weather.icon()` extended *and* color helpers in `Weather.swift` (`_textColor`, `_iconColor`) extended.
4. `Weather` structs are keyed by `Date` and stored in `weatherByLocation`.

### Visual model
The clock dial maps the 24 forecast hours around 360°. Most shapes (`Sun`, `Cloud`, `Rain`, `Snow`, `Lightning`, `Wind`, `Fog`, `ClearNight`, `SnowClouds`) are custom `Path`-based `Shape`s defined in `Frej/Icons.swift`. Repeated radial elements (sun rays, stars, rain streaks, fog bands) are produced by `Rays`, `ColoredRays`, and `StarRays` parameterized by density, start/end degrees, and wiggle flags. A seeded RNG (`star_field_random_numbers`, top of `FrejView.swift`) keeps the star field stable across redraws.

### Update cycle
A `Timer.publish(every: 10, ...)` in `FrejView` drives a `@State now: Date`. The 10-second cadence is intentional — the clock hand is hour-of-day, not seconds. Don't drop it to e.g. 1s without understanding the redraw cost across all the radial paths. Weather fetches are gated by the 1-hour cache regardless of timer fires.

### WeatherSource modes
`enum WeatherSource { case real, fake, demo }` lets `FrejView` swap in synthetic data via `fakeWeather()` / `demoWeather()` instead of calling Open-Meteo. Useful for screenshots and debugging visuals without waiting for network or for specific weather conditions to occur.

### Platform conditionals
`#if os(iOS)`, `#if os(watchOS)`, `#if targetEnvironment(macCatalyst)` are scattered throughout for layout/sizing differences. Always grep for matching conditionals when changing a piece of UI — watchOS in particular often has tighter line widths and font sizes a few lines below the iOS branch.

## Testing

`FrejTests/FrejTests.swift` and `FrejUITests/FrejlUITests.swift` (note misspelled filename) are essentially empty scaffolding from Xcode templates. There is no real test coverage today; don't assume tests will catch regressions.

## API

Open-Meteo (`https://api.open-meteo.com/v1/forecast`), no auth, called with `timezone=auto&timeformat=unixtime` and `past_days=1`. Requested hourly fields: `temperature_2m, precipitation, weathercode, cloudcover, windspeed_10m, uv_index`. Daily: `sunrise, sunset`. The 1-hour cache is per-location and lives only in memory (`lastFetchedByLocation`) — a fresh launch always re-fetches.
