//
//  Icon.swift
//  Frej
//
//  Created by Anders Hovmöller on 2024-02-12.
//

import Foundation
import SwiftUI


private let sun_ray_density = 0.2
private let cloud_ray_density = 0.16
private let rain_density = 0.108
private let circle_inner_diameter = 6.9
private let cloud_diameter = 3.0
private let cloud_diameter2 = 2.98
private let cloudSize = 30.0


struct DaylightIcon : View {
    var start : Int
    var sunrise: Date?
    var sunset: Date?

    var body : some View {
        if let sunrise = sunrise, let sunset = sunset {
            let (from, to) = datetime_to_degrees(sunrise: sunrise, sunset: sunset, start: start)
            Rays(a: sun_ray_density, b: circle_inner_diameter, ray_density: sun_ray_density, wiggle_a: true, start_degree: from, end_degree: to, wiggle_size: 1.03)
                .stroke(Color.yellow, style: StrokeStyle(lineWidth: 15, lineCap: .butt))
        }
        else {
            Text("")
        }
    }
}


struct ClockIcon : View {
    var now: Date;
    var startOfToday: Date;
    var showDials: Bool
    var start : Int
    var weather : [Date: Weather]
    let calendar = Calendar.current
    var sunrise : [NaiveDate: Date]
    var sunset : [NaiveDate: Date]
    let unit : String


    var body : some View {
        GeometryReader { (geometry) in
            let frame = geometry.size
            let startTime = startOfToday.addingTimeInterval(TimeInterval(start * 60 * 60))
            ZStack {
                DaylightIcon(start: start, sunrise: sunrise[startTime.getNaiveDate()], sunset: sunset[startTime.getNaiveDate()])
                
                
                ForEach(0..<12, id: \.self) { id in
                    let startDatetime = startOfToday.addingTimeInterval(TimeInterval((id + start) * 60 * 60))
                    if let weather = weather[startDatetime] {
                        // Rain
                        let (from, to) = rainDegrees(date: startDatetime)
                        
                        let darkClouds  = weather.rainMillimeter > 0 || weather.weatherType == .rain || weather.weatherType == .cloud
                    
                        if darkClouds {
                            // black anti-rays
                            Rays(a: cloud_diameter, b: circle_inner_diameter, ray_density: sun_ray_density, start_degree: from, end_degree: to )
                                .stroke(Color.black, style: StrokeStyle(lineWidth: 4, lineCap: .round))

                            // rain
                            Rays(a: cloud_diameter, b: circle_inner_diameter, ray_density: rain_density, wiggle_a: true, wiggle_b: true, start_degree: from, end_degree: to, wiggle_size: 1.05)
                                .stroke(rainColor, style: StrokeStyle(lineWidth: 8, lineCap: .butt, dash: [7]))
                        }
                        if !darkClouds && weather.weatherType == .lightCloud  {
                            // white clouds
                            Rays(a: cloud_diameter, b: cloud_diameter2, ray_density: cloud_ray_density, wiggle_a: false, wiggle_b: true, start_degree: from + 0.5, end_degree: to + 0.5, wiggle_size: 1.03)
                                .stroke(Color.white, style: StrokeStyle(lineWidth: cloudSize, lineCap: .round))
                        }
                        if darkClouds {
                            // dark clouds
                            Rays(a: cloud_diameter, b: cloud_diameter2, ray_density: cloud_ray_density, wiggle_c: true, start_degree: from + 0.5, end_degree: to + 0.5, wiggle_size: 1.03)
                                .stroke(Color(hex: 0x606060, alpha: 1), style: StrokeStyle(lineWidth: cloudSize, lineCap: .round))
                        }
                    }
                }
                // ground, or circle showing the break in the timeline
                Circle()
                    .trim(from: 0.0, to: 0.99)
                    .rotation(Angle.degrees(-105))
                    .stroke(Color.init(white: 0.3), lineWidth: 7)
                    .padding(frame.height * 0.2)
                    .scaleEffect(0.5)
            }
            #if os(watchOS)
                .scaleEffect(1.4)
            #endif
        }
    }
}

struct FooIcon : View {
    let weather : [Date: Weather]
    let height : CGFloat
    let hour : Int
    let now : Date
    let size : CGSize
    var sunrise : [NaiveDate: Date]
    var sunset : [NaiveDate: Date]
    let unit: String
    
    var body: some View {
        let fractionalHour: Double = now.fractionalHour()
        let startOfToday = now.set(hour: 0, minute: 0)!
        
        let day = 0

        VStack {
            let i: Int = day * 2
            let start1: Int = 12*i
            let start1_d = Double(start1)
            ClockIcon(
                now: now,
                startOfToday: startOfToday,
                showDials: fractionalHour > (start1_d - 0.5) && fractionalHour < (start1_d + 12 - 0.5),
                start: start1,
                weather: weather,
                sunrise: sunrise,
                sunset: sunset,
                unit: unit
            ).frame(height: height)
            
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(width: size.width, height: size.height)
    }
}

struct Darkness : Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 10, y: 50))
        p.addLine(to: CGPoint(x: 240, y: 50))
        p.addLine(to: CGPoint(x: 500, y: 300))
        p.addLine(to: CGPoint(x: 450, y: 650))
        p.addLine(to: CGPoint(x: 140, y: 600))
        return p
    }
}


struct Icon : View {
    @State var now: Date = Date()
    @State var weather : [Date: Weather] = [:]
    @State var sunrise : [NaiveDate: Date] = [:]
    @State var sunset : [NaiveDate: Date] = [:]
    @State var loadedURL : String = ""
    @State var timeOfData : Date = Date.init(timeIntervalSince1970: 0)
    @State var currentLocation : String = ""
    @State var showUnitChooser = false
    @ObservedObject var userSettings = UserSettings()

    var body: some View {
        let chunkiness = 15.0
        
        ZStack {
            DaylightIcon(
                start: 12,
                sunrise: Date.from(year: 2024, month: 1, day: 1).set(hour: 15),
                sunset: Date.from(year: 2024, month: 1, day: 1).set(hour: 20)
            )
            .scaleEffect(0.4)
            .position(x: 110, y: 265)
//            .mask(Text("F").font(Font.system(size: 130, weight: .bold, design: .rounded)))
//            Text("F").font(Font.system(size: 130, weight: .bold, design: .rounded)).foregroundColor(Color.black)
            ZStack() {
                Darkness().fill(Color.black).frame(width: 400, height: 700).position(x: 270, y: 805)

                Rays(a: sun_ray_density, b: 3, ray_density: sun_ray_density, wiggle_a: true, start_degree: 134, end_degree: 170, wiggle_size: 1.03)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 15, lineCap: .butt, dash: [35]))
                    .position(x: 40, y: 285)

                Circle()
                    .fill(Color.black)
                    .frame(width: 100, height: 120)
                    .position(x: 270, y: 500 - chunkiness)
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .position(x: 270, y: 500)

                
                Circle()
                    .fill(Color.black)
                    .frame(width: 120, height: 120)
                    .position(x: 220, y: 495 - chunkiness)
                Circle()
                    .fill(Color.white)
                    .frame(width: 120, height: 120)
                    .position(x: 220, y: 495)

                Circle()
                    .fill(Color.black)
                    .frame(width: 130, height: 130)
                    .position(x: 170, y: 490 - chunkiness)
                Circle()
                    .fill(Color.white)
                    .frame(width: 130, height: 130)
                    .position(x: 170, y: 490)

                
                Circle().fill(Color.black).frame(width: 100, height: 100).position(x: 115, y: 495)
                Circle().fill(Color.white).frame(width: 100, height: 100).position(x: 120, y: 505)

                

            }.position(x: 250, y: 400).scaleEffect(0.7)
            

//            Moon(date: Date.from(year: 2024, month: 1, day: 14).set(hour: 15)!).scaleEffect(0.08).position(x: 240, y: 430)
        }
        .preferredColorScheme(ColorScheme.dark)
    }
    
    func getWeather(hour: Int) -> Weather? {
        guard let date = Date().set(hour: hour) else {
            return nil
        }
        return self.weather[date]
    }
    
   
    func fakeWeather() {
        let now = Date()
        self.sunrise[now.getNaiveDate()] = now.set(hour: 0, minute: 0)
        self.sunset[now.getNaiveDate()] = now.set(hour: 5, minute: 10)
        self.weather[now.set(hour:  0)!] = Weather(time: now.set(hour:  0)!, temperature:   1, weatherType: .clear, rainMillimeter: 0, isDay: false)
        self.weather[now.set(hour:  1)!] = Weather(time: now.set(hour:  1)!, temperature:   1, weatherType: .clear, rainMillimeter: 0, isDay: false)
        self.weather[now.set(hour:  2)!] = Weather(time: now.set(hour:  2)!, temperature:   1, weatherType: .clear, rainMillimeter: 0, isDay: false)
        self.weather[now.set(hour:  3)!] = Weather(time: now.set(hour:  3)!, temperature:   1, weatherType: .clear, rainMillimeter: 0, isDay: false)
        self.weather[now.set(hour:  4)!] = Weather(time: now.set(hour:  4)!, temperature:   2, weatherType: .lightCloud, rainMillimeter: 0, isDay: false)
        self.weather[now.set(hour:  5)!] = Weather(time: now.set(hour:  5)!, temperature:   2, weatherType: .lightCloud, rainMillimeter: 0, isDay: false)
        self.weather[now.set(hour:  6)!] = Weather(time: now.set(hour:  6)!, temperature:   2, weatherType: .lightCloud, rainMillimeter: 0, isDay: false)
        self.weather[now.set(hour:  7)!] = Weather(time: now.set(hour:  7)!, temperature:   3, weatherType: .clear, rainMillimeter: 0, isDay:  true)
        self.weather[now.set(hour:  8)!] = Weather(time: now.set(hour:  8)!, temperature:   8, weatherType: .clear, rainMillimeter: 0, isDay:  true)
        self.weather[now.set(hour:  9)!] = Weather(time: now.set(hour:  9)!, temperature:   9, weatherType: .rain, rainMillimeter: 10, isDay:  true)
        self.weather[now.set(hour: 10)!] = Weather(time: now.set(hour: 10)!, temperature:   1, weatherType: .rain, rainMillimeter: 10, isDay:  true)
        self.weather[now.set(hour: 11)!] = Weather(time: now.set(hour: 11)!, temperature:   1, weatherType: .rain, rainMillimeter: 10, isDay:  true)
        self.weather[now.set(hour: 12)!] = Weather(time: now.set(hour: 12)!, temperature:   1, weatherType: .rain, rainMillimeter: 10, isDay:  true)
        self.weather[now.set(hour: 13)!] = Weather(time: now.set(hour: 13)!, temperature:   1, weatherType: .clear, rainMillimeter: 0, isDay:  true)
        self.weather[now.set(hour: 14)!] = Weather(time: now.set(hour: 14)!, temperature:   1, weatherType: .clear, rainMillimeter: 0, isDay:  true)
    }
    
 
}
struct Previews_Icon_Previews: PreviewProvider {
    static var previews: some View {
        Icon()
    }
}
