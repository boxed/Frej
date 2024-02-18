//
//  Icon.swift
//  Frej
//
//  Created by Anders Hovmöller on 2024-02-12.
//

import Foundation
import SwiftUI


private let sun_ray_density = 0.07
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
            Rays(a: 2.4, b: circle_inner_diameter, ray_density: sun_ray_density, wiggle_a: true, start_degree: from, end_degree: to, wiggle_size: 1.03)
                .stroke(Color.yellow, style: StrokeStyle(lineWidth: 8, lineCap: .butt))
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
                                .stroke(.black, style: StrokeStyle(lineWidth: 4, lineCap: .round))

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
                    .rotation(.degrees(-105))
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
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.hour], from: now)
        let hour = components.hour!
        
        VStack {
            #if !os(watchOS)
            Spacer()
            Text(currentLocation).font(.system(size: 25))
            Link("Weather data by Open-Meteo.com", destination: URL(string: "https://open-meteo.com/")!).font(Font.system(size: 12)).foregroundColor(.gray)
            #endif
            GeometryReader { (geometry) in
                let size = geometry.size
                let height = min(size.width * 0.9, abs(size.height / 2 - 25))
                FooIcon(weather: weather, height: height, hour: hour, now: now, size: size, sunrise: sunrise, sunset: sunset, unit: userSettings.unit)
            }
            #if os(iOS)
            .ignoresSafeArea(.all, edges: .bottom)
            #endif
            .preferredColorScheme(.dark)
            .onAppear {
                fakeWeather()
            }
        }
        
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
