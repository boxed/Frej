import Foundation
import CoreLocation

struct SavedLocation: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
    let isGPS: Bool

    init(id: UUID = UUID(), name: String, latitude: Double, longitude: Double, isGPS: Bool = false) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.isGPS = isGPS
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func gpsLocation(name: String, coordinate: CLLocationCoordinate2D) -> SavedLocation {
        SavedLocation(
            name: name,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            isGPS: true
        )
    }
}
