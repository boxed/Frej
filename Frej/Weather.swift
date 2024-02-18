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
    case 0...2.5:
        return .light
    case 2.5...7.5:
        return .moderate
    case 7.5...50:
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
    let weatherType : WeatherType
    let rainMillimeter : Float
    let textColor : Color
    let circleSegmentColor : Color
    let circleSegmentWidth : CGFloat
    let isDay : Bool
    let iconColor : Color
    let rainIntensity : RainIntensity

    init(
        time : Date,
        temperature : Float,
        weatherType : WeatherType,
        rainMillimeter : Float,
        isDay : Bool
    ) {
        self.time = time
        self.temperature = temperature
        self.weatherType = weatherType
        self.rainMillimeter = rainMillimeter

        self.isDay = isDay
                
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
                    .foregroundColor(.white)
                Cloud()
                    .stroke(lineWidth: 1)
                    .foregroundColor(.black)
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
}

struct OMHourly : Decodable {
    let cloudcover : [Int]
    let weathercode : [Int]
    let windspeed_10m : [Float]
    let precipitation : [Float]
    let time : [Date]
    let temperature_2m : [Float]
}


struct OMDaily : Decodable {
    let sunset : [Date]
    let sunrise : [Date]
}
