import Foundation
import SwiftUI
import CoreLocation

private let moon_bg_color = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
private let moon_slice_color = Color(#colorLiteral(red: 0.7179528061, green: 0.7179528061, blue: 0.7179528061, alpha: 1))

// MARK: - Astronomy

private struct Vec3 {
    var x, y, z: Double

    static func - (a: Vec3, b: Vec3) -> Vec3 { Vec3(x: a.x - b.x, y: a.y - b.y, z: a.z - b.z) }
    static func * (a: Vec3, s: Double) -> Vec3 { Vec3(x: a.x * s, y: a.y * s, z: a.z * s) }
    func dot(_ b: Vec3) -> Double { x * b.x + y * b.y + z * b.z }
    func cross(_ b: Vec3) -> Vec3 { Vec3(x: y * b.z - z * b.y, y: z * b.x - x * b.z, z: x * b.y - y * b.x) }
    var length: Double { sqrt(dot(self)) }
    var normalized: Vec3 { self * (1 / length) }
}

private func rad(_ degrees: Double) -> Double { degrees * .pi / 180 }

/// Ecliptic spherical coordinates (degrees, km) to a geocentric equatorial vector (km).
private func equatorial(longitude: Double, latitude: Double, distance: Double, obliquity: Double) -> Vec3 {
    let l = rad(longitude), b = rad(latitude), e = rad(obliquity)
    let x = cos(b) * cos(l), y = cos(b) * sin(l), z = sin(b)
    return Vec3(x: x, y: y * cos(e) - z * sin(e), z: y * sin(e) + z * cos(e)) * distance
}

/// What the moon looks like to an observer at a given moment.
struct MoonAppearance {
    /// Fraction of the disc that is lit, 0 (new) to 1 (full).
    let illuminatedFraction: Double
    /// Direction the lit limb points, in screen radians: 0 is right, positive is clockwise (y down), so -π/2 is up.
    let brightLimbAngle: Double

    /// Low precision positions from Meeus, "Astronomical Algorithms", ch. 25 and 47 (largest terms only),
    /// good to a fraction of a degree which is plenty for drawing.
    ///
    /// The orientation is found by projecting the moon→sun direction onto the plane of the sky as seen by the
    /// observer, with the observer's zenith as "up". This is why the lit side often seems not to point at the sun
    /// (the "lunar terminator illusion"): the sun direction follows a great circle, not a straight line on the sky.
    /// Without a coordinate, celestial north is used as up.
    init(date: Date, coordinate: CLLocationCoordinate2D?) {
        let jd = 2440587.5 + date.timeIntervalSince1970 / 86400
        let d = jd - 2451545
        let t = d / 36525
        let obliquity = 23.439291 - 0.0130042 * t

        // Sun
        let sunM = rad(357.52911 + 35999.05029 * t)
        let sunL0 = 280.46646 + 36000.76983 * t
        let sunC = (1.914602 - 0.004817 * t) * sin(sunM) + 0.019993 * sin(2 * sunM) + 0.000289 * sin(3 * sunM)
        let sunDistance = 149597870.7 * (1.00014 - 0.01671 * cos(sunM) - 0.00014 * cos(2 * sunM))
        let sun = equatorial(longitude: sunL0 + sunC, latitude: 0, distance: sunDistance, obliquity: obliquity)

        // Moon
        let lp = 218.3164477 + 481267.88123421 * t
        let D = rad(297.8501921 + 445267.1114034 * t)
        let M = sunM
        let Mp = rad(134.9633964 + 477198.8675055 * t)
        let F = rad(93.2720950 + 483202.0175233 * t)
        let E = 1 - 0.002516 * t

        let longitudeTerms: Double =
            6288774 * sin(Mp)
            + 1274027 * sin(2 * D - Mp)
            + 658314 * sin(2 * D)
            + 213618 * sin(2 * Mp)
            - 185116 * E * sin(M)
            - 114332 * sin(2 * F)
            + 58793 * sin(2 * D - 2 * Mp)
            + 57066 * E * sin(2 * D - M - Mp)
            + 53322 * sin(2 * D + Mp)
            + 45758 * E * sin(2 * D - M)
            - 40923 * E * sin(M - Mp)
            - 34720 * sin(D)
            - 30383 * E * sin(M + Mp)
            + 15327 * sin(2 * D - 2 * F)
            - 12528 * sin(Mp + 2 * F)
            + 10980 * sin(Mp - 2 * F)
            + 10675 * sin(4 * D - Mp)
            + 10034 * sin(3 * Mp)
            + 8548 * sin(4 * D - 2 * Mp)
        let latitudeTerms: Double =
            5128122 * sin(F)
            + 280602 * sin(Mp + F)
            + 277693 * sin(Mp - F)
            + 173237 * sin(2 * D - F)
            + 55413 * sin(2 * D - Mp + F)
            + 46271 * sin(2 * D - Mp - F)
            + 32573 * sin(2 * D + F)
            + 17198 * sin(2 * Mp + F)
            + 9266 * sin(2 * D + Mp - F)
            + 8822 * sin(2 * Mp - F)
        let distanceTerms: Double =
            -20905355 * cos(Mp)
            - 3699111 * cos(2 * D - Mp)
            - 2955968 * cos(2 * D)
            - 569925 * cos(2 * Mp)
            + 48888 * E * cos(M)
            - 3149 * cos(2 * F)
            + 246158 * cos(2 * D - 2 * Mp)
            - 152138 * E * cos(2 * D - M - Mp)
            - 170733 * cos(2 * D + Mp)
            - 204586 * E * cos(2 * D - M)
            - 129620 * E * cos(M - Mp)
            + 108743 * cos(D)
            + 104755 * E * cos(M + Mp)
        let moon = equatorial(
            longitude: lp + longitudeTerms / 1e6,
            latitude: latitudeTerms / 1e6,
            distance: 385000.56 + distanceTerms / 1000,
            obliquity: obliquity
        )

        // Observer
        let observer: Vec3
        let up: Vec3
        if let coordinate {
            let localSiderealTime = rad(280.46061837 + 360.98564736629 * d + 0.000387933 * t * t + coordinate.longitude)
            let lat = rad(coordinate.latitude)
            up = Vec3(x: cos(lat) * cos(localSiderealTime), y: cos(lat) * sin(localSiderealTime), z: sin(lat))
            observer = up * 6378.14
        }
        else {
            up = Vec3(x: 0, y: 0, z: 1)
            observer = Vec3(x: 0, y: 0, z: 0)
        }

        let lineOfSight = (moon - observer).normalized
        let moonToSun = (sun - moon).normalized

        let cosPhaseAngle = -lineOfSight.dot(moonToSun)
        illuminatedFraction = (1 + cosPhaseAngle) / 2

        // Screen basis for someone looking at the moon: up is the zenith projected onto the sky, right is line of sight × up.
        let screenUp = (up - lineOfSight * up.dot(lineOfSight)).normalized
        let screenRight = lineOfSight.cross(screenUp)
        brightLimbAngle = atan2(-moonToSun.dot(screenUp), moonToSun.dot(screenRight))
    }
}

// MARK: - Drawing

struct MoonBackground : Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let diameter = Double(min(rect.width, rect.height))
        p.addEllipse(in: CGRect(
            origin: rect.origin, size: CGSize(width: diameter, height: diameter)
        ))
        return p
    }
}

struct MoonPhase : Shape {
    let appearance: MoonAppearance

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.origin.x + radius, y: rect.origin.y + radius)
        // Drawn with the lit limb to the right: the limb is a half circle, the terminator a half ellipse whose
        // horizontal semi-axis goes from +radius (new) through 0 (half) to -radius (full).
        let terminatorWidth = radius * (1 - 2 * appearance.illuminatedFraction)

        var p = Path()
        p.addArc(center: .zero, radius: radius, startAngle: .degrees(90), endAngle: .degrees(-90), clockwise: true)
        let steps = 32
        for i in 1...steps {
            let a = Double.pi * Double(i) / Double(steps)
            p.addLine(to: CGPoint(x: terminatorWidth * sin(a), y: -radius * cos(a)))
        }
        p.closeSubpath()

        return p.applying(
            CGAffineTransform(rotationAngle: appearance.brightLimbAngle)
                .concatenating(CGAffineTransform(translationX: center.x, y: center.y))
        )
    }
}

struct Moon: View {
    let date: Date
    var coordinate: CLLocationCoordinate2D? = nil

    var body: some View {
        ZStack {
            MoonBackground().fill(moon_bg_color)
            MoonPhase(appearance: MoonAppearance(date: date, coordinate: coordinate)).fill(moon_slice_color)
        }
    }
}


struct Previews_Moon_Previews: PreviewProvider {
    static var previews: some View {
        // Sollentuna
        let coordinate = CLLocationCoordinate2D(latitude: 59.41769, longitude: 17.95)

        VStack {
            ForEach(1..<8) { i in
                let date = Date.from(year: 2024, month: 1, day: i * 4).set(hour: 20)!
                Moon(date: date, coordinate: coordinate).frame(width: 100, height: 100)
            }
        }.preferredColorScheme(ColorScheme.dark)
    }
}
