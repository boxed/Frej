import Foundation

let UTC = TimeZone.init(secondsFromGMT: 0)!

struct NaiveDate : Hashable {
    let year : Int
    let month : Int
    let day : Int
}
