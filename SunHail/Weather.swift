import Foundation
import SwiftUI

enum WeatherType {
    case sun
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
    let temperature : Float
    let weatherType : WeatherType
    let rainMillimeter : Float
    
    func textColor() -> Color {
        switch self.weatherType {
        case .sun:
            return Color.init(hex: 0xFFFDB0)
        case .lightning:
            return Color.init(hex: 0x929292)
        case .cloud:
            return Color.init(hex: 0x929292)
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
        case .sun:
            return Color.init(hex: 0xF9E231)
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
    
    @ViewBuilder
    func icon() -> some View {
        switch self.weatherType {
        case .sun:
            Sun().stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
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

struct WeatherData : Decodable {
    let timeSeries : [WeatherTimeslot]
}

struct WeatherTimeslot : Decodable {
    let validTime : Date
    let parameters : [WeatherParameter]
}

struct WeatherParameter : Decodable {
    let name : String
    let values : [Float]
}
