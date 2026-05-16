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
        snapshot: fakePreviewSnapshot(),
        unit: "C",
        showUVRays: false,
        useApparentTemperature: false
    )
}

// Synthetic 24-hour forecast for the widget gallery preview: includes rain,
// snow, and a wide temperature spread in both halves of the day so any visible
// 12-hour window looks varied.
func fakePreviewSnapshot() -> WeatherSnapshot {
    let now = Date()
    var weatherDict: [Date: Weather] = [:]
    var sunriseDict: [NaiveDate: Date] = [:]
    var sunsetDict: [NaiveDate: Date] = [:]

    sunriseDict[now.getNaiveDate()] = now.set(hour: 6, minute: 20)
    sunsetDict[now.getNaiveDate()] = now.set(hour: 19, minute: 30)

    let entries: [(Int, Float, WeatherType, Float, Bool)] = [
        // hour, temp, type, rainMM, isDay
        ( 0,  -5, .snow,        1, false),
        ( 1,  -3, .snow,        1, false),
        ( 2,  -1, .clear,       0, false),
        ( 3,   1, .clear,       0, false),
        ( 4,   3, .lightCloud,  0, false),
        ( 5,   6, .lightCloud,  0, false),
        ( 6,  10, .mainlyClear, 0, true ),
        ( 7,  15, .clear,       0, true ),
        ( 8,  22, .clear,       0, true ),
        ( 9,  26, .lightCloud,  0, true ),
        (10,  28, .rain,        4, true ),
        (11,  25, .rain,        6, true ),
        (12,  24, .rain,        3, true ),
        (13,  23, .lightning,   8, true ),
        (14,  28, .lightCloud,  0, true ),
        (15,  30, .clear,       0, true ),
        (16,  27, .clear,       0, true ),
        (17,  22, .lightCloud,  0, true ),
        (18,  15, .cloud,       0, true ),
        (19,  10, .rain,        2, false),
        (20,   5, .rain,        3, false),
        (21,   0, .snow,        1, false),
        (22,  -3, .snow,        2, false),
        (23,  -6, .snow,        1, false),
    ]
    for (hour, temp, type, rain, isDay) in entries {
        let t = now.set(hour: hour)!
        weatherDict[t] = Weather(time: t, temperature: temp, weatherType: type, rainMillimeter: rain, isDay: isDay, uvIndex: isDay ? 4 : 0)
    }

    return WeatherSnapshot(
        weather: weatherDict,
        sunrise: sunriseDict,
        sunset: sunsetDict,
        utcOffsetSeconds: TimeZone.current.secondsFromGMT(for: now)
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
