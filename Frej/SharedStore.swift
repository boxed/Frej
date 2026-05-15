import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

enum SharedStore {
    static let appGroupID = "group.net.kodare.sunhail"

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    private enum Key {
        static let unit = "widget.unit"
        static let showUVRays = "widget.showUVRays"
        static let useApparentTemperature = "widget.useApparentTemperature"
        static let savedLocations = "widget.savedLocations"
        static let gpsLocation = "widget.gpsLocation"
        static func weatherJSON(_ id: UUID) -> String { "widget.weather.\(id.uuidString)" }
    }

    static func saveSettings(unit: String, showUVRays: Bool, useApparentTemperature: Bool) {
        let d = defaults
        d.set(unit, forKey: Key.unit)
        d.set(showUVRays, forKey: Key.showUVRays)
        d.set(useApparentTemperature, forKey: Key.useApparentTemperature)
    }

    static var unit: String { defaults.string(forKey: Key.unit) ?? "C" }
    static var showUVRays: Bool { defaults.bool(forKey: Key.showUVRays) }
    static var useApparentTemperature: Bool { defaults.bool(forKey: Key.useApparentTemperature) }

    static func saveLocations(_ locations: [SavedLocation]) {
        guard let data = try? JSONEncoder().encode(locations) else { return }
        defaults.set(data, forKey: Key.savedLocations)
    }

    static var savedLocations: [SavedLocation] {
        guard let data = defaults.data(forKey: Key.savedLocations),
              let decoded = try? JSONDecoder().decode([SavedLocation].self, from: data)
        else { return [] }
        return decoded
    }

    static func saveGPSLocation(_ location: SavedLocation?) {
        guard let location = location, let data = try? JSONEncoder().encode(location) else {
            defaults.removeObject(forKey: Key.gpsLocation)
            return
        }
        defaults.set(data, forKey: Key.gpsLocation)
    }

    static var gpsLocation: SavedLocation? {
        guard let data = defaults.data(forKey: Key.gpsLocation),
              let decoded = try? JSONDecoder().decode(SavedLocation.self, from: data)
        else { return nil }
        return decoded
    }

    static var allLocations: [SavedLocation] {
        if let gps = gpsLocation {
            return [gps] + savedLocations
        }
        return savedLocations
    }

    static func saveWeatherJSON(_ data: Data, for locationID: UUID) {
        defaults.set(data, forKey: Key.weatherJSON(locationID))
    }

    static func loadWeatherJSON(for locationID: UUID) -> Data? {
        defaults.data(forKey: Key.weatherJSON(locationID))
    }
}

enum WidgetReloader {
    static func reload() {
        #if canImport(WidgetKit) && !os(watchOS)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}
