import Foundation

extension Date {
    func set(hour: Int? = nil, minute: Int? = nil) -> Date? {
        var dc = Calendar.current.dateComponents([.year, .month, .day, .hour], from: self)
        if let hour = hour {
            dc.hour = hour
        }
        if let minute = minute {
            dc.minute = minute
        }
        guard let result = Calendar.current.date(from: dc) else {
            return nil
        }
        return result
    }

    func setUTC(hour: Int? = nil, minute: Int? = nil) -> Date? {
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(identifier: "UTC")!
        var dc = utcCalendar.dateComponents([.year, .month, .day, .hour], from: self)
        if let hour = hour {
            dc.hour = hour
        }
        if let minute = minute {
            dc.minute = minute
        }
        guard let result = utcCalendar.date(from: dc) else {
            return nil
        }
        return result
    }

    func startOfDay(utcOffsetSeconds: Int) -> Date {
        // Calculate midnight in a timezone specified by UTC offset
        let localTimestamp = self.timeIntervalSince1970 + Double(utcOffsetSeconds)
        let secondsInDay: Double = 86400
        let midnightLocalTimestamp = floor(localTimestamp / secondsInDay) * secondsInDay
        return Date(timeIntervalSince1970: midnightLocalTimestamp - Double(utcOffsetSeconds))
    }
    
    static func from(year: Int, month: Int, day: Int) -> Date {
         let gregorianCalendar = NSCalendar(calendarIdentifier: .gregorian)!

         var dateComponents = DateComponents()
         dateComponents.year = year
         dateComponents.month = month
         dateComponents.day = day

         let date = gregorianCalendar.date(from: dateComponents)!
         return date
     }

    func hour() -> Int {
        return Calendar.current.dateComponents([.hour], from: self).hour!
    }
    
    func fractionalHour() -> Double {
        let dc = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        return Double(dc.hour!) + Double(dc.minute!) / 60.0
    }

    func fractionalHour(utcOffsetSeconds: Int) -> Double {
        // Calculate fractional hour in a timezone specified by UTC offset
        let localTimestamp = self.timeIntervalSince1970 + Double(utcOffsetSeconds)
        let secondsInDay: Double = 86400
        let secondsSinceMidnight = localTimestamp.truncatingRemainder(dividingBy: secondsInDay)
        return secondsSinceMidnight / 3600.0
    }
    
    func getNaiveDate() -> NaiveDate {
        let dc = Calendar.current.dateComponents([.year, .month, .day, .hour], from: self)
        return NaiveDate(year: dc.year!, month: dc.month!, day: dc.day!)
    }

    func getNaiveDate(utcOffsetSeconds: Int) -> NaiveDate {
        // Get the date in a specific timezone
        let localTimestamp = self.timeIntervalSince1970 + Double(utcOffsetSeconds)
        let date = Date(timeIntervalSince1970: localTimestamp)
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(identifier: "UTC")!
        let dc = utcCalendar.dateComponents([.year, .month, .day], from: date)
        return NaiveDate(year: dc.year!, month: dc.month!, day: dc.day!)
    }
    
    var jd: Double {
        let julianEpoch = 2440587.542
        return julianEpoch + timeIntervalSince1970 / (24 * 60 * 60)
    }
    
    var moonPhase: Double {
        return (jd - Date.from(year: 2000, month: 1, day: 6).jd).truncatingRemainder(dividingBy: 29.530588853)
    }
}
