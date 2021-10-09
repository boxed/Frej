import Foundation

extension Date {
    func setHour(_ hour: Int) -> Date? {
        var dc = Calendar.current.dateComponents([.year, .month, .day, .hour], from: self)
        dc.hour = hour
        guard let result = Calendar.current.date(from: dc) else {
            return nil
        }
        return result
    }
    
    func hour() -> Int {
        return Calendar.current.dateComponents([.hour], from: self).hour!
    }
    
    func fractionalHour() -> Double {
        let dc = Calendar.current.dateComponents(in: UTC, from: self)
        return Double(dc.hour!) + Double(dc.minute!) / 60.0
    }
    
    func getNaiveDate() -> NaiveDate {
        let dc = Calendar.current.dateComponents([.year, .month, .day, .hour], from: self)
        return NaiveDate(year: dc.year!, month: dc.month!, day: dc.day!)
    }
}
