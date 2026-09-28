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

    // Midnight at the start of this date's day in the given time zone
    func startOfDay(in timeZone: TimeZone) -> Date {
        Calendar.gregorian(in: timeZone).startOfDay(for: self)
    }

    // The start of local clock hour `hours` counted from this midnight. Counting clock hours rather than adding
    // 3600 seconds per hour keeps later days lined up across a daylight saving change.
    func addingLocalHours(_ hours: Int, in timeZone: TimeZone) -> Date {
        let calendar = Calendar.gregorian(in: timeZone)
        let days = Int(floor(Double(hours) / 24))
        guard let day = calendar.date(byAdding: .day, value: days, to: self),
              let date = calendar.date(bySettingHour: hours - days * 24, minute: 0, second: 0, of: day) else {
            return addingTimeInterval(TimeInterval(hours * 3600))
        }
        return date
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

    // Hours since midnight on the local clock in the given time zone
    func fractionalHour(in timeZone: TimeZone) -> Double {
        let dc = Calendar.gregorian(in: timeZone).dateComponents([.hour, .minute, .second, .nanosecond], from: self)
        return Double(dc.hour!) + Double(dc.minute!) / 60 + (Double(dc.second!) + Double(dc.nanosecond!) / 1e9) / 3600
    }
    
    func getNaiveDate() -> NaiveDate {
        let dc = Calendar.current.dateComponents([.year, .month, .day, .hour], from: self)
        return NaiveDate(year: dc.year!, month: dc.month!, day: dc.day!)
    }

    func getNaiveDate(in timeZone: TimeZone) -> NaiveDate {
        let dc = Calendar.gregorian(in: timeZone).dateComponents([.year, .month, .day], from: self)
        return NaiveDate(year: dc.year!, month: dc.month!, day: dc.day!)
    }
}

extension Calendar {
    static func gregorian(in timeZone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }
}
