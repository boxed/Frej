import WidgetKit
import SwiftUI

struct FrejEntry: TimelineEntry {
    let date: Date
    let location: SavedLocation?
    let snapshot: WeatherSnapshot?
    let unit: String
    let showUVRays: Bool
    let useApparentTemperature: Bool

    static let placeholder = FrejEntry(
        date: Date(),
        location: nil,
        snapshot: nil,
        unit: "C",
        showUVRays: false,
        useApparentTemperature: false
    )
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
        var entries: [FrejEntry] = []

        // One entry per hour for the next 12 hours so the dial advances.
        for offset in 0..<12 {
            let date = Calendar.current.date(byAdding: .hour, value: offset, to: now) ?? now
            entries.append(currentEntry(at: date))
        }

        // Refresh in ~30 minutes; the app's next fetch will populate fresh data.
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: now) ?? now.addingTimeInterval(1800)
        completion(Timeline(entries: entries, policy: .after(nextRefresh)))
    }

    private func currentEntry(at date: Date) -> FrejEntry {
        let location = SharedStore.allLocations.first
        let snapshot: WeatherSnapshot?
        if let location = location, let data = SharedStore.loadWeatherJSON(for: location.id) {
            snapshot = decodeOpenMeteoResponse(data)
        } else {
            snapshot = nil
        }
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
