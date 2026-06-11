import Foundation
import SwiftUI

enum WeatherType {
    case clear
    case mainlyClear
    case lightCloud
    case mediumCloud
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
    case .mediumCloud:
        return Color.init(hex: 0xDADADA)
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
    case .mediumCloud:
        return Color.init(hex: 0xC8C8C8)
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

// Below this cloud-cover percentage the sky reads as clear (sun shows); above it,
// clouds darken smoothly with cover rather than snapping between discrete tiers.
let clearCloudCoverCutoff = 15

// 0 (thin white cloud) ... 1 (heavy dark overcast). Returns nil when there is no cloud band.
func cloudBandShade(weatherType: WeatherType, cloudCover: Int, rain: Bool) -> Double? {
    if rain || weatherType == .lightning {
        return 1.0
    }
    switch weatherType {
    case .cloud:
        if cloudCover <= 0 { return 1.0 } // hand-authored demo data with no cloud-cover value
        return min(1.0, max(0.0, Double(cloudCover - clearCloudCoverCutoff) / Double(100 - clearCloudCoverCutoff)))
    case .mediumCloud:
        return 0.5
    case .lightCloud:
        return 0.12
    default:
        return nil
    }
}

private func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double { a + (b - a) * t }

// White (shade 0) interpolated to the heavy-overcast grey (shade 1) used for the dial band.
func cloudBandColor(shade: Double) -> Color {
    let s = min(1.0, max(0.0, shade))
    return Color(red: lerp(1.0, 0.3568909366, s), green: lerp(1.0, 0.3843440824, s), blue: lerp(1.0, 0.4227784864, s))
}

// White (shade 0) interpolated to 0x929292 (shade 1) for the small cloud glyph.
func cloudIconColor(cloudCover: Int) -> Color {
    let shade = cloudBandShade(weatherType: .cloud, cloudCover: cloudCover, rain: false) ?? 1.0
    let v = lerp(1.0, Double(0x92) / 255.0, shade)
    return Color(red: v, green: v, blue: v)
}

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
    let cloudCover : Int

    init(
        time : Date,
        temperature : Float,
        weatherType : WeatherType,
        rainMillimeter : Float,
        isDay : Bool,
        uvIndex : Float = 0,
        apparentTemperature : Float? = nil,
        cloudCover : Int = 0
    ) {
        self.time = time
        self.temperature = temperature
        self.apparentTemperature = apparentTemperature ?? temperature
        self.weatherType = weatherType
        self.rainMillimeter = rainMillimeter

        self.isDay = isDay
        self.uvIndex = uvIndex
        self.cloudCover = cloudCover

        self.circleSegmentColor = rainMillimeter > 0 ? rainColor : .white
        self.circleSegmentWidth = max(1, CGFloat(log(rainMillimeter) * 10))
        self.textColor = _textColor(isDay: isDay, weatherType: weatherType)
        // Overcast clouds shade continuously with cloud cover; everything else keeps its fixed colour.
        if weatherType == .cloud && cloudCover > 0 {
            self.iconColor = cloudIconColor(cloudCover: cloudCover)
        } else {
            self.iconColor = _iconColor(weatherType: weatherType, isDay: isDay)
        }
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
        case .mediumCloud:
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
        let cloudcover = result.hourly.cloudcover[i]
        let rainMillimeter = result.hourly.precipitation[i]
        let windspeed = result.hourly.windspeed_10m[i]
        let uvIndex = result.hourly.uv_index[i]
        guard let sunrise = sunriseDict[time.getNaiveDate()] else { continue }
        guard let sunset = sunsetDict[time.getNaiveDate()] else { continue }
        let isDay = time > sunrise && time < sunset

        var weatherType: WeatherType
        switch weatherSymbol {
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
            // Clear/cloudy is driven by cloudcover %, not the coarse weathercode.
            // Below the cutoff the sky is clear; above it we mark it cloudy and let
            // the renderer shade the cloud continuously from the cloudCover value.
            weatherType = cloudcover < clearCloudCoverCutoff ? .clear : .cloud
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
            apparentTemperature: apparentTemperature,
            cloudCover: cloudcover
        )
    }

    return WeatherSnapshot(
        weather: weatherDict,
        sunrise: sunriseDict,
        sunset: sunsetDict,
        utcOffsetSeconds: result.utc_offset_seconds
    )
}
