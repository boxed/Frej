import Foundation
import SwiftUI

enum WeatherType {
    // TODO: Snow!!
    case clear
    case cloud
    case rain
    case lightning
    case wind
    case unknown
}

enum RainIntensity {
    case none
    case light
    case moderate
    case heavy
    case violent
}

struct Weather {
    let time : Date
    let temperature : Float
    let weatherType : WeatherType
    let rainMillimeter : Float
    
    func textColor() -> Color {
        switch self.weatherType {
        case .clear:
            if isDay() {
                return Color.init(hex: 0xFFFDB0)
            }
            else {
                return .white
            }
        case .lightning:
            return Color.init(hex: 0x929292)
        case .cloud:
            return Color.init(hex: 0xC2C2C2)
        case .rain:
            return Color.init(hex: 0xCDE9FF)
        case .wind:
            return Color.init(hex: 0xD5D5D5)
        case .unknown:
            return .gray
        }
    }
    
    func iconColor() -> Color {
        switch self.weatherType {
        case .clear:
            if isDay() {
                return Color.init(hex: 0xF9E231)
            }
            else {
                return .white
            }
        case .cloud:
            return Color.init(hex: 0x929292)
        case .rain:
            return Color.init(hex: 0x4F95CD);
        case .lightning:
            return Color.init(hex: 0xF9E231)
        default:
            return .white
        }
    }
    
    func isDay() -> Bool {
        let components = Calendar.current.dateComponents([.hour], from: time)
        return components.hour! > 6 && components.hour! < 20
    }
    
    @ViewBuilder
    func icon() -> some View {
        switch self.weatherType {
        case .clear:
            if isDay() {
                Sun().stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            }
            else {
                ClearNight()
            }
        case .cloud:
            Cloud()
        case .rain:
            Rain()
        case .lightning:
            Lightning()
        case .wind:
            Wind()
        case .unknown:
            Text("")
        }
    }
    
    func rainIntensity() -> RainIntensity {
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
    let hourly: OMFoo
}

struct OMFoo : Decodable {
    let cloudcover : [Int]
    let weathercode : [Int]
    let windspeed_10m : [Float]
    let precipitation : [Float]
    let time : [Date]
    let temperature_2m : [Float]
}
