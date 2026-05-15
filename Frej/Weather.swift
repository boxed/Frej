import Foundation
import SwiftUI

enum WeatherType {
    case clear
    case mainlyClear
    case lightCloud
    case cloud
    case rain
    case lightning
    case wind
    case fog
    case snow
    case unknown
}

enum RainIntensity {
    case none
    case light
    case moderate
    case heavy
    case violent
}

private func _textColor(isDay: Bool, weatherType: WeatherType) -> Color {
    switch weatherType {
    case .clear:
        if isDay {
            return Color.init(hex: 0xFFFDB0)
        }
        else {
            return .white
        }
    case .mainlyClear:
        return .white
    case .lightning:
        return Color.init(hex: 0x929292)
    case .cloud:
        return Color.init(hex: 0xC2C2C2)
    case .lightCloud:
        return .white
    case .fog:
        return .white
    case .rain:
        return Color.init(hex: 0xCDE9FF)
    case .wind:
        return .white
    case .snow:
        return .white
    case .unknown:
        return .gray
    }
}

private func _iconColor(weatherType : WeatherType, isDay : Bool) -> Color {
    switch weatherType {
    case .clear:
        if isDay {
            return sunColor
        }
        else {
            return .white
        }
    case .mainlyClear:
        return .white
    case .lightCloud:
        return .white
    case .cloud:
        return Color.init(hex: 0x929292)
    case .rain:
        return rainColor;
    case .lightning:
        return Color.init(hex: 0xF9E231)
    case .fog:
        return Color.init(hex: 0x929292)
    case .snow:
        return .white
    case .unknown:
        return .white
    case .wind:
        return Color.init(hex: 0xB0B0B0)
    }
}

private func _rainIntensity(rainMillimeter : Float) -> RainIntensity {
    switch rainMillimeter {
    case 0...0.01:
        return .none
    case 0...4.5:
        return .light
    case 4.5...8.5:
        return .moderate
    case 8.5...50:
        return .heavy
    default:
        if rainMillimeter < 0 {
            return .none
        }
        if rainMillimeter > 50 {
            return .violent
        }
                    
        assert(false)
        return .none
    }
}


let rainColor = Color.init(hex: 0x0080FF)
let sunColor = Color.init(hex: 0xF9E231)

struct Weather {
    let time : Date
    let temperature : Float
    let apparentTemperature : Float
    let weatherType : WeatherType
    let rainMillimeter : Float
    let textColor : Color
    let circleSegmentColor : Color
    let circleSegmentWidth : CGFloat
    let isDay : Bool
    let iconColor : Color
    let rainIntensity : RainIntensity
    let uvIndex : Float

    init(
        time : Date,
        temperature : Float,
        weatherType : WeatherType,
        rainMillimeter : Float,
        isDay : Bool,
        uvIndex : Float = 0,
        apparentTemperature : Float? = nil
    ) {
        self.time = time
        self.temperature = temperature
        self.apparentTemperature = apparentTemperature ?? temperature
        self.weatherType = weatherType
        self.rainMillimeter = rainMillimeter

        self.isDay = isDay
        self.uvIndex = uvIndex

        self.circleSegmentColor = rainMillimeter > 0 ? rainColor : .white
        self.circleSegmentWidth = max(1, CGFloat(log(rainMillimeter) * 10))
        self.textColor = _textColor(isDay: isDay, weatherType: weatherType)
        self.iconColor = _iconColor(weatherType: weatherType, isDay: isDay)
        self.rainIntensity = _rainIntensity(rainMillimeter: self.rainMillimeter)
    }
    
    @ViewBuilder
    func icon() -> some View {
        switch self.weatherType {
        case .clear:
            if isDay {
                Sun()
                #if os(watchOS)
                    .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                #else
                    .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                #endif
                .foregroundColor(sunColor)
            }
            else {
                ClearNight()
                    .foregroundColor(self.iconColor)
            }
        case .mainlyClear:
            ZStack {
                if isDay {
                    Sun()
                    #if os(watchOS)
                        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    #else
                        .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    #endif
                    .foregroundColor(sunColor)
                }
                else {
                    ClearNight()
                        .foregroundColor(self.iconColor)
                }
                Cloud()
                    .foregroundColor(Color.white)
                Cloud()
                    .stroke(lineWidth: 1)
                    .foregroundColor(Color.black)
            }
        case .lightCloud:
            Cloud().foregroundColor(self.iconColor)
        case .cloud:
            Cloud().foregroundColor(self.iconColor)
        case .rain:
            Rain(mm: Int(self.circleSegmentWidth)).foregroundColor(self.iconColor)
        case .lightning:
            Lightning().foregroundColor(self.iconColor)
        case .wind:
            Wind().foregroundColor(self.iconColor)
        case .fog:
            Fog().scale(0.8).foregroundColor(self.iconColor)
        case .snow:
            ZStack {
                SnowClouds().foregroundColor(self.iconColor)
                Snow().stroke(lineWidth: 1).foregroundColor(self.iconColor)
            }
        case .unknown:
            Text("")
        }
    }
}

struct SMHIWeatherData : Decodable {
    let timeSeries : [SMHIWeatherTimeslot]
}

struct SMHIWeatherTimeslot : Decodable {
    let validTime : Date
    let parameters : [SMHIWeatherParameter]
}

struct SMHIWeatherParameter : Decodable {
    let name : String
    let values : [Float]
}


struct OMWeatherData : Decodable {
    let hourly: OMHourly
    let daily: OMDaily
    let utc_offset_seconds: Int
}

struct OMHourly : Decodable {
    let cloudcover : [Int]
    let weathercode : [Int]
    let windspeed_10m : [Float]
    let precipitation : [Float]
    let time : [Date]
    let temperature_2m : [Float]
    let apparent_temperature : [Float]
    let uv_index : [Float]
}


struct OMDaily : Decodable {
    let time : [Date]
    let sunset : [Date]
    let sunrise : [Date]
}

struct WeatherSnapshot {
    let weather: [Date: Weather]
    let sunrise: [NaiveDate: Date]
    let sunset: [NaiveDate: Date]
    let utcOffsetSeconds: Int
}

func decodeOpenMeteoResponse(_ data: Data) -> WeatherSnapshot? {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    guard let result = try? decoder.decode(OMWeatherData.self, from: data) else {
        return nil
    }

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
        let apparentTemperature = result.hourly.apparent_temperature[i]
        let weatherSymbol = result.hourly.weathercode[i]
        let rainMillimeter = result.hourly.precipitation[i]
        let windspeed = result.hourly.windspeed_10m[i]
        let uvIndex = result.hourly.uv_index[i]
        guard let sunrise = sunriseDict[time.getNaiveDate()] else { continue }
        guard let sunset = sunsetDict[time.getNaiveDate()] else { continue }
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

        weatherDict[time] = Weather(
            time: time,
            temperature: temperature,
            weatherType: weatherType,
            rainMillimeter: rainMillimeter,
            isDay: isDay,
            uvIndex: uvIndex,
            apparentTemperature: apparentTemperature
        )
    }

    return WeatherSnapshot(
        weather: weatherDict,
        sunrise: sunriseDict,
        sunset: sunsetDict,
        utcOffsetSeconds: result.utc_offset_seconds
    )
}
