import Foundation
import SwiftUI

private let moon_bg_color = Color(#colorLiteral(red: 0.1407150751, green: 0.1515393104, blue: 0.1666932398, alpha: 1))
private let moon_slice_color = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))


struct MoonBackground : Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let diameter = Double(min(rect.width, rect.height))
        p.addEllipse(in: CGRect(
            origin: rect.origin, size: CGSize(width: diameter, height: diameter)
        ))
        return p
    }
}

struct MoonPhase : Shape {
    let date: Date
    
    func path(in rect: CGRect) -> Path {
        let phase = date.moonPhase
        let diameter = Double(min(rect.width, rect.height))
        let radius = CGFloat(diameter / 2)
        var p = Path()
        let center = CGPoint(x: radius, y: radius)
        
        let foo = 1.35
        let tanLength: CGFloat
        p.move(to: CGPoint(x: center.x, y: center.y + radius))
        if phase <= 15 {
            p.addCurve(
                to: CGPoint(
                    x: center.x,
                    y: center.y - radius
                ),
                control1: CGPoint(
                    x: center.x + radius*foo,
                    y: center.y + radius
                ),
                control2: CGPoint(
                    x: center.x + radius*foo,
                    y: center.y - radius
                )
            )
            
            tanLength = cos(phase * Double.pi/15)
        }
        else {
            p.addCurve(
                to: CGPoint(
                    x: center.x,
                    y: center.y - radius
                ),
                control1: CGPoint(
                    x: center.x - radius*foo,
                    y: center.y + radius
                ),
                control2: CGPoint(
                    x: center.x - radius*foo,
                    y: center.y - radius
                )
            )

            tanLength = -cos(phase * Double.pi/15)
        }
        
        p.addCurve(
            to: CGPoint(
                x: center.x,
                y: center.y + radius
            ),
            control1: CGPoint(
                x: center.x + radius*foo * tanLength,
                y: center.y - radius
            ),
            control2: CGPoint(
                x: center.x + radius*foo * tanLength,
                y: center.y + radius
            )
        )
        
        return p
    }
}

struct Moon: View {
    let date: Date
    var body: some View {
        ZStack {
            MoonBackground().fill(moon_bg_color)
            MoonPhase(date: date).fill(moon_slice_color)//.stroke(.red, lineWidth: 1)
        }
    }
}


struct Previews_Moon_Previews: PreviewProvider {
    static var previews: some View {
//                Text("\(Date.from(year: 1900, month: 3, day: 4).jd) == 2415082.5")
//                Text("\(Date.from(year: 2021, month: 3, day: 4).jd) == 2459277.5")
//                Text("\(Date.from(year: 2024, month: 3, day: 4).jd) == 2460373.5")
        VStack {
            ForEach(1..<10) { i in
                        let date = Date.from(year: 2024, month: 1, day: i+5)
//                        Text("2024-01-\(i)")
                        Moon(date: date)
                    }
        }.preferredColorScheme(.dark)
    }
}