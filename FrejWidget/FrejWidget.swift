import WidgetKit
import SwiftUI

struct FrejEntry: TimelineEntry {
    let date: Date
    let location: SavedLocation?
    let snapshot: WeatherSnapshot?
    let unit: String
    let showUVRays: Bool
    let useApparentTemperature: Bool

    // The placeholder must never show fake weather — when WidgetKit has no real
    // timeline yet it should fall back to the empty/setup state, not demo data.
    static let placeholder = FrejEntry(
        date: Date(),
        location: nil,
        snapshot: nil,
        unit: "C",
        showUVRays: false,
        useApparentTemperature: false
    )
}

// Loads the first location and its decoded weather from the shared App Group
// store the app writes to. Returns nil snapshot when there's no location or no
// decodable weather yet, in which case the view shows the empty/setup state.
func loadSnapshot() -> (SavedLocation?, WeatherSnapshot?) {
    guard let location = SharedStore.allLocations.first,
          let data = SharedStore.loadWeatherJSON(for: location.id),
          let snapshot = decodeOpenMeteoResponse(data) else {
        return (SharedStore.allLocations.first, nil)
    }
    return (location, snapshot)
}

struct FrejProvider: TimelineProvider {
    func placeholder(in context: Context) -> FrejEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (FrejEntry) -> Void) {
        completion(currentEntry(at: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FrejEntry>) -> Void) {
        let now = Date()

        // Decode the shared snapshot once and reuse it for every entry.
        let (location, snapshot) = loadSnapshot()
        let unit = SharedStore.unit
        let showUVRays = SharedStore.showUVRays
        let useApparentTemperature = SharedStore.useApparentTemperature

        // Each entry carries the full ~192-hour snapshot, and WidgetKit
        // serializes EVERY entry when it persists the timeline. On a real
        // device the widget extension has a hard (~30 MB) memory budget, so a
        // large entry count makes that archive too big and the timeline never
        // commits — leaving the widget stuck on the redacted placeholder. (The
        // simulator has no such limit, which is why it renders fine there.)
        // The original working widget used ~12 entries; a 1440-entry timeline
        // broke it. Keep the count modest: one entry every 5 minutes over the
        // 12-hour display window gives smooth-enough hand movement while
        // staying well within the archive budget. `.atEnd` then reloads to pick
        // up fresh weather, and the app nudges an earlier reload on each fetch.
        let stepMinutes = 5
        let windowMinutes = 12 * 60
        var entries: [FrejEntry] = []
        entries.reserveCapacity(windowMinutes / stepMinutes)
        for offset in stride(from: 0, to: windowMinutes, by: stepMinutes) {
            let date = Calendar.current.date(byAdding: .minute, value: offset, to: now) ?? now
            entries.append(FrejEntry(
                date: date,
                location: location,
                snapshot: snapshot,
                unit: unit,
                showUVRays: showUVRays,
                useApparentTemperature: useApparentTemperature
            ))
        }

        // Reload once the window's worth of entries runs out, picking up fresh
        // weather. We also nudge the widget to reload sooner via WidgetCenter
        // whenever the app fetches new data.
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func currentEntry(at date: Date) -> FrejEntry {
        let (location, snapshot) = loadSnapshot()
        return FrejEntry(
            date: date,
            location: location,
            snapshot: snapshot,
            unit: SharedStore.unit,
            showUVRays: SharedStore.showUVRays,
            useApparentTemperature: SharedStore.useApparentTemperature
        )
    }
}

struct FrejWidget: Widget {
    let kind = "FrejWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FrejProvider()) { entry in
            FrejWidgetView(entry: entry)
                .containerBackground(.black, for: .widget)
        }
        .configurationDisplayName("Frej")
        .description("A clock face showing the next 12 hours of weather.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

#Preview(as: .systemSmall) {
    FrejWidget()
} timeline: {
    FrejEntry.placeholder
}

#Preview(as: .systemMedium) {
    FrejWidget()
} timeline: {
    FrejEntry.placeholder
}

#Preview(as: .systemLarge) {
    FrejWidget()
} timeline: {
    FrejEntry.placeholder
}
