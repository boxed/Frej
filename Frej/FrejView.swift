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

let weekday_number_to_string = [
    1: "Sunday",
    2: "Monday",
    3: "Tuesday",
    4: "Wednesday",
    5: "Thursday",
    6: "Friday",
    7: "Saturday",
]


func fromTo(sunrise: Date, sunset: Date, myStart: Double) -> (Double, Double) {
    let from = max(0, CGFloat(sunrise.fractionalHour() - myStart)) / 12.0
    var to = min(11.38, CGFloat(sunset.fractionalHour() - myStart)) / 12.0
    if from == 0 {
        // This and the weird ?: in the rotation for the cirlcle in Daylight is to correct for the circle starting half an hour before the hour starts
        to += 0.5 / 12
    }
    return (from, to)
}

struct Daylight : View {
    var start : Double
    var sunrise: Date?
    var sunset: Date?

    var body : some View {
        let myStart = start.truncatingRemainder(dividingBy: 24) + 0.5
        if let sunrise = sunrise, let sunset = sunset {
            let (from, to) = fromTo(sunrise: sunrise, sunset: sunset, myStart: myStart)
            Circle()
                .trim(from: from, to: to)
                .rotation(.degrees(from == 0 ? -105 : -90))
                .stroke(lineWidth: 2)
                .foregroundColor(sunColor)
                .scaleEffect(0.58)
        }
        else {
            Text("")
        }
    }
}

struct ClockInner : View {
    var weather : [Date: Weather]
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
        let weather = weather[datetimeToday(hour: id + start)]
        
        let radians : CGFloat = CGFloat.pi - 2.0 * CGFloat.pi / 12.0 * CGFloat(id)
        let size : CGFloat = frame.height * 0.4
        let x = sin(radians) * size + frame.width / 2 - 2
        let y = cos(radians) * size + frame.height / 2 - 2
        
        #if os(watchOS)
        let iconSize = frame.height / 4.5
        #else
        let iconSize = frame.height / 5
        #endif

        let textX = x + 3
        
        if let weather = weather {
            let font = Font.system(size: iconSize / 3)
            let temperature = Text("\(self.temperature(weather: weather))°")
            let text = temperature
                .foregroundColor(.black)
                .font(font)
            
            ZStack {
                if weather.rainMillimeter > 0 {
                    Circle()
                        .trim(from: 0.0, to: id == 11 ? 1/14 : 1/12)
                        .rotation(-.radians(radians - CGFloat.pi/2 + CGFloat.pi/12))
                        .stroke(weather.circleSegmentColor, lineWidth: weather.circleSegmentWidth + 1)
                        .scaleEffect(0.62)
                }

                weather.icon()
                    .frame(width: iconSize, height: iconSize)
                    .position(x: x, y: y)
                
                // "Border" hack
                ZStack {
                    text.position(x: textX + 1, y: y)
                    text.position(x: textX - 1, y: y)
                    text.position(x: textX + 1, y: y + 1)
                    text.position(x: textX - 1, y: y + 1)
                    text.position(x: textX + 1, y: y - 1)
                    text.position(x: textX - 1, y: y - 1)
                }
                ZStack {
                    text.position(x: textX, y: y + 1)
                    text.position(x: textX, y: y - 1)
                    text.position(x: textX + 1, y: y + 1)
                    text.position(x: textX + 1, y: y - 1)
                    text.position(x: textX - 1, y: y + 1)
                    text.position(x: textX - 1, y: y - 1)
                }
                
                // Actual text
                temperature
                    .font(font)
                    .position(x: textX, y: y)
                    .foregroundColor(weather.textColor)
            }
        }
    }
}

struct Clock : View {
    var now: Date;
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
            let startTime = now.addingTimeInterval(TimeInterval(start * 60 * 60))
            let components = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: now)
            let minutes = Double(components.minute!)
            let hour = startTime.fractionalHour()
    //        let seconds = Double(components.second!) + Double(components.nanosecond!) / 1_000_000_000.0
            let strokeWidth = frame.height / 70
            let weekday = calendar.dateComponents([.weekday], from: startTime).weekday!
            let weekdayStr = start == 0 ? "Today" : start % 24 == 0 ? weekday_number_to_string[weekday]! : ""

            ZStack {
                #if !os(watchOS)
                VStack {
                    Text("\(weekdayStr)").frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 10))
                    .padding()
                    Spacer()
                }
                #endif
                Daylight(start: Double(start), sunrise: sunrise[startTime.getNaiveDate()], sunset: sunset[startTime.getNaiveDate()])
                if showDials {
                    ClockDial(now: now, progress: hour / 12, extraSize: 0.25).stroke(Color.white, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                    ClockDial(now: now, progress: minutes / 60.0, extraSize: 0.45).stroke(Color.white, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                    // second
    //                ClockDial(now: now, progress: seconds / 60.0, extraSize: 0.5).stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                }
                ForEach(0..<12, id: \.self) { id in
                    ClockInner(weather: weather, start: start, frame: frame, id: id, unit: unit)
                }
                ForEach(0..<12, id: \.self) { id in
                    let time = datetimeToday(hour: id + start)
                    let hour = Calendar.current.dateComponents([.hour], from: time).hour!
                    let radians : CGFloat = CGFloat.pi - 2.0 * CGFloat.pi / 12.0 * CGFloat(id)
                    let size : CGFloat = frame.height * 0.25
                    let x = sin(radians) * size + frame.width / 2
                    let y = cos(radians) * size + frame.height / 2
                    Text("\(hour)").position(x: x, y: y)
                    .foregroundColor(Color.init(white: 0.4))
                    #if os(watchOS)
                    .font(.system(size: 9))
                    #endif
                }
                Circle()
                    .trim(from: 0.0, to: 0.99)
                    .rotation(.degrees(-105))
                    .stroke(Color.init(white: 0.3), lineWidth: 1)
                    .padding(frame.height * 0.2)
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
    
    var body: some View {
        TabView {
            #if os(watchOS)
            ForEach(0..<12, id: \.self) { id in
                let start1 = 12*id
                Clock(now: now, showDials: hour > start1,    start: start1,    weather: weather, sunrise: sunrise, sunset: sunset, unit: unit)
            }
            #else
            ForEach(0..<6, id: \.self) { id in
                VStack {
                    let i = id * 2
                    let start1 = 12*i
                    let start2 = 12*(i + 1)
                    Clock(now: now, showDials: hour > start1,    start: start1,    weather: weather, sunrise: sunrise, sunset: sunset, unit: unit).frame(height: height)
                    Clock(now: now, showDials: hour > start2, start: start2, weather: weather, sunrise: sunrise, sunset: sunset, unit: unit).frame(height: height)
                }
            }
            #endif
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(width: size.width, height: size.height)
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
    
    init() {
        self.hasChosenUnit = UserDefaults.standard.bool(forKey: "hasChosenUnit")
        self.unit = UserDefaults.standard.string(forKey: "unit") ?? "C"
    }
}

struct FrejView: View {
    @State var now: Date = Date()
    @StateObject var locationProvider = LocationProvider()
    @State var weather : [Date: Weather] = [:]
    @State var sunrise : [NaiveDate: Date] = [:]
    @State var sunset : [NaiveDate: Date] = [:]
    @State var cancellableLocation : AnyCancellable?
    @State var loadedURL : String = ""
    @State var timeOfData : Date = Date.init(timeIntervalSince1970: 0)
    @State var currentLocation : String = ""
    @State var showUnitChooser = false
    @ObservedObject var userSettings = UserSettings()

    let timer = Timer.publish(
        // seconds
        every: 10, // 0.05 to get a smooth second counter
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {
        if showUnitChooser {
            VStack {
                Button(action: {
                    userSettings.unit = "C"
                    userSettings.hasChosenUnit = true
                    showUnitChooser = false
                }) {
                    Text("Celsius").font(.system(size: 40)).padding()
                }
                Button(action: {
                    userSettings.unit = "F"
                    userSettings.hasChosenUnit = true
                    showUnitChooser = false
                }) {
                    Text("Fahrenheit").font(.system(size: 40))
                }
            }.preferredColorScheme(.dark)
        }
        else {
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
                    Foo(weather: weather, height: height, hour: hour, now: now, size: size, sunrise: sunrise, sunset: sunset, unit: userSettings.unit)
                }
                #if os(iOS)
                .ignoresSafeArea(.all, edges: .bottom)
                #endif
                .preferredColorScheme(.dark)
                .onAppear {
                    startLocationTracking()
                    fetchWeather()
                }
            }
            .onReceive(timer) { input in
                now = input
                if now.distance(to: timeOfData) > 60 * 60 {
                    timeOfData = now
                    fetchWeather()
                }
            }
        }
    }
    
    func getWeather(hour: Int) -> Weather? {
        guard let date = Date().setHour(hour) else {
            return nil
        }
        return self.weather[date]
    }
    
    func fetchWeather() {
        // weatherFromSMI()
//        fakeWeather()
        weatherFromOpenMeteo()
    }
    
    func fakeWeather() {
        let now = Date()
        self.weather[now.setHour( 0)!] = Weather(time: now.setHour( 0)!, temperature:   1, weatherType: .snow, rainMillimeter:   0, isDay: false)
        self.weather[now.setHour( 1)!] = Weather(time: now.setHour( 1)!, temperature:   1, weatherType: .mainlyClear, rainMillimeter:   0, isDay: false)
        self.weather[now.setHour( 2)!] = Weather(time: now.setHour( 2)!, temperature:   2, weatherType:       .clear, rainMillimeter:   1, isDay: false)
        self.weather[now.setHour( 3)!] = Weather(time: now.setHour( 3)!, temperature:   3, weatherType:   .lightning, rainMillimeter:   2, isDay: false)
        self.weather[now.setHour( 4)!] = Weather(time: now.setHour( 4)!, temperature:   4, weatherType:        .wind, rainMillimeter:   3, isDay: false)
        self.weather[now.setHour( 5)!] = Weather(time: now.setHour( 5)!, temperature:   5, weatherType:       .cloud, rainMillimeter:   4, isDay: false)
        self.weather[now.setHour( 6)!] = Weather(time: now.setHour( 6)!, temperature:  -6, weatherType:.  lightCloud, rainMillimeter:   5, isDay: false)
        self.weather[now.setHour( 7)!] = Weather(time: now.setHour( 7)!, temperature:  -7, weatherType:        .rain, rainMillimeter:   6, isDay:  true)
        self.weather[now.setHour( 8)!] = Weather(time: now.setHour( 8)!, temperature:   8, weatherType:        .wind, rainMillimeter:   7, isDay:  true)
        self.weather[now.setHour( 9)!] = Weather(time: now.setHour( 9)!, temperature:   9, weatherType:       .cloud, rainMillimeter:   9, isDay:  true)
        self.weather[now.setHour(10)!] = Weather(time: now.setHour(10)!, temperature:  10, weatherType:   .lightning, rainMillimeter:  10, isDay:  true)
        self.weather[now.setHour(11)!] = Weather(time: now.setHour(11)!, temperature:  11, weatherType:        .wind, rainMillimeter:  20, isDay:  true)
        self.weather[now.setHour(12)!] = Weather(time: now.setHour(12)!, temperature:  12, weatherType:       .clear, rainMillimeter:  30, isDay:  true)
        self.weather[now.setHour(13)!] = Weather(time: now.setHour(13)!, temperature:  13, weatherType:   .lightning, rainMillimeter:  40, isDay:  true)
        self.weather[now.setHour(14)!] = Weather(time: now.setHour(14)!, temperature:  14, weatherType:       .clear, rainMillimeter:  50, isDay:  true)
        self.weather[now.setHour(15)!] = Weather(time: now.setHour(15)!, temperature:  16, weatherType:       .cloud, rainMillimeter:  60, isDay:  true)
        self.weather[now.setHour(16)!] = Weather(time: now.setHour(16)!, temperature: -23, weatherType:        .wind, rainMillimeter:  70, isDay:  true)
        self.weather[now.setHour(17)!] = Weather(time: now.setHour(17)!, temperature: -12, weatherType:        .rain, rainMillimeter:  80, isDay:  true)
        self.weather[now.setHour(18)!] = Weather(time: now.setHour(18)!, temperature:  17, weatherType:        .wind, rainMillimeter:  90, isDay:  true)
        self.weather[now.setHour(19)!] = Weather(time: now.setHour(19)!, temperature:  24, weatherType:       .cloud, rainMillimeter: 100, isDay: false)
        self.weather[now.setHour(20)!] = Weather(time: now.setHour(20)!, temperature:  35, weatherType:   .lightning, rainMillimeter: 110, isDay: false)
        self.weather[now.setHour(21)!] = Weather(time: now.setHour(21)!, temperature:   1, weatherType:        .wind, rainMillimeter: 120, isDay: false)
        self.weather[now.setHour(22)!] = Weather(time: now.setHour(22)!, temperature:  10, weatherType:       .clear, rainMillimeter: 130, isDay: false)
        self.weather[now.setHour(23)!] = Weather(time: now.setHour(23)!, temperature:  13, weatherType:   .lightning, rainMillimeter: 140, isDay: false)
        self.weather[now.setHour(24)!] = Weather(time: now.setHour(24)!, temperature:  14, weatherType:       .clear, rainMillimeter:   5, isDay: false)
        self.weather[now.setHour(25)!] = Weather(time: now.setHour(25)!, temperature:  16, weatherType:       .cloud, rainMillimeter:   6, isDay: false)
        self.weather[now.setHour(26)!] = Weather(time: now.setHour(26)!, temperature: -23, weatherType:        .wind, rainMillimeter:   8, isDay: false)
        self.weather[now.setHour(27)!] = Weather(time: now.setHour(27)!, temperature: -12, weatherType:        .rain, rainMillimeter:   9, isDay: false)
        self.weather[now.setHour(28)!] = Weather(time: now.setHour(28)!, temperature:  17, weatherType:        .wind, rainMillimeter:  10, isDay: false)
        self.weather[now.setHour(29)!] = Weather(time: now.setHour(29)!, temperature:  24, weatherType:       .cloud, rainMillimeter:  20, isDay: false)
        self.weather[now.setHour(30)!] = Weather(time: now.setHour(30)!, temperature:  35, weatherType:   .lightning, rainMillimeter:  40, isDay: false)
        self.weather[now.setHour(31)!] = Weather(time: now.setHour(31)!, temperature:   1, weatherType:        .wind, rainMillimeter:   0, isDay: true)
        self.weather[now.setHour(32)!] = Weather(time: now.setHour(32)!, temperature:  10, weatherType:       .clear, rainMillimeter:   2, isDay:  true)
        self.weather[now.setHour(33)!] = Weather(time: now.setHour(33)!, temperature:  13, weatherType:   .lightning, rainMillimeter:   3, isDay:  true)
        self.weather[now.setHour(34)!] = Weather(time: now.setHour(34)!, temperature:  14, weatherType:       .clear, rainMillimeter:   5, isDay:  true)
        self.weather[now.setHour(35)!] = Weather(time: now.setHour(35)!, temperature:  16, weatherType:       .cloud, rainMillimeter:   6, isDay:  true)
        self.weather[now.setHour(36)!] = Weather(time: now.setHour(36)!, temperature: -23, weatherType:        .wind, rainMillimeter:   8, isDay:  true)
        self.weather[now.setHour(37)!] = Weather(time: now.setHour(37)!, temperature: -12, weatherType:        .rain, rainMillimeter:   9, isDay:  true)
        self.weather[now.setHour(38)!] = Weather(time: now.setHour(38)!, temperature:  17, weatherType:        .wind, rainMillimeter:  10, isDay:  true)
        self.weather[now.setHour(39)!] = Weather(time: now.setHour(39)!, temperature:  24, weatherType:       .cloud, rainMillimeter:  20, isDay:  true)
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
            geocoder.reverseGeocodeLocation(loc) { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    currentLocation = firstLocation?.locality ?? ""
                    
                    if firstLocation?.country ?? "unknown" == "United States" && !userSettings.hasChosenUnit {
                        showUnitChooser = true
                    }
                }
            }

            // handleLocation(loc)
            DispatchQueue.main.async {
                let s = "https://api.open-meteo.com/v1/forecast?latitude=\(loc.coordinate.latitude)&longitude=\(loc.coordinate.longitude)&hourly=temperature_2m,precipitation,weathercode,cloudcover,windspeed_10m&past_days=1&daily=sunrise,sunset&timezone=UTC&timeformat=unixtime"
                guard s != loadedURL && timeOfData.distance(to: Date()) > 60*60 else {  // don't update more than once an hour
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
                                let string1 = String(data: data, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                                print(string1)
                                let decoder = JSONDecoder()
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
                                
                                decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.secondsSince1970
                                let result = try decoder.decode(OMWeatherData.self, from: data)
                                print("Parsed!")
                                
                                for sunset_item in result.daily.sunset {
                                    self.sunset[sunset_item.getNaiveDate()] = sunset_item
                                }
                                for sunrise_item in result.daily.sunrise {
                                    self.sunrise[sunrise_item.getNaiveDate()] = sunrise_item
                                }

                                for i in 0..<result.hourly.time.count {
                                    let time = result.hourly.time[i]
                                    let temperature = result.hourly.temperature_2m[i]
                                    let weatherSymbol = result.hourly.weathercode[i]
                                    let rainMillimeter = result.hourly.precipitation[i]
                                    let windspeed = result.hourly.windspeed_10m[i]
                                    let sunrise = self.sunrise[time.getNaiveDate()]
                                    let sunset = self.sunset[time.getNaiveDate()]
                                    guard let sunrise = sunrise else {
                                        continue
                                    }
                                    guard let sunset = sunset else {
                                        continue
                                    }
                                    let isDay = time > sunrise && time < sunset
                                                                     
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
                                    
                                    var weatherType : WeatherType
                                    switch weatherSymbol {
                                    case 0:
                                        weatherType = .clear
                                    case 1:
                                        weatherType = .mainlyClear
                                    case 2:
                                        weatherType = .lightCloud
                                    case 3:
                                        weatherType = .cloud
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
                                    
                                    self.weather[time] = Weather(time: time, temperature: temperature, weatherType: weatherType, rainMillimeter: rainMillimeter, isDay: isDay)
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
                guard s != loadedURL && timeOfData.distance(to: Date()) > 60*60 else {
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

                                    self.weather[timeslot.validTime] = Weather(time: timeslot.validTime, temperature: temperature, weatherType: weatherType, rainMillimeter: rainMillimeter, isDay: true)
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
