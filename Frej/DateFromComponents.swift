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

    func hour() -> Int {
        return Calendar.current.dateComponents([.hour], from: self).hour!
    }
    
    func fractionalHour() -> Double {
        let dc = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        return Double(dc.hour!) + Double(dc.minute!) / 60.0
    }
    
    func getNaiveDate() -> NaiveDate {
        let dc = Calendar.current.dateComponents([.year, .month, .day, .hour], from: self)
        return NaiveDate(year: dc.year!, month: dc.month!, day: dc.day!)
    }
}
