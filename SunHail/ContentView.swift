// https://stackoverflow.com/questions/57334125/how-to-make-text-stroke-in-swiftui
// https://www.smhi.se/data/oppna-data/meteorologiska-data/api-for-vaderprognosdata-1.34233

// https://opendata-download-metfcst.smhi.se/api/category/pmp3g/version/2/geotype/point/lon/16.158/lat/58.5812/data.json
// json data:
//      t : temperature C
//      ws : wind speed m/s
//      tcc_mean : Mean value of total cloud cover (0-9)
//      pmin: Minimum precipitation intensity (mm/h)
//      pmax: Maximum precipitation intensity (mm/h)
//      pcat: Precipitation Category
//            0    No precipitation
//            1    Snow
//            2    Snow and rain
//            3    Rain
//            4    Drizzle
//            5    Freezing rain
//            6    Freezing drizzle
//      Wsymb2: Weather symbol
//            1    Clear sky
//            2    Nearly clear sky
//            3    Variable cloudiness
//            4    Halfclear sky
//            5    Cloudy sky
//            6    Overcast
//            7    Fog
//            8    Light rain showers
//            9    Moderate rain showers
//           10    Heavy rain showers
//           11    Thunderstorm
//           12    Light sleet showers
//           13    Moderate sleet showers
//           14    Heavy sleet showers
//           15    Light snow showers
//           16    Moderate snow showers
//           17    Heavy snow showers
//           18    Light rain
//           19    Moderate rain
//           20    Heavy rain
//           21    Thunder
//           22    Light sleet
//           23    Moderate sleet
//           24    Heavy sleet
//           25    Light snowfall
//           26    Moderate snowfall
//           27    Heavy snowfall

import SwiftUI
import CoreLocation
import Combine


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


struct Clock : View {
    var now: Date;
    var showDials: Bool
    @State var frame: CGSize = .zero
    var start : Int
    var weather : [Date: Weather]
    
    var body : some View {
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second, Calendar.Component.nanosecond], from: now)
        let minutes = Double(components.minute!)
        let hour = Double(components.hour!) + minutes / 60
//        let seconds = Double(components.second!) + Double(components.nanosecond!) / 1_000_000_000.0
        let color = showDials ? Color.white : Color.black

        ZStack {
            GeometryReader { (geometry) in
                self.makeView(geometry)
            }
            let strokeWidth = frame.width / 70
            ClockDial(now: now, progress: hour / 12, extraSize: 0.25).stroke(color, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
            ClockDial(now: now, progress: minutes / 60.0, extraSize: 0.45).stroke(color, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
//            ClockDial(now: now, progress: seconds / 60.0, extraSize: 0.9).stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round))
            Circle().trim(from: 0.0, to: 0.98).rotation(.degrees(-102)).stroke(Color.white).foregroundColor(Color.white).padding(frame.height * 0.2)
            ForEach(0..<12, id: \.self) { id in
                let weather = weather[datetimeToday(hour: id + start)]
                
                let radians : CGFloat = CGFloat.pi - 2.0 * CGFloat.pi / 12.0 * CGFloat(id)
                let size : CGFloat = frame.height * 0.4
                let x = sin(radians) * size + frame.width / 2
                let y = cos(radians) * size + frame.height / 2
                let iconSize = frame.height / 5
                
                if let weather = weather {
                    ZStack {
                        weather.icon()
                            .frame(width: iconSize, height: iconSize)
                            .position(x: x, y: y)
                            .foregroundColor(weather.iconColor())

                        Text("\(Int(weather.temperature))°")
                            .font(.system(size: iconSize / 3))
                            .position(x: x + 3, y: y)
                            .foregroundColor(weather.textColor())
                            .shadow(color: .black, radius: 0.5)
                            .shadow(color: .black, radius: 0.5)
                            .shadow(color: .black, radius: 0.5)
                            .shadow(color: .black, radius: 1)
                            .shadow(color: .black, radius: 1)
                    }
                }
                else {
                    Text("")
                }
            }
            ForEach(0..<12, id: \.self) { id in
                let time = datetimeToday(hour: id + start)
                let hour = Calendar.current.dateComponents([.hour], from: time).hour!
                let radians : CGFloat = CGFloat.pi - 2.0 * CGFloat.pi / 12.0 * CGFloat(id)
                let size : CGFloat = frame.height * 0.25
                let x = sin(radians) * size + frame.width / 2
                let y = cos(radians) * size + frame.height / 2
                Text("\(hour)").position(x: x, y: y).foregroundColor(Color.init(white: 0.4))
            }
        }
//        .background(Rectangle().foregroundColor(.red))
    }
    
    func makeView(_ geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async { self.frame = geometry.size }
        return Text("")
    }
}


struct ContentView: View {
    @State var now: Date = Date()
    @StateObject var locationProvider = LocationProvider()
    @State var weather : [Date: Weather] = [:]
    @State var cancellableLocation : AnyCancellable?
    @State var loadedURL : String = ""
    @State var timeOfData : Date = Date.init(timeIntervalSince1970: 0)
    @State var frame: CGSize = .zero

    let timer = Timer.publish(
        every: 10,  // seconds
        on: .main,
        in: .common
    ).autoconnect()

    func makeView(_ geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async { self.frame = geometry.size }
        return Text("")
    }

    var body: some View {
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.hour], from: now)
        
        ZStack {
            GeometryReader { (geometry) in
                self.makeView(geometry)
            }
            ScrollView(.vertical){
                let height = frame.width
                VStack {
                    Clock(now: now, showDials: components.hour! <= 12, start: 0, weather: weather).frame(height: height)
                    Clock(now: now, showDials: components.hour! > 12*1, start: 12*1, weather: weather).frame(height: height)
                    Clock(now: now, showDials: components.hour! > 12*2, start: 12*2, weather: weather).frame(height: height)
                    Clock(now: now, showDials: components.hour! > 12*3, start: 12*3, weather: weather).frame(height: height)
    //                Clock(now: now, showDials: components.hour! > 24, start: 36, weather: weather)
                }
            }
            .onReceive(timer) { input in
                now = input
            }
            .preferredColorScheme(.dark)
            .onAppear {
    //            weatherFromSMI()
                weatherFromOpenMeteo()
    //            fakeWeather()
            }
            
            VStack {
                Spacer()
                Link("Weather data by Open-Meteo.com", destination: URL(string: "https://open-meteo.com/")!).font(Font.system(size: 12)).foregroundColor(.gray)
            }
        }
    }
    
    func getWeather(hour: Int) -> Weather? {
        guard let date = Date.now.setHour(hour) else {
            return nil
        }
        return self.weather[date]
    }
    
    func fakeWeather() {
        let now = Date.now
        self.weather[now.setHour( 1)!] = Weather(time: now.setHour( 1)!, temperature:   1, weatherType:      .wind, rainMillimeter:  0)
        self.weather[now.setHour( 2)!] = Weather(time: now.setHour( 2)!, temperature:  10, weatherType:     .clear, rainMillimeter:  2)
        self.weather[now.setHour( 3)!] = Weather(time: now.setHour( 3)!, temperature:  13, weatherType: .lightning, rainMillimeter:  3)
        self.weather[now.setHour( 4)!] = Weather(time: now.setHour( 4)!, temperature:  14, weatherType:     .clear, rainMillimeter:  5)
        self.weather[now.setHour( 5)!] = Weather(time: now.setHour( 5)!, temperature:  16, weatherType:     .cloud, rainMillimeter:  6)
        self.weather[now.setHour( 6)!] = Weather(time: now.setHour( 6)!, temperature: -23, weatherType:      .wind, rainMillimeter:  8)
        self.weather[now.setHour( 7)!] = Weather(time: now.setHour( 7)!, temperature: -12, weatherType:      .rain, rainMillimeter:  9)
        self.weather[now.setHour( 8)!] = Weather(time: now.setHour( 8)!, temperature:  17, weatherType:      .wind, rainMillimeter: 10)
        self.weather[now.setHour( 9)!] = Weather(time: now.setHour( 9)!, temperature:  24, weatherType:     .cloud, rainMillimeter: 20)
        self.weather[now.setHour(10)!] = Weather(time: now.setHour(10)!, temperature:  35, weatherType: .lightning, rainMillimeter: 40)
        self.weather[now.setHour(11)!] = Weather(time: now.setHour(11)!, temperature:   1, weatherType:      .wind, rainMillimeter:  0)
        self.weather[now.setHour(12)!] = Weather(time: now.setHour(12)!, temperature:  10, weatherType:     .clear, rainMillimeter:  2)
        self.weather[now.setHour(13)!] = Weather(time: now.setHour(13)!, temperature:  13, weatherType: .lightning, rainMillimeter:  3)
        self.weather[now.setHour(14)!] = Weather(time: now.setHour(14)!, temperature:  14, weatherType:     .clear, rainMillimeter:  5)
        self.weather[now.setHour(15)!] = Weather(time: now.setHour(15)!, temperature:  16, weatherType:     .cloud, rainMillimeter:  6)
        self.weather[now.setHour(16)!] = Weather(time: now.setHour(16)!, temperature: -23, weatherType:      .wind, rainMillimeter:  8)
        self.weather[now.setHour(17)!] = Weather(time: now.setHour(17)!, temperature: -12, weatherType:      .rain, rainMillimeter:  9)
        self.weather[now.setHour(18)!] = Weather(time: now.setHour(18)!, temperature:  17, weatherType:      .wind, rainMillimeter: 10)
        self.weather[now.setHour(19)!] = Weather(time: now.setHour(19)!, temperature:  24, weatherType:     .cloud, rainMillimeter: 20)
        self.weather[now.setHour(20)!] = Weather(time: now.setHour(20)!, temperature:  35, weatherType: .lightning, rainMillimeter: 40)
        self.weather[now.setHour(21)!] = Weather(time: now.setHour(21)!, temperature:   1, weatherType:      .wind, rainMillimeter:  0)
        self.weather[now.setHour(22)!] = Weather(time: now.setHour(22)!, temperature:  10, weatherType:     .clear, rainMillimeter:  2)
        self.weather[now.setHour(23)!] = Weather(time: now.setHour(23)!, temperature:  13, weatherType: .lightning, rainMillimeter:  3)
        self.weather[now.setHour(24)!] = Weather(time: now.setHour(24)!, temperature:  14, weatherType:     .clear, rainMillimeter:  5)
        self.weather[now.setHour(25)!] = Weather(time: now.setHour(25)!, temperature:  16, weatherType:     .cloud, rainMillimeter:  6)
        self.weather[now.setHour(26)!] = Weather(time: now.setHour(26)!, temperature: -23, weatherType:      .wind, rainMillimeter:  8)
        self.weather[now.setHour(27)!] = Weather(time: now.setHour(27)!, temperature: -12, weatherType:      .rain, rainMillimeter:  9)
        self.weather[now.setHour(28)!] = Weather(time: now.setHour(28)!, temperature:  17, weatherType:      .wind, rainMillimeter: 10)
        self.weather[now.setHour(29)!] = Weather(time: now.setHour(29)!, temperature:  24, weatherType:     .cloud, rainMillimeter: 20)
        self.weather[now.setHour(30)!] = Weather(time: now.setHour(30)!, temperature:  35, weatherType: .lightning, rainMillimeter: 40)
        self.weather[now.setHour(31)!] = Weather(time: now.setHour(31)!, temperature:   1, weatherType:      .wind, rainMillimeter:  0)
        self.weather[now.setHour(32)!] = Weather(time: now.setHour(32)!, temperature:  10, weatherType:     .clear, rainMillimeter:  2)
        self.weather[now.setHour(33)!] = Weather(time: now.setHour(33)!, temperature:  13, weatherType: .lightning, rainMillimeter:  3)
        self.weather[now.setHour(34)!] = Weather(time: now.setHour(34)!, temperature:  14, weatherType:     .clear, rainMillimeter:  5)
        self.weather[now.setHour(35)!] = Weather(time: now.setHour(35)!, temperature:  16, weatherType:     .cloud, rainMillimeter:  6)
        self.weather[now.setHour(36)!] = Weather(time: now.setHour(36)!, temperature: -23, weatherType:      .wind, rainMillimeter:  8)
        self.weather[now.setHour(37)!] = Weather(time: now.setHour(37)!, temperature: -12, weatherType:      .rain, rainMillimeter:  9)
        self.weather[now.setHour(38)!] = Weather(time: now.setHour(38)!, temperature:  17, weatherType:      .wind, rainMillimeter: 10)
        self.weather[now.setHour(39)!] = Weather(time: now.setHour(39)!, temperature:  24, weatherType:     .cloud, rainMillimeter: 20)
    }
 
    func weatherFromOpenMeteo() {
        do {
            try locationProvider.start()
        }
        catch {
            print("No location access.")
            locationProvider.requestAuthorization()
        }
        
        cancellableLocation = locationProvider.locationWillChange.sink { loc in
            // handleLocation(loc)
            DispatchQueue.main.async {
                let s = "https://api.open-meteo.com/v1/forecast?latitude=\(loc.coordinate.latitude)&longitude=\(loc.coordinate.longitude)&hourly=temperature_2m,precipitation,weathercode,cloudcover,windspeed_10m&past_days=1"
                guard s != loadedURL && timeOfData.distance(to: Date.now) > 60*60 else {  // don't update more than once an hour
                    return
                }
                guard let url = URL(string: s) else {
                    return
                }
                loadedURL = s
                
                print("getting: \(url)")
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
//                                let string1 = String(data: data, encoding: String.Encoding.utf8) ?? "Data could not be printed"
//                                print(string1)
                                let decoder = JSONDecoder()
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
                                
                                decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.formatted(dateFormatter)
                                let result = try decoder.decode(OMWeatherData.self, from: data)
                                print("Parsed!")
                                
                                for i in 0..<result.hourly.time.count {
                                    let time = result.hourly.time[i]
                                    let temperature = result.hourly.temperature_2m[i]
                                    let weatherSymbol = result.hourly.weathercode[i]
                                    let rainMillimeter = result.hourly.precipitation[i]
                                                                     
                                    /*
                                     0              Clear sky
                                     1, 2, 3        Mainly clear, partly cloudy, and overcast
                                     45, 48         Fog and depositing rime fog
                                     51, 53, 55     Drizzle: Light, moderate, and dense intensity
                                     56, 57         Freezing Drizzle: Light and dense intensity
                                     61, 63, 65     Rain: Slight, moderate and heavy intensity
                                     66, 67         Freezing Rain: Light and heavy intensity
                                     71, 73, 75     Snow fall: Slight, moderate, and heavy intensity
                                     77             Snow grains
                                     80, 81, 82     Rain showers: Slight, moderate, and violent
                                     85, 86         Snow showers slight and heavy
                                     95 *           Thunderstorm: Slight or moderate
                                     96, 99 *       Thunderstorm with slight and heavy hail
                                     */
                                    
                                    let weatherType : WeatherType
                                    switch weatherSymbol {
                                    case 0...1:
                                        weatherType = .clear
                                    case 2...3:
                                        weatherType = .cloud
                                    case 51...67:
                                        weatherType = .rain
                                    case 80...86:
                                        weatherType = .rain
                                    case 95...99:
                                        weatherType = .lightning
                                    default:
                                        weatherType = .unknown
                                    }

                                    self.weather[time] = Weather(time: time, temperature: temperature, weatherType: weatherType, rainMillimeter: rainMillimeter)
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
    
    func weatherFromSMI() {
        do {
            try locationProvider.start()
        }
        catch {
            print("No location access.")
            locationProvider.requestAuthorization()
        }
        
        cancellableLocation = locationProvider.locationWillChange.sink { loc in
            // handleLocation(loc)
            DispatchQueue.main.async {
                let s = "https://opendata-download-metfcst.smhi.se/api/category/pmp3g/version/2/geotype/point/lon/\(loc.coordinate.longitude)/lat/\(loc.coordinate.latitude)/data.json"
                guard s != loadedURL && timeOfData.distance(to: Date.now) > 60*60 else {
                    return
                }
                guard let url = URL(string: s) else {
                    return
                }
                loadedURL = s
                
                print("getting: \(url)")
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
//                                let string1 = String(data: data, encoding: String.Encoding.utf8) ?? "Data could not be printed"
//                                print(string1)
                                let decoder = JSONDecoder()
                                decoder.dateDecodingStrategy = .iso8601
                                let result = try decoder.decode(SMHIWeatherData.self, from: data)
//                                print("Parsed!")
                                
                                for timeslot in result.timeSeries {
                                    var temperature : Float?
                                    var weatherSymbol : Int?
                                    var rainMillimeter : Float?
                                    
                                    for param in timeslot.parameters {
                                        switch param.name {
                                        case "t":
                                            temperature = param.values[0]
                                        case "Wsymb2":
                                            weatherSymbol = Int(param.values[0])
                                        case "pmin":
                                            rainMillimeter = param.values[0]
                                        default:
                                            ()
                                        }
                                    }
                                    
                                    guard let temperature = temperature,
                                          let weatherSymbol = weatherSymbol,
                                          let rainMillimeter = rainMillimeter
                                    else {
                                        continue
                                    }
                                    
                                    //      Wsymb2: Weather symbol
                                    //            1    Clear sky
                                    //            2    Nearly clear sky
                                    //            3    Variable cloudiness
                                    //            4    Halfclear sky
                                    //            5    Cloudy sky
                                    //            6    Overcast
                                    //            7    Fog
                                    //            8    Light rain showers
                                    //            9    Moderate rain showers
                                    //           10    Heavy rain showers
                                    //           11    Thunderstorm
                                    //           12    Light sleet showers
                                    //           13    Moderate sleet showers
                                    //           14    Heavy sleet showers
                                    //           15    Light snow showers
                                    //           16    Moderate snow showers
                                    //           17    Heavy snow showers
                                    //           18    Light rain
                                    //           19    Moderate rain
                                    //           20    Heavy rain
                                    //           21    Thunder
                                    //           22    Light sleet
                                    //           23    Moderate sleet
                                    //           24    Heavy sleet
                                    //           25    Light snowfall
                                    //           26    Moderate snowfall
                                    //           27    Heavy snowfall
                                    let weatherType : WeatherType
                                    switch weatherSymbol {
                                    case 1...4:
                                        weatherType = .clear
                                    case 6...7:
                                        weatherType = .cloud
                                        
                                    case 8...21:
                                        weatherType = .rain
                                    case 21:
                                        weatherType = .lightning
                                    default:
                                        weatherType = .unknown
                                    }

                                    self.weather[timeslot.validTime] = Weather(time: timeslot.validTime, temperature: temperature, weatherType: weatherType, rainMillimeter: rainMillimeter)
                                }
                            }
                        }
                        catch {
                            print("Error parsing")
                        }
                    }
                }
                task.resume()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
