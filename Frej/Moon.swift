import Foundation
import SwiftUI
import CoreLocation

private let moon_bg_color = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
private let moon_slice_color = Color(#colorLiteral(red: 0.7179528061, green: 0.7179528061, blue: 0.7179528061, alpha: 1))
private let moon_maria_color = Color(#colorLiteral(red: 0.6315254227, green: 0.6354416913, blue: 0.6432933126, alpha: 1))
private let moon_dark_maria_color = Color(#colorLiteral(red: 0.2078431373, green: 0.2274509804, blue: 0.2549019608, alpha: 1))

/// Outlines of the near side maria on a unit disc, north up, as seen from Earth. Generated from the LROC global mare
/// boundaries (https://data.lroc.im-ldi.com/lroc/view_rdr/SHAPEFILE_LROC_GLOBAL_MARE): orthographically projected,
/// merged, with small features dropped and the outlines simplified. Drawn as smoothed curves through these points.
private let maria: [[(Double, Double)]] = [
    [(-0.949, 0.228), (-0.916, 0.374), (-0.882, 0.470), (-0.846, 0.512), (-0.836, 0.540), (-0.760, 0.633), (-0.734, 0.650), (-0.678, 0.731), (-0.531, 0.832), (-0.492, 0.813), (-0.431, 0.821), (-0.399, 0.840), (-0.341, 0.848), (-0.316, 0.863), (-0.257, 0.872), (-0.205, 0.892), (-0.148, 0.888), (-0.117, 0.902), (-0.061, 0.861), (-0.033, 0.881), (0.028, 0.882), (0.065, 0.855), (0.098, 0.848), (0.140, 0.855), (0.180, 0.837), (0.236, 0.847), (0.288, 0.845), (0.383, 0.801), (0.389, 0.785), (0.377, 0.757), (0.384, 0.738), (0.427, 0.723), (0.435, 0.702), (0.425, 0.684), (0.389, 0.677), (0.388, 0.652), (0.412, 0.645), (0.440, 0.676), (0.473, 0.669), (0.507, 0.598), (0.546, 0.558), (0.540, 0.539), (0.510, 0.531), (0.492, 0.511), (0.450, 0.524), (0.429, 0.506), (0.443, 0.467), (0.477, 0.434), (0.519, 0.415), (0.528, 0.400), (0.521, 0.379), (0.486, 0.364), (0.484, 0.316), (0.509, 0.305), (0.527, 0.312), (0.537, 0.351), (0.530, 0.379), (0.542, 0.393), (0.564, 0.396), (0.601, 0.375), (0.640, 0.380), (0.648, 0.359), (0.616, 0.283), (0.638, 0.222), (0.677, 0.207), (0.711, 0.164), (0.754, 0.143), (0.790, 0.092), (0.812, 0.082), (0.825, 0.058), (0.841, 0.051), (0.863, 0.059), (0.882, 0.103), (0.870, 0.162), (0.853, 0.174), (0.817, 0.172), (0.740, 0.251), (0.734, 0.358), (0.698, 0.394), (0.691, 0.412), (0.735, 0.460), (0.844, 0.440), (0.901, 0.330), (0.937, 0.324), (0.949, 0.312), (0.976, 0.213), (0.968, 0.198), (0.944, 0.188), (0.937, 0.169), (0.964, 0.135), (0.959, 0.091), (0.997, 0.062), (1.000, 0.014), (0.989, -0.002), (0.953, -0.009), (0.923, -0.039), (0.892, -0.049), (0.873, -0.073), (0.836, -0.079), (0.822, -0.092), (0.829, -0.145), (0.821, -0.208), (0.830, -0.249), (0.852, -0.268), (0.857, -0.290), (0.846, -0.307), (0.786, -0.333), (0.754, -0.381), (0.727, -0.389), (0.699, -0.372), (0.657, -0.372), (0.645, -0.304), (0.627, -0.291), (0.611, -0.298), (0.600, -0.330), (0.579, -0.346), (0.508, -0.365), (0.493, -0.354), (0.472, -0.307), (0.486, -0.256), (0.516, -0.227), (0.521, -0.181), (0.547, -0.172), (0.579, -0.178), (0.602, -0.213), (0.643, -0.229), (0.673, -0.211), (0.671, -0.183), (0.644, -0.151), (0.649, -0.097), (0.663, -0.073), (0.652, -0.047), (0.652, -0.015), (0.630, -0.001), (0.584, 0.002), (0.548, 0.017), (0.510, -0.034), (0.510, -0.084), (0.495, -0.118), (0.479, -0.124), (0.417, -0.112), (0.399, -0.088), (0.421, -0.052), (0.415, -0.030), (0.376, -0.026), (0.356, -0.009), (0.325, -0.006), (0.313, 0.003), (0.296, 0.068), (0.304, 0.126), (0.288, 0.156), (0.253, 0.159), (0.223, 0.190), (0.162, 0.147), (0.114, 0.172), (0.075, 0.153), (0.045, 0.180), (0.012, 0.184), (-0.000, 0.194), (-0.017, 0.259), (-0.005, 0.289), (0.026, 0.324), (0.096, 0.350), (0.131, 0.339), (0.150, 0.352), (0.149, 0.372), (0.121, 0.400), (0.119, 0.453), (0.105, 0.462), (0.059, 0.463), (0.043, 0.513), (0.027, 0.523), (0.005, 0.507), (0.013, 0.478), (0.051, 0.466), (0.061, 0.450), (0.038, 0.418), (0.004, 0.415), (-0.056, 0.479), (-0.128, 0.468), (-0.140, 0.453), (-0.135, 0.420), (-0.091, 0.390), (-0.057, 0.383), (-0.046, 0.357), (-0.119, 0.286), (-0.097, 0.247), (-0.064, 0.226), (-0.060, 0.181), (-0.105, 0.136), (-0.142, 0.128), (-0.149, 0.099), (-0.134, 0.087), (-0.101, 0.094), (-0.040, 0.079), (-0.012, 0.100), (0.036, 0.108), (0.050, 0.094), (0.059, 0.055), (0.054, 0.022), (0.007, -0.010), (-0.008, -0.031), (-0.039, -0.038), (-0.056, -0.073), (-0.101, -0.063), (-0.140, -0.101), (-0.143, -0.139), (-0.124, -0.167), (-0.126, -0.201), (-0.098, -0.219), (-0.090, -0.236), (-0.096, -0.276), (-0.133, -0.319), (-0.092, -0.409), (-0.107, -0.457), (-0.128, -0.476), (-0.171, -0.484), (-0.192, -0.514), (-0.231, -0.525), (-0.261, -0.519), (-0.305, -0.539), (-0.324, -0.562), (-0.387, -0.583), (-0.448, -0.573), (-0.468, -0.520), (-0.489, -0.496), (-0.531, -0.492), (-0.582, -0.527), (-0.614, -0.500), (-0.657, -0.489), (-0.676, -0.435), (-0.656, -0.407), (-0.651, -0.340), (-0.638, -0.325), (-0.606, -0.324), (-0.587, -0.303), (-0.591, -0.247), (-0.635, -0.209), (-0.694, -0.204), (-0.708, -0.222), (-0.692, -0.262), (-0.696, -0.280), (-0.745, -0.294), (-0.759, -0.284), (-0.774, -0.244), (-0.813, -0.218), (-0.863, -0.081), (-0.899, -0.049), (-0.896, -0.023), (-0.910, 0.012), (-0.899, 0.111), (-0.913, 0.161)],
    [(0.179, 0.809), (0.146, 0.794), (0.136, 0.759), (0.118, 0.749), (0.078, 0.766), (0.043, 0.765), (-0.001, 0.818), (-0.052, 0.838), (-0.061, 0.851), (-0.094, 0.831), (-0.100, 0.817), (-0.065, 0.772), (-0.020, 0.767), (-0.003, 0.753), (-0.003, 0.716), (0.022, 0.673), (0.049, 0.661), (0.074, 0.666), (0.090, 0.659), (0.085, 0.608), (0.125, 0.570), (0.140, 0.576), (0.185, 0.631), (0.257, 0.597), (0.274, 0.598), (0.284, 0.612), (0.268, 0.660), (0.288, 0.688), (0.284, 0.719), (0.293, 0.755), (0.279, 0.765), (0.249, 0.765), (0.227, 0.787)],
    [(-0.291, 0.822), (-0.421, 0.772), (-0.465, 0.741), (-0.515, 0.726), (-0.549, 0.659), (-0.546, 0.630), (-0.532, 0.622), (-0.513, 0.625), (-0.497, 0.634), (-0.477, 0.670), (-0.437, 0.674), (-0.396, 0.734), (-0.312, 0.741), (-0.234, 0.774), (-0.233, 0.791), (-0.246, 0.806)],
    [(-0.207, 0.270), (-0.213, 0.233), (-0.197, 0.222), (-0.176, 0.224), (-0.164, 0.244), (-0.172, 0.266), (-0.186, 0.275)],
    [(-0.336, -0.087), (-0.328, -0.131), (-0.303, -0.142), (-0.284, -0.174), (-0.261, -0.172), (-0.249, -0.115), (-0.253, -0.072), (-0.265, -0.054), (-0.299, -0.043)],
    [(-0.405, 0.052), (-0.389, 0.020), (-0.363, 0.021), (-0.356, 0.038), (-0.364, 0.093), (-0.351, 0.104), (-0.317, 0.108), (-0.295, 0.146), (-0.288, 0.192), (-0.315, 0.253), (-0.337, 0.255), (-0.358, 0.239), (-0.368, 0.204), (-0.401, 0.169), (-0.400, 0.143), (-0.369, 0.101), (-0.377, 0.085), (-0.404, 0.073)],
    [(-0.736, 0.444), (-0.713, 0.384), (-0.665, 0.386), (-0.655, 0.411), (-0.663, 0.468), (-0.690, 0.480), (-0.730, 0.460)],
    [(0.454, 0.830), (0.464, 0.853), (0.510, 0.857), (0.566, 0.823), (0.582, 0.801), (0.577, 0.761), (0.631, 0.727), (0.661, 0.694), (0.659, 0.671), (0.598, 0.649), (0.562, 0.669), (0.545, 0.694), (0.542, 0.723), (0.519, 0.739), (0.508, 0.763), (0.484, 0.772), (0.456, 0.800)],
    [(-0.591, -0.563), (-0.581, -0.546), (-0.561, -0.546), (-0.530, -0.569), (-0.529, -0.598), (-0.543, -0.608), (-0.578, -0.609), (-0.588, -0.597)],
]


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

/// Days since J2000 and Julian centuries since J2000.
private func julianTime(_ date: Date) -> (d: Double, t: Double) {
    let d = 2440587.5 + date.timeIntervalSince1970 / 86400 - 2451545
    return (d, d / 36525)
}

private func meanObliquity(t: Double) -> Double { 23.439291 - 0.0130042 * t }

/// Geocentric equatorial position of the sun (km), from Meeus ch. 25 (largest terms only).
private func sunPosition(t: Double) -> Vec3 {
    let sunM = rad(357.52911 + 35999.05029 * t)
    let sunL0 = 280.46646 + 36000.76983 * t
    let sunC = (1.914602 - 0.004817 * t) * sin(sunM) + 0.019993 * sin(2 * sunM) + 0.000289 * sin(3 * sunM)
    let sunDistance = 149597870.7 * (1.00014 - 0.01671 * cos(sunM) - 0.00014 * cos(2 * sunM))
    return equatorial(longitude: sunL0 + sunC, latitude: 0, distance: sunDistance, obliquity: meanObliquity(t: t))
}

/// Unit vector from the earth's center through the observer, which is also the observer's zenith.
private func zenith(d: Double, t: Double, coordinate: CLLocationCoordinate2D) -> Vec3 {
    let localSiderealTime = rad(280.46061837 + 360.98564736629 * d + 0.000387933 * t * t + coordinate.longitude)
    let lat = rad(coordinate.latitude)
    return Vec3(x: cos(lat) * cos(localSiderealTime), y: cos(lat) * sin(localSiderealTime), z: sin(lat))
}

/// Height of the sun above the horizon in degrees, negative when it's below. Ignores refraction.
func sunElevation(date: Date, coordinate: CLLocationCoordinate2D) -> Double {
    let (d, t) = julianTime(date)
    return asin(sunPosition(t: t).normalized.dot(zenith(d: d, t: t, coordinate: coordinate))) * 180 / .pi
}

/// What the moon looks like to an observer at a given moment.
struct MoonAppearance {
    /// Fraction of the disc that is lit, 0 (new) to 1 (full).
    let illuminatedFraction: Double
    /// Direction the lit limb points, in screen radians: 0 is right, positive is clockwise (y down), so -π/2 is up.
    let brightLimbAngle: Double
    /// Direction of the moon's north pole on screen, same convention as `brightLimbAngle`.
    let northAngle: Double

    /// Low precision positions from Meeus, "Astronomical Algorithms", ch. 25 and 47 (largest terms only),
    /// good to a fraction of a degree which is plenty for drawing.
    ///
    /// The orientation is found by projecting the moon→sun direction onto the plane of the sky as seen by the
    /// observer, with the observer's zenith as "up". This is why the lit side often seems not to point at the sun
    /// (the "lunar terminator illusion"): the sun direction follows a great circle, not a straight line on the sky.
    /// Without a coordinate, celestial north is used as up.
    init(date: Date, coordinate: CLLocationCoordinate2D?) {
        let (d, t) = julianTime(date)
        let obliquity = meanObliquity(t: t)
        let sun = sunPosition(t: t)

        // Moon
        let lp = 218.3164477 + 481267.88123421 * t
        let D = rad(297.8501921 + 445267.1114034 * t)
        let M = rad(357.52911 + 35999.05029 * t)
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
            up = zenith(d: d, t: t, coordinate: coordinate)
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

        // The moon's axis is within 1.5° of the ecliptic pole, close enough to orient the maria.
        let e = rad(obliquity)
        let eclipticPole = Vec3(x: 0, y: -sin(e), z: cos(e))
        northAngle = atan2(-eclipticPole.dot(screenUp), eclipticPole.dot(screenRight))
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

struct MoonMaria : Shape {
    let appearance: MoonAppearance

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.origin.x + radius, y: rect.origin.y + radius)

        var p = Path()
        for outline in maria {
            // Quadratic curves between edge midpoints, with the outline points as control points, round off the corners.
            let points = outline.map { CGPoint(x: $0.0 * radius, y: -$0.1 * radius) }
            func midpoint(_ i: Int) -> CGPoint {
                let a = points[i % points.count], b = points[(i + 1) % points.count]
                return CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
            }
            p.move(to: midpoint(0))
            for i in 1...points.count {
                p.addQuadCurve(to: midpoint(i), control: points[i % points.count])
            }
            p.closeSubpath()
        }

        // Maria are laid out with north up (-π/2), turn them to where the moon's north actually is.
        return p.applying(
            CGAffineTransform(rotationAngle: appearance.northAngle + .pi / 2)
                .concatenating(CGAffineTransform(translationX: center.x, y: center.y))
        )
    }
}

struct Moon: View {
    let date: Date
    var coordinate: CLLocationCoordinate2D? = nil

    var body: some View {
        let appearance = MoonAppearance(date: date, coordinate: coordinate)
        ZStack {
            MoonBackground().fill(moon_bg_color)
            MoonMaria(appearance: appearance).fill(moon_dark_maria_color, style: FillStyle(eoFill: true))
            ZStack {
                MoonPhase(appearance: appearance).fill(moon_slice_color)
                MoonMaria(appearance: appearance).fill(moon_maria_color, style: FillStyle(eoFill: true))
            }
            .mask(MoonPhase(appearance: appearance))
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
