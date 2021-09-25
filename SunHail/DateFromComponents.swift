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
}
