//
//  SunHailTests.swift
//  SunHailTests
//
//  Created by Anders Hovmöller on 2021-05-11.
//

import XCTest
import SwiftUI
import CoreLocation
@testable import Frej

// Renders the clock and its layers off screen and prints how long each takes, to find what's slow to draw. Run with
// optimizations on (SWIFT_OPTIMIZATION_LEVEL=-O), or the numbers say more about debug builds than the app.
@MainActor
class DrawingBenchmarkTests: XCTestCase {
    let timeZone = TimeZone(identifier: "Europe/Stockholm")!
    let coordinate = CLLocationCoordinate2D(latitude: 59.33, longitude: 18.07)
    let size = CGSize(width: 354, height: 354)

    var startOfToday: Date { Date().startOfDay(in: timeZone) }

    // Every hour has something going on: clouds everywhere, with rain, snow, fog, and lightning mixed in
    func busyWeather() -> [Date: Weather] {
        var weather: [Date: Weather] = [:]
        for hour in 0..<24 {
            let time = startOfToday.addingLocalHours(hour, in: timeZone)
            let (type, mm): (WeatherType, Float) = switch hour % 6 {
            case 0: (.rain, 0.3)
            case 1: (.rain, 5)
            case 2: (.lightning, 15)
            case 3: (.snow, 1)
            case 4: (.fog, 0)
            default: (.cloud, 0)
            }
            weather[time] = Weather(time: time, temperature: Float(hour), weatherType: type, rainMillimeter: mm, isDay: hour > 6 && hour < 20, cloudCover: 80)
        }
        return weather
    }

    func clearWeather() -> [Date: Weather] {
        var weather: [Date: Weather] = [:]
        for hour in 0..<24 {
            let time = startOfToday.addingLocalHours(hour, in: timeZone)
            weather[time] = Weather(time: time, temperature: Float(hour), weatherType: .clear, rainMillimeter: 0, isDay: hour > 6 && hour < 20)
        }
        return weather
    }

    var sunrise: [NaiveDate: Date] { [startOfToday.getNaiveDate(in: timeZone): startOfToday.addingTimeInterval(6.5 * 3600)] }
    var sunset: [NaiveDate: Date] { [startOfToday.getNaiveDate(in: timeZone): startOfToday.addingTimeInterval(19.5 * 3600)] }

    func clock(_ weather: [Date: Weather], start: Int) -> Clock {
        Clock(now: startOfToday.addingTimeInterval(10 * 3600), startOfToday: startOfToday, showDials: true, start: start, weather: weather, sunrise: sunrise, sunset: sunset, unit: "C", timeZone: timeZone, coordinate: coordinate)
    }

    // Average milliseconds to render the view, after a warm up render
    func time<V: View>(_ name: String, iterations: Int = 20, size: CGSize? = nil, _ view: V) -> Double {
        let size = size ?? self.size
        let renderer = ImageRenderer(content: view.frame(width: size.width, height: size.height).background(Color.black))
        renderer.scale = 3
        _ = renderer.cgImage
        let start = CFAbsoluteTimeGetCurrent()
        for _ in 0..<iterations {
            // A new renderer each time, so nothing is cached between renders
            let renderer = ImageRenderer(content: view.frame(width: size.width, height: size.height).background(Color.black))
            renderer.scale = 3
            _ = renderer.cgImage
        }
        let ms = (CFAbsoluteTimeGetCurrent() - start) / Double(iterations) * 1000
        print(String(format: "BENCHMARK %-28@ %8.2f ms", name as NSString, ms))
        return ms
    }

    func timeCode(_ name: String, iterations: Int, _ block: () -> Void) {
        let start = CFAbsoluteTimeGetCurrent()
        for _ in 0..<iterations { block() }
        let us = (CFAbsoluteTimeGetCurrent() - start) / Double(iterations) * 1_000_000
        print(String(format: "BENCHMARK %-28@ %8.2f µs", name as NSString, us))
    }

    // Writes the rendered clocks to FREJ_RENDER_DIR, to check that drawing changes don't change how things look
    func testRenderSnapshots() throws {
        guard let dir = ProcessInfo.processInfo.environment["FREJ_RENDER_DIR"] else { throw XCTSkip("FREJ_RENDER_DIR not set") }
        for (name, view) in [("busy-am", clock(busyWeather(), start: 0)), ("busy-pm", clock(busyWeather(), start: 12)), ("clear-am", clock(clearWeather(), start: 0))] {
            // Full size, and widget size, where the labels come closest to the edges
            for (suffix, side) in [("", size.width), ("-small", CGFloat(150))] {
                let renderer = ImageRenderer(content: view.frame(width: side, height: side).background(Color.black))
                renderer.scale = 3
                let data = UIImage(cgImage: renderer.cgImage!).pngData()!
                try data.write(to: URL(fileURLWithPath: dir).appendingPathComponent("\(name)\(suffix).png"))
            }
        }
    }

    // Renders the busy clock over and over while FREJ_PROFILE_SECONDS is set, for sampling with a profiler
    func testProfileLoop() throws {
        guard let seconds = ProcessInfo.processInfo.environment["FREJ_PROFILE_SECONDS"].flatMap(Double.init) else { throw XCTSkip("FREJ_PROFILE_SECONDS not set") }
        let busy = busyWeather()
        let end = Date().addingTimeInterval(seconds)
        while Date() < end {
            let renderer = ImageRenderer(content: clock(busy, start: 0).frame(width: size.width, height: size.height).background(Color.black))
            renderer.scale = 3
            _ = renderer.cgImage
        }
    }

    // DialHours skips the calendar when there's no daylight saving change on the dial, which must give the same hours
    func testDialHoursMatchesCalendar() {
        let calendar = Calendar.gregorian(in: timeZone)
        for (month, day) in [(3, 29), (10, 25), (6, 15)] {
            let midnight = calendar.date(from: DateComponents(year: 2026, month: month, day: day))!
            for start in stride(from: -24, through: 132, by: 12) {
                let hours = DialHours(startOfToday: midnight, start: start, timeZone: timeZone)
                for hour in (start - 1)...(start + 13) {
                    XCTAssertEqual(hours.date(hour: hour), midnight.addingLocalHours(hour, in: timeZone), "\(month)-\(day) start \(start) hour \(hour)")
                }
            }
        }
    }

    func testDrawingBenchmark() {
        let busy = busyWeather()
        let clear = clearWeather()

        time("empty", Color.black)
        time("clock busy am", clock(busy, start: 0))
        time("clock busy pm", clock(busy, start: 12))
        time("clock clear am", clock(clear, start: 0))
        time("clock clear pm", clock(clear, start: 12))

        // The layers of the busy morning dial on their own
        let day = startOfToday.getNaiveDate(in: timeZone)
        time("night", Night(start: 0, sunrise: sunrise[day], sunset: sunset[day], timeZone: timeZone, startOfToday: startOfToday, coordinate: coordinate, weather: busy))
        time("daylight", Daylight(start: 0, sunrise: sunrise[day], sunset: sunset[day], weather: busy, startOfToday: startOfToday, timeZone: timeZone, coordinate: coordinate))
        time("precipitation x12", ZStack {
            ForEach(0..<12, id: \.self) { id in
                let (from, to) = hourDegrees(id)
                Precipitation(a: 3.0, b: 3.7, ray_density: 0.6, start_degree: from, end_degree: to, snow: id % 2 == 0, heavinessBefore: 0.5, heavinessCenter: 0.5, heavinessAfter: 0.5, seed: id)
            }
        })
        time("cloud shadow", CloudShadow(shades: (0..<12).map { $0 == 4 ? nil : Double($0) / 11 }))
        time("cloud bands x12", ZStack {
            ForEach(0..<12, id: \.self) { id in
                let (from, to) = hourDegrees(id)
                CloudBand(from: from, to: to, shade: 0.5, previousShade: 0.3, nextShade: 0.7, cloudSize: self.size.height / 23)
            }
        })
        time("cloud rims x12", ZStack {
            ForEach(0..<12, id: \.self) { id in
                let (from, to) = hourDegrees(id)
                CloudRims(from: from, to: to, cloudSize: self.size.height / 23, seed: id)
            }
        })
        time("fog x1", ZStack {
            let (from, to) = hourDegrees(4)
            Rays(a: 3.0, b: 3.7, ray_density: 1.27 - 0.5, wiggle_a: true, wiggle_b: true, start_degree: from-1, end_degree: to+1, wiggle_size: 1.02)
                .stroke(Color.black.opacity(0.7), style: StrokeStyle(lineWidth: 3, lineCap: .butt, dash: [2, ])).blur(radius: self.size.height / 60)
            Rays(a: 3.0, b: 3.7 + 1.5, ray_density: 1.27 - 0.5, wiggle_a: true, wiggle_b: true, start_degree: from-1, end_degree: to+1)
                .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 4, lineCap: .butt, dash: [2,])).blur(radius: self.size.height / 60)
            Rays(a: 3.0, b: 3.7, ray_density: 1.27, wiggle_a: true, wiggle_b: true, start_degree: from-1, end_degree: to)
                .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, lineCap: .butt, dash: [1, 1])).blur(radius: self.size.height / 60)
        })
        time("temperatures", Temperatures(weather: (0..<12).map { busy[startOfToday.addingLocalHours($0, in: timeZone)] }, unit: "C"))
        time("hour labels", HourLabels(start: 0))
        time("cloud borders x12", ZStack {
            ForEach(0..<12, id: \.self) { id in
                let (from, to) = hourDegrees(id)
                Rays(a: 3.0 - 0.05, b: 2.98 - 0.05, ray_density: 0.2, wiggle_c: true, start_degree: from + 0.5, end_degree: to + 0.5, wiggle_size: 1.02)
                    .stroke(Color.black, style: StrokeStyle(lineWidth: self.size.height / 23, lineCap: .round))
            }
        })
        time("bolts x12", ZStack {
            ForEach(0..<12, id: \.self) { id in
                let (from, to) = hourDegrees(id)
                LightningStrikes(a: 3.1, b: 3.7, start_degree: from, end_degree: to, seed: id)
            }
        })
        time("dial and hands", ZStack {
            Circle()
                .trim(from: 0.0, to: 0.99)
                .rotation(Angle.degrees(-105))
                .fill(Color.black)
                .stroke(Color.gray, lineWidth: 1)
                .padding(self.size.height * 0.2)
                .scaleEffect(0.9)
            ClockDial(now: Date(), progress: 10 / 12.0, extraSize: 0.25).stroke(Color.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
            ClockDial(now: Date(), progress: 0.5, extraSize: 0.38).stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
        })
        let fullMoon = (0..<30).map { startOfToday.addingTimeInterval(Double($0) * 86400) }
            .max { MoonAppearance(date: $0, coordinate: coordinate).illuminatedFraction < MoonAppearance(date: $1, coordinate: coordinate).illuminatedFraction }!
        time("moon", Moon(date: fullMoon, coordinate: coordinate).frame(width: 60, height: 60))
        time("page (2 clocks + moon)", size: CGSize(width: size.width, height: size.height * 2), ZStack {
            VStack(spacing: 0) {
                clock(busy, start: 0).frame(height: self.size.height)
                clock(busy, start: 12).frame(height: self.size.height)
            }
            Moon(date: fullMoon, coordinate: coordinate).frame(width: 60, height: 60)
        })
        timeCode("greatestEclipse, full moon day", iterations: 100) {
            _ = MoonAppearance.greatestEclipse(from: fullMoon, to: fullMoon.addingTimeInterval(86400), coordinate: coordinate)
        }
        timeCode("greatestEclipse, other day", iterations: 100) {
            _ = MoonAppearance.greatestEclipse(from: startOfToday, to: startOfToday.addingTimeInterval(86400), coordinate: coordinate)
        }

        // Helpers that run per ray
        timeCode("blendColors", iterations: 10_000) { _ = blendColors(.red, .blue, ratio: 0.3) }
        timeCode("addingLocalHours", iterations: 10_000) { _ = startOfToday.addingLocalHours(5, in: timeZone) }
        timeCode("Calendar.gregorian", iterations: 10_000) { _ = Calendar.gregorian(in: timeZone) }
        let calendar = Calendar.gregorian(in: timeZone)
        timeCode("calendar date math", iterations: 10_000) {
            let day = calendar.date(byAdding: .day, value: 0, to: startOfToday)!
            _ = calendar.date(bySettingHour: 5, minute: 0, second: 0, of: day)
        }
        timeCode("fractionalHour", iterations: 10_000) { _ = startOfToday.fractionalHour(in: timeZone) }
        timeCode("sunElevation", iterations: 10_000) { _ = sunElevation(date: startOfToday, coordinate: coordinate) }
    }
}
