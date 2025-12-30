import SwiftUI
import CoreLocation
import Combine

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

private let sun_ray_density = 0.6
private let star_density = 0.3
private let rain_density = 0.5
private let fog_density = 1.27
private let circle_inner_diameter = 3.7
private let cloud_ray_density = 0.20
private let cloud_diameter = 3.0
private let cloud_diameter2 = 2.98
private let cloud_wiggle_size = 1.02
private let bolt_diameter = 3.1
private let bolt_diameter2 = 3.7

let dark_cloud_color = Color(#colorLiteral(red: 0.3568909366, green: 0.3843440824, blue: 0.4227784864, alpha: 1))
let dark_cloud_border_offset = 0.05

let snow_color = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
let lightning_color = Color(#colorLiteral(red: 0.9607843161, green: 0.908961656, blue: 0.6438163823, alpha: 1))
let fog_color = Color(#colorLiteral(red: 0.579559949, green: 0.579559949, blue: 0.579559949, alpha: 0.7122568295))

let cold = #colorLiteral(red: 0.308781036, green: 0.6557458493, blue: 1, alpha: 1)
let coldish = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
let hot = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
let warm = #colorLiteral(red: 0.9372549057, green: 0.7610096826, blue: 0.4300234694, alpha: 1)
let warmer = #colorLiteral(red: 0.9372549057, green: 0.5117781247, blue: 0.1694676863, alpha: 1)
let nice = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)


let generator = RandomNumberGeneratorWithSeed(seed: 8927686396)
let star_field_random_numbers = (0...500).map {_ in Double(generator.next()) / Double(UInt64.max)}
let star_field_random_numbers2 = (0...500).map {_ in Double(generator.next()) / Double(UInt64.max)}


func clockPathInner(path: inout Path, bounds: CGRect, progress: TimeInterval, extraSize: CGFloat = 1) {
    let pi = Double.pi
    let position: Double
    position = pi - (2*pi * progress)
    let size = bounds.height / 2
    let x = bounds.midX + CGFloat(sin(position)) * size * extraSize
    let y = bounds.midY + CGFloat(cos(position)) * size * extraSize
    path.move(
        to: CGPoint(
            x: bounds.midX,
            y: bounds.midY
        )
    )
    path.addLine(to: CGPoint(x: x, y: y))
}

func clockPath(now: Date, bounds: CGRect, progress: Double, extraSize: CGFloat) -> Path {
    Path { path in
        clockPathInner(path: &path, bounds: bounds, progress: progress, extraSize: extraSize)
    }
}

struct ClockDial: Shape {
    var now: Date;
    var progress: Double
    var extraSize: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let now: Date = Date();
        return clockPath(now: now, bounds: rect, progress: progress, extraSize: extraSize)
    }
}

extension BinaryInteger {
    var degreesToRadians: CGFloat { CGFloat(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}


let wiggle_c_set: Set = [
    1, 3, 6, 7,
]


struct Rays: Shape {
    let a: CGFloat
    let b: CGFloat
    let ray_density: Double
    var wiggle_a: Bool = false
    var wiggle_b: Bool = false
    var wiggle_c: Bool = false
    var start_degree = 0.0
    var end_degree = 360.0
    var wiggle_size = 1.01

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let degrees = end_degree - start_degree

        let number_of_rays = Int(Double(degrees) * ray_density)

        if number_of_rays < 0 {
            return p
        }

        for i in 0..<number_of_rays {
            let degree = start_degree + CGFloat(i) / ray_density
            var size_a : CGFloat = rect.height/a
            var size_b : CGFloat = rect.height/b
            if wiggle_a && i % 2 == 0 {
                size_a *= wiggle_size
            }
            if wiggle_b && i % 2 == 1 {
                size_b *= wiggle_size
            }
            if wiggle_c && wiggle_c_set.contains(i) {
                size_b *= wiggle_size
            }
            let radians = .pi - degree.degreesToRadians
            let x = sin(radians) * size_a + rect.width / 2
            let y = cos(radians) * size_a + rect.height / 2
            let x2 = sin(radians) * size_b + rect.width / 2
            let y2 = cos(radians) * size_b + rect.height / 2
            p.move(to: CGPoint(x: x, y: y))
            p.addLine(to: CGPoint(x: x2, y: y2))
        }
        return p
    }
}

struct ColoredRays: View {
    let a: CGFloat
    let b: CGFloat
    let ray_density: Double
    var wiggle_a: Bool = false
    var start_degree = 0.0
    var end_degree = 360.0
    var wiggle_size = 1.01

    // Three colors: before (start edge), center, after (end edge)
    var colorBefore: Color = .yellow
    var colorCenter: Color = .yellow
    var colorAfter: Color = .yellow

    // Three line widths: before (start edge), center, after (end edge)
    var lineWidthBefore: CGFloat = 1
    var lineWidthCenter: CGFloat = 1
    var lineWidthAfter: CGFloat = 1

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            let degrees = end_degree - start_degree
            let number_of_rays = Int(Double(degrees) * ray_density)

            if number_of_rays <= 0 { return }

            for i in 0..<number_of_rays {
                let degree = start_degree + CGFloat(i) / ray_density
                var size_a: CGFloat = rect.height / a
                let size_b: CGFloat = rect.height / b
                if wiggle_a && i % 2 == 0 {
                    size_a *= wiggle_size
                }
                let radians = CGFloat.pi - degree.degreesToRadians
                let x = sin(radians) * size_a + rect.width / 2
                let y = cos(radians) * size_a + rect.height / 2
                let x2 = sin(radians) * size_b + rect.width / 2
                let y2 = cos(radians) * size_b + rect.height / 2

                // Calculate color and line width based on position (0 = start, 0.5 = center, 1 = end)
                let progress = Double(i) / Double(max(1, number_of_rays - 1))
                let color: Color
                let lineWidth: CGFloat
                if progress < 0.5 {
                    // Blend from before to center
                    let ratio = progress * 2
                    color = blendColors(colorBefore, colorCenter, ratio: ratio)
                    lineWidth = lineWidthBefore + (lineWidthCenter - lineWidthBefore) * CGFloat(ratio)
                } else {
                    // Blend from center to after
                    let ratio = (progress - 0.5) * 2
                    color = blendColors(colorCenter, colorAfter, ratio: ratio)
                    lineWidth = lineWidthCenter + (lineWidthAfter - lineWidthCenter) * CGFloat(ratio)
                }

                var path = Path()
                path.move(to: CGPoint(x: x, y: y))
                path.addLine(to: CGPoint(x: x2, y: y2))

                context.stroke(path, with: .color(color), lineWidth: lineWidth)
            }
        }
    }
}

struct StarRays: Shape {
    let ray_density: Double
    var start_degree = 0.0
    var end_degree = 360.0
    
    func path(in rect: CGRect) -> Path {
        let a = 2.5
        let b = 3.5

        var p = Path()
        let degrees = end_degree - start_degree

        let number_of_rays = Int(Double(degrees) * ray_density)
        
        if number_of_rays < 0 {
            return p
        }
        
        for i in 0..<number_of_rays {
            let degree = start_degree + CGFloat(i) / ray_density
            let size_a : CGFloat = rect.height/a
            let size_b : CGFloat = rect.height/b
            
            let radians = .pi - degree.degreesToRadians
            let x = sin(radians) * size_a + rect.width / 2
            let y = cos(radians) * size_a + rect.height / 2
            let x2 = sin(radians) * size_b + rect.width / 2
            let y2 = cos(radians) * size_b + rect.height / 2
            
            let r = star_field_random_numbers[i]
            let s = star_field_random_numbers2[i]
            assert(r >= 0 && r <= 1.0)
            
            let sx = x2 + (x - x2) * r
            let sy = y2 + (y - y2) * r

//            p.move(to: CGPoint(x: x, y: y))
//            p.addLine(to: CGPoint(x: x2, y: y2))

            addStar(p: &p, s: 70.0 * s, x: sx, y: sy)
            
//            p.addLine(to: CGPoint(x: x2, y: y2))
        }
        return p
    }
}

struct Bolt: Shape {
    let a: CGFloat
    let b: CGFloat
    var start_degree = 0.0
    var end_degree = 360.0
    
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let degree = (start_degree + end_degree) / 2
    
        let size_a : CGFloat = rect.height/a
        let size_b : CGFloat = rect.height/b
        let size_m = (size_a + size_b)/2
        let radians: CGFloat = .pi - degree.degreesToRadians
        for i in [-0.21, -0.14, -0.07, 0.0, 0.07, 0.14, 0.21] {
            p.move(
                to: CGPoint(
                    x: sin(i + radians + 0.03) * size_a + rect.width / 2,
                    y: cos(i + radians + 0.03) * size_a + rect.height / 2
                )
            )
            p.addLine(
                to: CGPoint(
                    x: sin(i + radians + 0.015) * size_m + rect.width / 2,
                    y: cos(i + radians + 0.015) * size_m + rect.height / 2
                )
            )
            p.addLine(
                to: CGPoint(
                    x: sin(i + radians + 0.04) * size_m * 1.01 + rect.width / 2,
                    y: cos(i + radians + 0.04) * size_m * 1.01 + rect.height / 2
                )
            )
            p.addLine(
                to: CGPoint(
                    x: sin(i + radians + 0.03) * size_b + rect.width / 2,
                    y: cos(i + radians + 0.03) * size_b + rect.height / 2
                )
            )
        }
        return p
    }
}

func createDate(year: Int, month: Int, day: Int, hour: Int) -> Date {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    return components.date!
}

func datetimeToday(hour: Int) -> Date{
    let now = Date()
    var components = Calendar.current.dateComponents([.era, .year, .month, .day, .timeZone, .calendar], from: now)
    components.hour = hour
    components.minute = 0
    components.second = 0
    components.nanosecond = 0
    return components.date!
}

func rainIntensityToLineWidth(_ rain_intensity: RainIntensity) -> Double {
    switch rain_intensity {
        
    case .none:
        return 0
    case .light:
        return 1
    case .moderate:
        return 2
    case .heavy:
        return 3
    case .violent:
        return 5
    }
}

let weekday_number_to_string = [
    1: "Sunday",
    2: "Monday",
    3: "Tuesday",
    4: "Wednesday",
    5: "Thursday",
    6: "Friday",
    7: "Saturday",
]


func datetime_to_degrees(sunrise: Date, sunset: Date, start: Int, utcOffsetSeconds: Int = 0) -> (Double, Double) {
    let myStart = Double(start).truncatingRemainder(dividingBy: 24) - 0.5
    let from = 1/12 * max(0, Double(sunrise.fractionalHour(utcOffsetSeconds: utcOffsetSeconds) - myStart))
    let to = 1/12 * min(11.9, Double(sunset.fractionalHour(utcOffsetSeconds: utcOffsetSeconds) - myStart))
    let x = 360/12.0/2
    return (360 * from - x, 360 * to - x)
}

func uvToLineWidth(_ uvIndex: Float) -> CGFloat {
    // UV index typically ranges 0-11+
    // Scale line width from 0.5 (low UV) to 3 (extreme UV)
    let clamped = min(max(uvIndex, 0), 11)
    return CGFloat(0.5 + clamped * 0.25)
}

func uvToColor(_ uvIndex: Float) -> Color {
    // UV index color scale:
    // 0-5: Yellow (low/moderate)
    // 6-7: Orange (high)
    // 8+: Purple (very high/extreme)
    if uvIndex < 6 {
        return Color.yellow
    } else if uvIndex < 8 {
        return Color.orange
    } else {
        return Color.purple
    }
}

func blendColors(_ c1: Color, _ c2: Color, ratio: Double) -> Color {
    let r = min(1, max(0, ratio))

    let ui1 = UIColor(c1)
    let ui2 = UIColor(c2)

    var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
    var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

    if let srgb1 = ui1.cgColor.converted(to: CGColorSpace(name: CGColorSpace.sRGB)!, intent: .defaultIntent, options: nil) {
        let components1 = srgb1.components ?? [0, 0, 0, 1]
        r1 = components1.count > 0 ? components1[0] : 0
        g1 = components1.count > 1 ? components1[1] : 0
        b1 = components1.count > 2 ? components1[2] : 0
        a1 = components1.count > 3 ? components1[3] : 1
    }

    if let srgb2 = ui2.cgColor.converted(to: CGColorSpace(name: CGColorSpace.sRGB)!, intent: .defaultIntent, options: nil) {
        let components2 = srgb2.components ?? [0, 0, 0, 1]
        r2 = components2.count > 0 ? components2[0] : 0
        g2 = components2.count > 1 ? components2[1] : 0
        b2 = components2.count > 2 ? components2[2] : 0
        a2 = components2.count > 3 ? components2[3] : 1
    }

    let red = r1 + (r2 - r1) * r
    let green = g1 + (g2 - g1) * r
    let blue = b1 + (b2 - b1) * r
    let alpha = a1 + (a2 - a1) * r

    return Color(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(alpha))
}

struct Daylight : View {
    var start : Int
    var sunrise: Date?
    var sunset: Date?
    var weather: [Date: Weather] = [:]
    var showUVRays: Bool = false
    var startOfToday: Date = Date()
    var utcOffsetSeconds: Int = 0

    var body : some View {
        if let sunrise = sunrise, let sunset = sunset {
            let (from, to) = datetime_to_degrees(sunrise: sunrise, sunset: sunset, start: start, utcOffsetSeconds: utcOffsetSeconds)
            if showUVRays {
                // Draw individual rays per hour with UV-based thickness and color fading
                ForEach(0..<12, id: \.self) { id in
                    let startDatetime = startOfToday.addingTimeInterval(TimeInterval((id + start) * 60 * 60))
                    let prevDatetime = startOfToday.addingTimeInterval(TimeInterval((id + start - 1) * 60 * 60))
                    let nextDatetime = startOfToday.addingTimeInterval(TimeInterval((id + start + 1) * 60 * 60))

                    // Compute hour degree range directly from id to avoid timezone issues
                    let k = (id + start) % 12
                    let mid = Double(k * 30)
                    let hourFrom = mid - 15.0
                    let hourTo = mid + 15.0 - (k == 11 ? 2.1 : 0)

                    // Check if this hour overlaps with daylight using degree ranges
                    let isDuringDaylight = hourTo > from && hourFrom < to

                    if let hourWeather = weather[startDatetime], isDuringDaylight {
                        let centerLineWidth = uvToLineWidth(hourWeather.uvIndex)
                        let centerColor = uvToColor(hourWeather.uvIndex)

                        // Get data from adjacent hours
                        let prevWeather = weather[prevDatetime]
                        let nextWeather = weather[nextDatetime]

                        // Check if prev/next hours are during daylight using degree ranges
                        let prevK = (id + start - 1) % 12
                        let prevMid = Double(prevK * 30)
                        let prevHourTo = prevMid + 15.0 - (prevK == 11 ? 2.1 : 0)
                        let prevHourFrom = prevMid - 15.0
                        let prevIsDaylight = prevHourTo > from && prevHourFrom < to

                        let nextK = (id + start + 1) % 12
                        let nextMid = Double(nextK * 30)
                        let nextHourTo = nextMid + 15.0 - (nextK == 11 ? 2.1 : 0)
                        let nextHourFrom = nextMid - 15.0
                        let nextIsDaylight = nextHourTo > from && nextHourFrom < to

                        let prevColor = prevWeather != nil && prevIsDaylight
                            ? uvToColor(prevWeather!.uvIndex)
                            : centerColor
                        let nextColor = nextWeather != nil && nextIsDaylight
                            ? uvToColor(nextWeather!.uvIndex)
                            : centerColor

                        let prevLineWidth = prevWeather != nil && prevIsDaylight
                            ? uvToLineWidth(prevWeather!.uvIndex)
                            : centerLineWidth
                        let nextLineWidth = nextWeather != nil && nextIsDaylight
                            ? uvToLineWidth(nextWeather!.uvIndex)
                            : centerLineWidth

                        // Edge values are the midpoint between this hour and adjacent hours
                        let beforeColor = blendColors(prevColor, centerColor, ratio: 0.5)
                        let afterColor = blendColors(centerColor, nextColor, ratio: 0.5)
                        let beforeLineWidth = (prevLineWidth + centerLineWidth) / 2
                        let afterLineWidth = (centerLineWidth + nextLineWidth) / 2

                        ColoredRays(
                            a: 2.6,
                            b: circle_inner_diameter,
                            ray_density: sun_ray_density,
                            wiggle_a: true,
                            start_degree: hourFrom,
                            end_degree: hourTo,
                            colorBefore: beforeColor,
                            colorCenter: centerColor,
                            colorAfter: afterColor,
                            lineWidthBefore: beforeLineWidth,
                            lineWidthCenter: centerLineWidth,
                            lineWidthAfter: afterLineWidth
                        )
                    }
                }
            } else {
                // Use the same approach as Night - draw rays based on sunrise/sunset degrees
                Rays(a: 2.6, b: circle_inner_diameter, ray_density: sun_ray_density, wiggle_a: true, start_degree: from, end_degree: to)
                    .stroke(Color.yellow, style: StrokeStyle(lineWidth: 1, lineCap: .butt))
            }
        }
        else {
            Text("")
        }
    }
}

struct Night : View {
    var start : Int
    var sunrise: Date?
    var sunset: Date?
    var utcOffsetSeconds: Int = 0

    var body : some View {
        if let sunrise = sunrise, let sunset = sunset {
            let (from, to) = datetime_to_degrees(sunrise: sunrise, sunset: sunset, start: start, utcOffsetSeconds: utcOffsetSeconds)
            if start % 24 == 0 {
                StarRays(ray_density: star_density, start_degree: -15, end_degree: from)
                //.stroke(Color.white, style: StrokeStyle(lineWidth: 1, lineCap: .butt))
                .fill(Color.white)
            }
            else {
                StarRays(ray_density: star_density, start_degree: to, end_degree: 360 - 15)
                //.stroke(Color.white, style: StrokeStyle(lineWidth: 1, lineCap: .butt))
                .fill(Color.white)
            }
        }
        else {
            Text("")
        }
    }
}

func color_from_temperature(_ temp: Float) -> Color {
    if temp < 0 {
        return Color(cold)
    }
    if temp < 20 {
        return Color(coldish)
    }
    if temp > 30 {
        return Color(hot)
    }
    if temp > 26 {
        return Color(warmer)
    }
    if temp > 25 {
        return Color(warm)
    }
    return Color(nice)
}

struct Temperature : View {
    var weather : Weather
    var start : Int
    var frame : CGSize
    let id : Int
    let unit: String
    
    func temperature(weather: Weather) -> Int {
        if unit == "F" {
            return Int(weather.temperature * 9 / 5 + 32)
        }
        else {
            return Int(round(weather.temperature))
        }
    }

    var body : some View {
        let radians : CGFloat = CGFloat.pi - 2.0 * CGFloat.pi / 12.0 * CGFloat(id)
        let size : CGFloat = frame.height * 0.45
        let x: CGFloat = sin(radians) * size + frame.width / 2 - 2
        let y: CGFloat = cos(radians) * size + frame.height / 2 - 2 + 4
        
        #if os(watchOS)
        let iconSize = frame.height / 4.5
        #else
        let iconSize = frame.height / 5.0
        #endif

        let textX = x + 3.0
    
        let font = Font.system(size: iconSize / 3.2)
        let temperature = Text("\(self.temperature(weather: weather))°")
        temperature
            .font(font)
            .position(x: textX, y: y)
            .foregroundColor(color_from_temperature(self.weather.temperature))
    }
}

let hour_slice = 360/12

func hourToStartDegree(hour: Int) -> Int {
    assert(hour >= 0)
    assert(hour <= 24)
    if hour > 12 {
        return hourToStartDegree(hour: hour - 12)
    }
    let x = hour * hour_slice
    return x - hour_slice / 2
}

func hourToEndDegree(hour: Int) -> Int {
    return hourToStartDegree(hour: hour) + hour_slice
}

func rainDegrees(date: Date) -> (Double, Double) {
    let k = date.hour() % 12
    let mid = Double(k * 30)
    let x: Double = k == 11 ? 2.1 : 0
    return (mid - 15.0, mid + 15.0 - x)
}

struct Clock : View {
    var now: Date;
    var startOfToday: Date;
    var showDials: Bool
    var start : Int
    var weather : [Date: Weather]
    let calendar = Calendar.current
    var sunrise : [NaiveDate: Date]
    var sunset : [NaiveDate: Date]
    let unit : String
    var showUVRays : Bool = false
    var utcOffsetSeconds: Int = 0


    var body : some View {
        GeometryReader { (geometry) in
            let frame = geometry.size
            let startTime = startOfToday.addingTimeInterval(TimeInterval(start * 60 * 60))
            let components = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: now)
            let minutes = Double(components.minute!)
            let hour = now.fractionalHour(utcOffsetSeconds: utcOffsetSeconds)
    //        let seconds = Double(components.second!) + Double(components.nanosecond!) / 1_000_000_000.0
            let strokeWidth = frame.height / 70
            let weekday = calendar.dateComponents([.weekday], from: startTime).weekday!
            let weekdayStr: String = start == 0 ? "Today" : start % 24 == 0 ? weekday_number_to_string[weekday]! : ""
            
            let cloud_size: CGFloat = geometry.size.height / 23

            
            ZStack {
                Night(start: start, sunrise: sunrise[startTime.getNaiveDate(utcOffsetSeconds: utcOffsetSeconds)], sunset: sunset[startTime.getNaiveDate(utcOffsetSeconds: utcOffsetSeconds)], utcOffsetSeconds: utcOffsetSeconds)
                Daylight(start: start, sunrise: sunrise[startTime.getNaiveDate(utcOffsetSeconds: utcOffsetSeconds)], sunset: sunset[startTime.getNaiveDate(utcOffsetSeconds: utcOffsetSeconds)], weather: weather, showUVRays: showUVRays, startOfToday: startOfToday, utcOffsetSeconds: utcOffsetSeconds)
                #if !os(watchOS)
                VStack {
                    Text("\(weekdayStr)").frame(maxWidth: .infinity, alignment: .leading)
                    .font(Font.system(size: 10))
                    .padding([.leading, .trailing])
                    .padding(.top, 5)
                    Spacer()
                }
                #endif
                
                ForEach(0..<12, id: \.self) { id in
                    let startDatetime = startOfToday.addingTimeInterval(TimeInterval((id + start) * 60 * 60))
                    if let weather = weather[startDatetime] {
                        let (from, to) = rainDegrees(date: startDatetime)

                        let isNightTime = true
                        // Bool = (
//                        middleOfHour < sunrise[startTime.getNaiveDate()] ?? true
//                        ||
//                        middleOfHour > sunset[startTime.getNaiveDate()] ?? true
//                        middleOfHour > sunset[startTime.getNaiveDate()] ?? true
//                    )
                        
                        if weather.weatherType == .clear && isNightTime {
                            
                        }
                        
                        // Rain
                        
                        let rain  = weather.rainMillimeter > 0 || weather.weatherType == .rain
                        
                        let darkClouds = rain || weather.weatherType == .lightning || weather.weatherType == .cloud
                    
                        if weather.weatherType == .fog {
                            let blur_radius = frame.height / 60
                            Rays(a: cloud_diameter, b: circle_inner_diameter, ray_density: fog_density - 0.5, wiggle_a: true, wiggle_b: true, start_degree: from-1, end_degree: to+1, wiggle_size: 1.02)
                                .stroke(Color.black.opacity(0.7), style: StrokeStyle(lineWidth: 3, lineCap: .butt, dash: [2, ])).blur(radius: blur_radius)
                            Rays(a: cloud_diameter, b: circle_inner_diameter + 1.5, ray_density: fog_density - 0.5, wiggle_a: true, wiggle_b: true, start_degree: from-1, end_degree: to+1)
                                .stroke(fog_color.opacity(0.5), style: StrokeStyle(lineWidth: 4, lineCap: .butt, dash: [2,])).blur(radius: blur_radius)
                            Rays(a: cloud_diameter, b: circle_inner_diameter, ray_density: fog_density, wiggle_a: true, wiggle_b: true, start_degree: from-1, end_degree: to)
                                .stroke(fog_color, style: StrokeStyle(lineWidth: 1, lineCap: .butt, dash: [1, 1])).blur(radius: blur_radius)
                        }

                        if darkClouds {
                            // black anti-rays
                            Rays(a: cloud_diameter, b: circle_inner_diameter, ray_density: sun_ray_density, start_degree: from, end_degree: to )
                                .stroke(Color.black, style: StrokeStyle(lineWidth: min(geometry.size.height/2, geometry.size.width) / 50, lineCap: .round))
                        }
                        if rain {
                            if weather.weatherType == .snow {
                                Rays(a: cloud_diameter, b: circle_inner_diameter, ray_density: rain_density, wiggle_a: true, wiggle_b: true, start_degree: from, end_degree: to)
                                    .stroke(snow_color, style: StrokeStyle(lineWidth: 1, lineCap: .butt, dash: [1, 4, 1, 4]))
                            }
                            else {
                                // rain
                                Rays(a: cloud_diameter, b: circle_inner_diameter, ray_density: rain_density, wiggle_a: true, wiggle_b: true, start_degree: from, end_degree: to)
                                    .stroke(rainColor, style: StrokeStyle(lineWidth: rainIntensityToLineWidth(weather.rainIntensity), lineCap: .butt, dash: [2]))
                            }
                        }
                        
                        if weather.weatherType == .lightning {
                            Bolt(a: bolt_diameter, b: bolt_diameter2, start_degree: from, end_degree: to).stroke(lightning_color)
                        }
                        
                        if !rain && weather.weatherType == .lightCloud  {
                            Rays(a: cloud_diameter - dark_cloud_border_offset, b: cloud_diameter2 - dark_cloud_border_offset, ray_density: cloud_ray_density, wiggle_c: true, start_degree: from + 0.5, end_degree: to + 0.5, wiggle_size: cloud_wiggle_size)
                                .stroke(Color.black, style: StrokeStyle(lineWidth: cloud_size, lineCap: .round))

                            // white clouds
                            Rays(a: cloud_diameter, b: cloud_diameter2, ray_density: cloud_ray_density, wiggle_a: false, wiggle_b: true, start_degree: from + 0.5, end_degree: to + 0.5, wiggle_size: cloud_wiggle_size)
                                .stroke(Color.white, style: StrokeStyle(lineWidth: cloud_size, lineCap: .round))
                        }
                        if darkClouds {
                            Rays(a: cloud_diameter - dark_cloud_border_offset, b: cloud_diameter2 - dark_cloud_border_offset, ray_density: cloud_ray_density, wiggle_c: true, start_degree: from + 0.5, end_degree: to + 0.5, wiggle_size: cloud_wiggle_size)
                                .stroke(Color.black, style: StrokeStyle(lineWidth: cloud_size, lineCap: .round))

                            // dark clouds
                            Rays(a: cloud_diameter, b: cloud_diameter2, ray_density: cloud_ray_density, wiggle_c: true, start_degree: from + 0.5, end_degree: to + 0.5, wiggle_size: cloud_wiggle_size)
                                .stroke(dark_cloud_color, style: StrokeStyle(lineWidth: cloud_size, lineCap: .round))
                        }
                        
//                        if weather.weatherType == .wind {
//                            let time = datetimeToday(hour: id + start)
//                            let hour = Calendar.current.dateComponents([.hour], from: time).hour!
//                            let radians : CGFloat = CGFloat.pi - 2.0 * CGFloat.pi / 12.0 * CGFloat(id)
//                            let size : CGFloat = frame.height * 0.31
//                            let x = sin(radians) * size + frame.width / 2
//                            let y = cos(radians) * size + frame.height / 2
//                            Wind().stroke(Color.black, lineWidth: 44).fill(Color.gray).rotationEffect(Angle.degrees(Double(hour) * 30.0)).scaleEffect(0.07).position(x: x, y: y)
//                        }

                        Temperature(weather: weather, start: start, frame: frame, id: id, unit: unit)
                    }
                }
                // ground, or circle showing the break in the timeline
                Circle()
                    .trim(from: 0.0, to: 0.99)
                    .rotation(Angle.degrees(-105))
                    .fill(Color.black)
                    .stroke(Color.init(white: 0.3), lineWidth: 1)
                    .padding(frame.height * 0.2)
                    .scaleEffect(0.9)
                
                // Hours strings
                ForEach(0..<12, id: \.self) { id in
                    let time = datetimeToday(hour: id + start)
                    let hour = Calendar.current.dateComponents([.hour], from: time).hour!
                    let radians : CGFloat = CGFloat.pi - 2.0 * CGFloat.pi / 12.0 * CGFloat(id)
                    let size : CGFloat = frame.height * 0.225
                    let x = sin(radians) * size + frame.width / 2
                    let y = cos(radians) * size + frame.height / 2
                    Text("\(hour)").position(x: x, y: y)
                    .foregroundColor(Color.init(white: 0.4))
                    .font(Font.system(size: frame.height / 25.0))
                }
                // Hour and minute dials
                if showDials {
                    ClockDial(now: now, progress: hour / 12.0, extraSize: 0.25).stroke(Color.white, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                    ClockDial(now: now, progress: minutes / 60.0, extraSize: 0.45).stroke(Color.white, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                    // second
    //                ClockDial(now: now, progress: seconds / 60.0, extraSize: 0.5).stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                }
            }
            #if os(watchOS)
                .scaleEffect(1.4)
            #endif
        }
    }
}


struct Foo : View {
    let weather : [Date: Weather]
    let height : CGFloat
    let hour : Int
    let now : Date
    let size : CGSize
    var sunrise : [NaiveDate: Date]
    var sunset : [NaiveDate: Date]
    let unit: String
    let coordinate: CLLocationCoordinate2D?
    @Binding var selectedDay: Int
    var showUVRays: Bool = false
    var utcOffsetSeconds: Int = 0

    var body: some View {
        let fractionalHour: Double = now.fractionalHour(utcOffsetSeconds: utcOffsetSeconds)
        let startOfToday = now.startOfDay(utcOffsetSeconds: utcOffsetSeconds)
        GeometryReader { (geometry) in
            TabView(selection: $selectedDay) {
#if os(watchOS)
                ForEach(0..<12, id: \.self) { id in
                    let start1 = 12*id
                    Clock(
                        now: now,
                        startOfToday: startOfToday,
                        showDials: fractionalHour > (start1 - 0.5) && fractionalHour < (start1 + 12 - 0.5),
                        start: start1,
                        weather: weather,
                        sunrise: sunrise,
                        sunset: sunset,
                        unit: unit,
                        showUVRays: showUVRays,
                        utcOffsetSeconds: utcOffsetSeconds
                    )
                    .tag(id)
                }
#else
                ForEach(0..<6, id: \.self) { day in
                    ZStack {
                        HStack {
                            Spacer()
                            let moon_size = min(geometry.size.height/2, geometry.size.width) / 6.0

                            Moon(date: now.addingTimeInterval(TimeInterval(day * 24 * 60 * 60))).frame(width: moon_size, height: moon_size).rotationEffect(Angle(degrees: (coordinate?.latitude ?? 0) - 90)).padding(.trailing, 10).padding([.top, .leading], 20)
                        }

                        VStack {
                            let i: Int = day * 2
                            let start1: Int = 12*i
                            let start2: Int = 12*(i + 1)
                            let start1_d = Double(start1)
                            let start2_d = Double(start2)
                            Clock(
                                now: now,
                                startOfToday: startOfToday,
                                showDials: fractionalHour > (start1_d - 0.5) && fractionalHour < (start1_d + 12 - 0.5),
                                start: start1,
                                weather: weather,
                                sunrise: sunrise,
                                sunset: sunset,
                                unit: unit,
                                showUVRays: showUVRays,
                                utcOffsetSeconds: utcOffsetSeconds
                            ).frame(height: height)
                            Clock(
                                now: now,
                                startOfToday: startOfToday,
                                showDials: fractionalHour > (start2_d - 0.5) && fractionalHour < (start2_d + 12 - 0.5),
                                start: start2,
                                weather: weather,
                                sunrise: sunrise,
                                sunset: sunset,
                                unit: unit,
                                showUVRays: showUVRays,
                                utcOffsetSeconds: utcOffsetSeconds
                            ).frame(height: height)
                        }
                    }
                    .tag(day)
                }
#endif
            }
            #if targetEnvironment(macCatalyst)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            #else
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            #endif
            .frame(width: size.width, height: size.height)
        }
    }
}

class UserSettings: ObservableObject {
    @Published var hasChosenUnit: Bool {
        didSet {
            UserDefaults.standard.set(hasChosenUnit, forKey: "hasChosenUnit")
        }
    }

    @Published var unit: String {
        didSet {
            UserDefaults.standard.set(unit, forKey: "unit")
        }
    }

    @Published var savedLocations: [SavedLocation] {
        didSet {
            if let encoded = try? JSONEncoder().encode(savedLocations) {
                UserDefaults.standard.set(encoded, forKey: "savedLocations")
            }
        }
    }

    @Published var selectedLocationIndex: Int {
        didSet {
            UserDefaults.standard.set(selectedLocationIndex, forKey: "selectedLocationIndex")
        }
    }

    @Published var showUVRays: Bool {
        didSet {
            UserDefaults.standard.set(showUVRays, forKey: "showUVRays")
        }
    }

    init() {
        self.hasChosenUnit = UserDefaults.standard.bool(forKey: "hasChosenUnit")
        self.unit = UserDefaults.standard.string(forKey: "unit") ?? "C"
        self.selectedLocationIndex = UserDefaults.standard.integer(forKey: "selectedLocationIndex")
        self.showUVRays = UserDefaults.standard.bool(forKey: "showUVRays")

        if let data = UserDefaults.standard.data(forKey: "savedLocations"),
           let decoded = try? JSONDecoder().decode([SavedLocation].self, from: data) {
            self.savedLocations = decoded
        } else {
            self.savedLocations = []
        }
    }
}

enum WeatherSource {
    case real
    case fake
    case demo
}

struct FrejView: View {
    @State var now: Date = Date()
    @StateObject var locationProvider = LocationProvider()
    @State var coordinate: CLLocationCoordinate2D?
    @State var weatherByLocation: [UUID: [Date: Weather]] = [:]
    @State var sunriseByLocation: [UUID: [NaiveDate: Date]] = [:]
    @State var sunsetByLocation: [UUID: [NaiveDate: Date]] = [:]
    @State var utcOffsetByLocation: [UUID: Int] = [:]
    @State var lastFetchedByLocation: [UUID: Date] = [:]
    @State var cancellableLocation: AnyCancellable?
    @State var loadedURL: String = ""
    @State var timeOfData: Date = Date.init(timeIntervalSince1970: 0)
    @State var currentLocation: String = ""
    @State var showUnitChooser = false
    @State var showSettings = false
    @State var gpsLocation: SavedLocation?
    @State var dragOffset: CGFloat = 0
    @State var selectedDay: Int = 0
    @ObservedObject var userSettings = UserSettings()
    @State var weatherSource: WeatherSource = .real

    var allLocations: [SavedLocation] {
        if let gps = gpsLocation {
            return [gps] + userSettings.savedLocations
        }
        return userSettings.savedLocations
    }

    var currentLocationData: SavedLocation? {
        let index = userSettings.selectedLocationIndex
        guard index >= 0 && index < allLocations.count else {
            return allLocations.first
        }
        return allLocations[index]
    }

    func weatherForLocation(_ id: UUID) -> [Date: Weather] {
        weatherByLocation[id] ?? [:]
    }

    func sunriseForLocation(_ id: UUID) -> [NaiveDate: Date] {
        sunriseByLocation[id] ?? [:]
    }

    func sunsetForLocation(_ id: UUID) -> [NaiveDate: Date] {
        sunsetByLocation[id] ?? [:]
    }

    func utcOffsetForLocation(_ id: UUID) -> Int {
        utcOffsetByLocation[id] ?? 0
    }

    let timer = Timer.publish(
        // seconds
        every: 10, // 0.05 to get a smooth second counter
        on: .main,
        in: .common
    ).autoconnect()
        // .background(Rectangle().fill(Color.black))
    var body: some View {
        if showUnitChooser {
            VStack {
                Button(action: {
                    userSettings.unit = "C"
                    userSettings.hasChosenUnit = true
                    showUnitChooser = false
                }) {
                    Text("Celsius").font(Font.system(size: 40)).padding()
                }
                Button(action: {
                    userSettings.unit = "F"
                    userSettings.hasChosenUnit = true
                    showUnitChooser = false
                }) {
                    Text("Fahrenheit").font(Font.system(size: 40))
                }
            }.preferredColorScheme(ColorScheme.dark)
        }
        else {
            let calendar = Calendar.current
            let components = calendar.dateComponents([Calendar.Component.hour], from: now)
            let hour = components.hour!

            ZStack {
                VStack(spacing: 0) {
                    GeometryReader { (geometry) in
                        let size = geometry.size
                        let height = min(size.width * 0.9, abs(size.height / 2 - 25))

                        if allLocations.count > 1 {
                            let currentIndex = userSettings.selectedLocationIndex
                            let screenHeight = size.height

                            ZStack {
                                // Previous location (above)
                                if currentIndex > 0, let prevLocation = allLocations[safe: currentIndex - 1] {
                                    VStack(spacing: 0) {
#if !os(watchOS)
                                        Spacer()
                                        Text(prevLocation.name).font(Font.system(size: 25)).padding(.bottom, -10)
#endif
                                        Foo(
                                            weather: weatherForLocation(prevLocation.id),
                                            height: height,
                                            hour: hour,
                                            now: now,
                                            size: size,
                                            sunrise: sunriseForLocation(prevLocation.id),
                                            sunset: sunsetForLocation(prevLocation.id),
                                            unit: userSettings.unit,
                                            coordinate: prevLocation.coordinate,
                                            selectedDay: $selectedDay,
                                            showUVRays: userSettings.showUVRays,
                                            utcOffsetSeconds: utcOffsetForLocation(prevLocation.id)
                                        )
                                    }
                                    .offset(y: dragOffset - screenHeight)
                                }

                                // Current location
                                if let location = allLocations[safe: currentIndex] ?? allLocations.first {
                                    VStack(spacing: 0) {
#if !os(watchOS)
                                        Spacer()
                                        Text(location.name).font(Font.system(size: 25)).padding(.bottom, -10)
#endif
                                        Foo(
                                            weather: weatherForLocation(location.id),
                                            height: height,
                                            hour: hour,
                                            now: now,
                                            size: size,
                                            sunrise: sunriseForLocation(location.id),
                                            sunset: sunsetForLocation(location.id),
                                            unit: userSettings.unit,
                                            coordinate: location.coordinate,
                                            selectedDay: $selectedDay,
                                            showUVRays: userSettings.showUVRays,
                                            utcOffsetSeconds: utcOffsetForLocation(location.id)
                                        )
                                    }
                                    .offset(y: dragOffset)
                                }

                                // Next location (below)
                                if currentIndex < allLocations.count - 1, let nextLocation = allLocations[safe: currentIndex + 1] {
                                    VStack(spacing: 0) {
#if !os(watchOS)
                                        Spacer()
                                        Text(nextLocation.name).font(Font.system(size: 25)).padding(.bottom, -10)
#endif
                                        Foo(
                                            weather: weatherForLocation(nextLocation.id),
                                            height: height,
                                            hour: hour,
                                            now: now,
                                            size: size,
                                            sunrise: sunriseForLocation(nextLocation.id),
                                            sunset: sunsetForLocation(nextLocation.id),
                                            unit: userSettings.unit,
                                            coordinate: nextLocation.coordinate,
                                            selectedDay: $selectedDay,
                                            showUVRays: userSettings.showUVRays,
                                            utcOffsetSeconds: utcOffsetForLocation(nextLocation.id)
                                        )
                                    }
                                    .offset(y: dragOffset + screenHeight)
                                }
                            }
                            .clipped()
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let translation = value.translation.height
                                        let hasPrevious = currentIndex > 0
                                        let hasNext = currentIndex < allLocations.count - 1

                                        let newOffset: CGFloat
                                        if !hasPrevious && translation > 0 {
                                            newOffset = translation * 0.3
                                        } else if !hasNext && translation < 0 {
                                            newOffset = translation * 0.3
                                        } else {
                                            newOffset = translation
                                        }
                                        // Round to whole pixels to avoid sub-pixel jitter
                                        dragOffset = round(newOffset)
                                    }
                                    .onEnded { value in
                                        let threshold: CGFloat = 60
                                        let verticalMovement = value.translation.height

                                        withAnimation(.easeOut(duration: 0.25)) {
                                            if verticalMovement < -threshold && currentIndex < allLocations.count - 1 {
                                                dragOffset = -screenHeight
                                            } else if verticalMovement > threshold && currentIndex > 0 {
                                                dragOffset = screenHeight
                                            } else {
                                                dragOffset = 0
                                            }
                                        }

                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                            if verticalMovement < -threshold && userSettings.selectedLocationIndex < allLocations.count - 1 {
                                                userSettings.selectedLocationIndex += 1
                                            } else if verticalMovement > threshold && userSettings.selectedLocationIndex > 0 {
                                                userSettings.selectedLocationIndex -= 1
                                            }
                                            dragOffset = 0
                                        }
                                    }
                            )
                        } else if let location = allLocations.first {
                            VStack(spacing: 0) {
#if !os(watchOS)
                                Spacer()
                                Text(location.name).font(Font.system(size: 25)).padding(.bottom, -10)
#endif
                                Foo(
                                    weather: weatherForLocation(location.id),
                                    height: height,
                                    hour: hour,
                                    now: now,
                                    size: size,
                                    sunrise: sunriseForLocation(location.id),
                                    sunset: sunsetForLocation(location.id),
                                    unit: userSettings.unit,
                                    coordinate: location.coordinate,
                                    selectedDay: $selectedDay,
                                    showUVRays: userSettings.showUVRays,
                                    utcOffsetSeconds: utcOffsetForLocation(location.id)
                                )
                            }
                        } else {
                            VStack(spacing: 0) {
#if !os(watchOS)
                                Spacer()
                                Text(currentLocation).font(Font.system(size: 25)).padding(.bottom, -10)
#endif
                                Foo(
                                    weather: [:],
                                    height: height,
                                    hour: hour,
                                    now: now,
                                    size: size,
                                    sunrise: [:],
                                    sunset: [:],
                                    unit: userSettings.unit,
                                    coordinate: coordinate,
                                    selectedDay: $selectedDay,
                                    showUVRays: userSettings.showUVRays
                                )
                            }
                        }
                    }
#if os(iOS)
                    .ignoresSafeArea(SafeAreaRegions.all, edges: .bottom)
#endif
                }

#if !os(watchOS)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.2))
                                .padding(12)
                                .background(Circle().fill(Color.black.opacity(0.5)))
                        }
                        .padding(.trailing, 0)
                        .padding(.bottom, 0)
                    }
                }
#endif
            }
            .preferredColorScheme(ColorScheme.dark)
            .onAppear {
                startLocationTracking()
                fetchWeather()
            }
            .onReceive(timer) { input in
                now = input
                if now.distance(to: timeOfData) > 60 * 60 {
                    timeOfData = now
                    fetchWeather()
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(userSettings: userSettings, gpsLocation: $gpsLocation)
            }
            .onChange(of: userSettings.savedLocations) { oldValue, newValue in
                // Fetch weather for any newly added locations
                let newLocations = newValue.filter { newLoc in
                    !oldValue.contains { $0.id == newLoc.id }
                }
                for location in newLocations {
                    fetchWeatherForLocation(location)
                }
            }
        }
    }
    
    func getWeather(hour: Int) -> Weather? {
        guard let date = Date().set(hour: hour) else {
            return nil
        }
        guard let locationId = currentLocationData?.id else {
            return nil
        }
        return weatherByLocation[locationId]?[date]
    }
    
    func fetchWeather() {
        // weatherFromSMI()
        switch self.weatherSource {
        case .fake:
            fakeWeather()
        case .real:
            weatherFromOpenMeteo()
        case .demo:
            demoWeather()
        }
    }
    
    func fakeWeather() {
        let now = Date()
        let fakeLocation = SavedLocation(name: "Test City", latitude: 59.33, longitude: 18.07, isGPS: true)
        self.gpsLocation = fakeLocation
        let id = fakeLocation.id

        var sunriseDict: [NaiveDate: Date] = [:]
        var sunsetDict: [NaiveDate: Date] = [:]
        var weatherDict: [Date: Weather] = [:]

        sunriseDict[now.getNaiveDate()] = now.set(hour: 6, minute: 20)
        sunsetDict[now.getNaiveDate()] = now.set(hour: 20, minute: 10)
        // AM
        weatherDict[now.set(hour:  0)!] = Weather(time: now.set(hour:  0)!, temperature:   1, weatherType:        .snow, rainMillimeter:  1, isDay: false)
        weatherDict[now.set(hour:  1)!] = Weather(time: now.set(hour:  1)!, temperature: -11, weatherType: .mainlyClear, rainMillimeter:  0, isDay: false)
        weatherDict[now.set(hour:  2)!] = Weather(time: now.set(hour:  2)!, temperature:  10, weatherType:       .clear, rainMillimeter:  1, isDay: false)
        weatherDict[now.set(hour:  3)!] = Weather(time: now.set(hour:  3)!, temperature:  15, weatherType:   .lightning, rainMillimeter:  0, isDay: false)
        weatherDict[now.set(hour:  4)!] = Weather(time: now.set(hour:  4)!, temperature:  20, weatherType:   .lightning, rainMillimeter:  9, isDay: false)
        weatherDict[now.set(hour:  5)!] = Weather(time: now.set(hour:  5)!, temperature:  26, weatherType:       .cloud, rainMillimeter:100, isDay: false)
        weatherDict[now.set(hour:  6)!] = Weather(time: now.set(hour:  6)!, temperature:  27, weatherType:  .lightCloud, rainMillimeter:  1, isDay: false)
        weatherDict[now.set(hour:  7)!] = Weather(time: now.set(hour:  7)!, temperature:  32, weatherType:        .rain, rainMillimeter:  0, isDay:  true)
        weatherDict[now.set(hour:  8)!] = Weather(time: now.set(hour:  8)!, temperature:   8, weatherType:        .wind, rainMillimeter: 0, isDay:  true)
        weatherDict[now.set(hour:  9)!] = Weather(time: now.set(hour:  9)!, temperature:   9, weatherType:       .cloud, rainMillimeter:  0, isDay:  true)
        weatherDict[now.set(hour: 10)!] = Weather(time: now.set(hour: 10)!, temperature:  10, weatherType:   .lightning, rainMillimeter:  0, isDay:  true)
        weatherDict[now.set(hour: 11)!] = Weather(time: now.set(hour: 11)!, temperature:  11, weatherType:         .fog, rainMillimeter: 10, isDay:  true)
        // PM
        weatherDict[now.set(hour: 12)!] = Weather(time: now.set(hour: 12)!, temperature:  12, weatherType:         .fog, rainMillimeter:  0, isDay:  true)
        weatherDict[now.set(hour: 13)!] = Weather(time: now.set(hour: 13)!, temperature:  13, weatherType:   .lightning, rainMillimeter: 10, isDay:  true)
        weatherDict[now.set(hour: 14)!] = Weather(time: now.set(hour: 14)!, temperature:  14, weatherType:       .clear, rainMillimeter: 10, isDay:  true)
        weatherDict[now.set(hour: 15)!] = Weather(time: now.set(hour: 15)!, temperature:  16, weatherType:  .lightCloud, rainMillimeter:  10, isDay:  true)
        weatherDict[now.set(hour: 16)!] = Weather(time: now.set(hour: 16)!, temperature: -23, weatherType:  .lightCloud, rainMillimeter: 10, isDay:  true)
        weatherDict[now.set(hour: 17)!] = Weather(time: now.set(hour: 17)!, temperature: -12, weatherType:  .lightCloud, rainMillimeter:  0, isDay:  true)
        weatherDict[now.set(hour: 18)!] = Weather(time: now.set(hour: 18)!, temperature:  17, weatherType:        .wind, rainMillimeter: 10, isDay:  true)
        weatherDict[now.set(hour: 19)!] = Weather(time: now.set(hour: 19)!, temperature:  24, weatherType:       .cloud, rainMillimeter:  0, isDay: false)
        weatherDict[now.set(hour: 20)!] = Weather(time: now.set(hour: 20)!, temperature:  35, weatherType:   .lightning, rainMillimeter:  1, isDay: false)
        weatherDict[now.set(hour: 21)!] = Weather(time: now.set(hour: 21)!, temperature:   1, weatherType:          .fog, rainMillimeter:  0, isDay: false)
        weatherDict[now.set(hour: 22)!] = Weather(time: now.set(hour: 22)!, temperature:  10, weatherType:         .fog, rainMillimeter:  0, isDay: false)
        weatherDict[now.set(hour: 23)!] = Weather(time: now.set(hour: 23)!, temperature:  13, weatherType:         .fog, rainMillimeter:  0, isDay: false)

        self.weatherByLocation[id] = weatherDict
        self.sunriseByLocation[id] = sunriseDict
        self.sunsetByLocation[id] = sunsetDict
    }

    func demoWeather() {
        let now = Date()
        let demoLocation = SavedLocation(name: "Demo City", latitude: 59.33, longitude: 18.07, isGPS: true)
        self.gpsLocation = demoLocation
        let id = demoLocation.id

        var sunriseDict: [NaiveDate: Date] = [:]
        var sunsetDict: [NaiveDate: Date] = [:]
        var weatherDict: [Date: Weather] = [:]

        sunriseDict[now.getNaiveDate()] = now.set(hour: 6, minute: 20)
        sunsetDict[now.getNaiveDate()] = now.set(hour: 19, minute: 30)
        // AM
        weatherDict[now.set(hour:  0)!] = Weather(time: now.set(hour:  0)!, temperature:   1, weatherType:        .clear, rainMillimeter:  0, isDay: false)
        weatherDict[now.set(hour:  1)!] = Weather(time: now.set(hour:  1)!, temperature:  -1, weatherType: .mainlyClear, rainMillimeter:  0, isDay: false)
        weatherDict[now.set(hour:  2)!] = Weather(time: now.set(hour:  2)!, temperature:  3, weatherType:       .clear, rainMillimeter:  0, isDay: false)
        weatherDict[now.set(hour:  3)!] = Weather(time: now.set(hour:  3)!, temperature:  7, weatherType:   .clear, rainMillimeter:  0, isDay: false)
        weatherDict[now.set(hour:  4)!] = Weather(time: now.set(hour:  4)!, temperature:  14, weatherType:   .lightCloud, rainMillimeter:  0, isDay: false)
        weatherDict[now.set(hour:  5)!] = Weather(time: now.set(hour:  5)!, temperature:  18, weatherType:   .lightCloud, rainMillimeter:  0, isDay: false)
        weatherDict[now.set(hour:  6)!] = Weather(time: now.set(hour:  6)!, temperature:  20, weatherType:  .lightCloud, rainMillimeter:  1, isDay: false)
        weatherDict[now.set(hour:  7)!] = Weather(time: now.set(hour:  7)!, temperature:  20, weatherType:        .rain, rainMillimeter:  5, isDay:  true)
        weatherDict[now.set(hour:  8)!] = Weather(time: now.set(hour:  8)!, temperature:  19, weatherType:        .rain, rainMillimeter: 10, isDay:  true)
        weatherDict[now.set(hour:  9)!] = Weather(time: now.set(hour:  9)!, temperature:  20, weatherType:       .rain, rainMillimeter:  1, isDay:  true)
        weatherDict[now.set(hour: 10)!] = Weather(time: now.set(hour: 10)!, temperature:  19, weatherType:   .lightCloud, rainMillimeter:  0, isDay:  true)
        weatherDict[now.set(hour: 11)!] = Weather(time: now.set(hour: 11)!, temperature:  17, weatherType:   .lightCloud, rainMillimeter: 0, isDay:  true)
        // PM
        weatherDict[now.set(hour: 12)!] = Weather(time: now.set(hour: 12)!, temperature:  23, weatherType:         .clear, rainMillimeter:  0, isDay:  true)
        weatherDict[now.set(hour: 13)!] = Weather(time: now.set(hour: 13)!, temperature:  25, weatherType:   .clear, rainMillimeter: 0, isDay:  true)
        weatherDict[now.set(hour: 14)!] = Weather(time: now.set(hour: 14)!, temperature:  24, weatherType:       .clear, rainMillimeter: 0, isDay:  true)
        weatherDict[now.set(hour: 15)!] = Weather(time: now.set(hour: 15)!, temperature:  27, weatherType:  .lightCloud, rainMillimeter:  0, isDay:  true)
        weatherDict[now.set(hour: 16)!] = Weather(time: now.set(hour: 16)!, temperature:  26, weatherType:  .lightCloud, rainMillimeter: 0, isDay:  true)
        weatherDict[now.set(hour: 17)!] = Weather(time: now.set(hour: 17)!, temperature:  32, weatherType:  .lightCloud, rainMillimeter:  0, isDay:  true)
        weatherDict[now.set(hour: 18)!] = Weather(time: now.set(hour: 18)!, temperature:  30, weatherType:        .wind, rainMillimeter: 0, isDay:  true)
        weatherDict[now.set(hour: 19)!] = Weather(time: now.set(hour: 19)!, temperature:  28, weatherType:       .clear, rainMillimeter:  0, isDay: false)
        weatherDict[now.set(hour: 20)!] = Weather(time: now.set(hour: 20)!, temperature:  23, weatherType:   .clear, rainMillimeter:  0, isDay: false)
        weatherDict[now.set(hour: 21)!] = Weather(time: now.set(hour: 21)!, temperature:  20, weatherType:          .clear, rainMillimeter:  0, isDay: false)
        weatherDict[now.set(hour: 22)!] = Weather(time: now.set(hour: 22)!, temperature:  16, weatherType:         .clear, rainMillimeter:  0, isDay: false)
        weatherDict[now.set(hour: 23)!] = Weather(time: now.set(hour: 23)!, temperature:  18, weatherType:         .clear, rainMillimeter:  0, isDay: false)

        self.weatherByLocation[id] = weatherDict
        self.sunriseByLocation[id] = sunriseDict
        self.sunsetByLocation[id] = sunsetDict
    }
    func startLocationTracking() {
        do {
            locationProvider.lm.allowsBackgroundLocationUpdates = false
            try locationProvider.start()
        }
        catch {
            print("No location access.")
            locationProvider.requestAuthorization()
            do {
                try locationProvider.start()
            }
            catch {
            }
        }
    }
 
    func weatherFromOpenMeteo() {
        cancellableLocation = locationProvider.locationWillChange.sink { loc in
            let geocoder = CLGeocoder()
            coordinate = loc.coordinate
            geocoder.reverseGeocodeLocation(loc) { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    let locationName = firstLocation?.locality ?? ""
                    currentLocation = locationName

                    // Create or update GPS location
                    let newGPSLocation = SavedLocation.gpsLocation(name: locationName, coordinate: loc.coordinate)
                    self.gpsLocation = newGPSLocation

                    // Fetch weather for GPS location
                    self.fetchWeatherForLocation(newGPSLocation)

                    // Fetch weather for all saved locations too
                    for location in self.userSettings.savedLocations {
                        self.fetchWeatherForLocation(location)
                    }

                    if firstLocation?.country ?? "unknown" == "United States" && !userSettings.hasChosenUnit {
                        showUnitChooser = true
                    }
                }
            }
        }
    }

    func fetchWeatherForLocation(_ location: SavedLocation) {
        // Check cache (1 hour)
        if let lastFetched = lastFetchedByLocation[location.id],
           Date().timeIntervalSince(lastFetched) < 3600 {
            return
        }

        DispatchQueue.main.async {
            let s = "https://api.open-meteo.com/v1/forecast?latitude=\(location.latitude)&longitude=\(location.longitude)&hourly=temperature_2m,precipitation,weathercode,cloudcover,windspeed_10m,uv_index&past_days=1&daily=sunrise,sunset&timezone=auto&timeformat=unixtime"

            guard let url = URL(string: s) else {
                return
            }

            print("getting weather for \(location.name): \(url)")
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let response = response as? HTTPURLResponse {

                    if response.statusCode == 503 {
                        return
                    }

                   if error != nil {
                        return
                    }

                    do {
                        if let data = data {
                            let string1 = String(data: data, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                            print(string1)
                            let decoder = JSONDecoder()

                            decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.secondsSince1970
                            let result = try decoder.decode(OMWeatherData.self, from: data)
                            print("Parsed for \(location.name)!")

                            var sunsetDict: [NaiveDate: Date] = [:]
                            var sunriseDict: [NaiveDate: Date] = [:]
                            var weatherDict: [Date: Weather] = [:]

                            for i in 0..<result.daily.time.count {
                                let date = result.daily.time[i].getNaiveDate(utcOffsetSeconds: result.utc_offset_seconds)
                                if i < result.daily.sunset.count {
                                    sunsetDict[date] = result.daily.sunset[i]
                                }
                                if i < result.daily.sunrise.count {
                                    sunriseDict[date] = result.daily.sunrise[i]
                                }
                            }

                            for i in 0..<result.hourly.time.count {
                                let time = result.hourly.time[i]
                                let temperature = result.hourly.temperature_2m[i]
                                let weatherSymbol = result.hourly.weathercode[i]
                                let rainMillimeter = result.hourly.precipitation[i]
                                let windspeed = result.hourly.windspeed_10m[i]
                                let uvIndex = result.hourly.uv_index[i]
                                let sunrise = sunriseDict[time.getNaiveDate()]
                                let sunset = sunsetDict[time.getNaiveDate()]
                                guard let sunrise = sunrise else {
                                    continue
                                }
                                guard let sunset = sunset else {
                                    continue
                                }
                                let isDay = time > sunrise && time < sunset

                                var weatherType: WeatherType
                                switch weatherSymbol {
                                case 0:
                                    weatherType = .clear
                                case 1:
                                    weatherType = .mainlyClear
                                case 2:
                                    weatherType = .lightCloud
                                case 3:
                                    weatherType = .cloud
                                case 71...75:
                                    weatherType = .snow
                                case 51...67:
                                    weatherType = .rain
                                case 80...86:
                                    weatherType = .rain
                                case 95...99:
                                    weatherType = .lightning
                                case 45...48:
                                    weatherType = .fog
                                default:
                                    weatherType = .unknown
                                }

                                if windspeed > 20 {
                                    weatherType = .wind
                                }

                                weatherDict[time] = Weather(time: time, temperature: temperature, weatherType: weatherType, rainMillimeter: rainMillimeter, isDay: isDay, uvIndex: uvIndex)
                            }

                            DispatchQueue.main.async {
                                self.weatherByLocation[location.id] = weatherDict
                                self.sunriseByLocation[location.id] = sunriseDict
                                self.sunsetByLocation[location.id] = sunsetDict
                                self.utcOffsetByLocation[location.id] = result.utc_offset_seconds
                                self.lastFetchedByLocation[location.id] = Date()
                            }
                        }
                    }
                    catch let error {
                        print("Error parsing (\(error))")
                    }
                }
            }
            task.resume()
        }
    }
}


struct Previews_FrejView_Previews: PreviewProvider {
    static var previews: some View {
        FrejView(weatherSource: .fake)
    }
}
