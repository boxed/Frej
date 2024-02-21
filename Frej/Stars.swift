import Foundation
import SwiftUI
import GameplayKit

struct RandomNumberGeneratorWithSeed: RandomNumberGenerator {
    init(seed: Int) { srand48(seed) }
    func next() -> UInt64 { return UInt64(drand48() * Double(UInt64.max)) }
}

func addStar(p: inout Path, s: CGFloat, x: CGFloat, y: CGFloat) {
    p.move(to:    CGPoint(x: x + (-0.35 + 0.32965) * s, y: y + (-0.15 + 0.10699)*s))
    p.addLine(to: CGPoint(x: x + (-0.35 + 0.32252) * s, y: y + (-0.15 + 0.12787)*s))
    p.addLine(to: CGPoint(x: x + (-0.35 + 0.2995 ) * s, y: y + (-0.15 + 0.12789)*s))
    p.addLine(to: CGPoint(x: x + (-0.35 + 0.31811) * s, y: y + (-0.15 + 0.14081)*s))
    p.addLine(to: CGPoint(x: x + (-0.35 + 0.31102) * s, y: y + (-0.15 + 0.16171)*s))
    p.addLine(to: CGPoint(x: x + (-0.35 + 0.32965) * s, y: y + (-0.15 + 0.14882)*s))
    p.addLine(to: CGPoint(x: x + (-0.35 + 0.34829) * s, y: y + (-0.15 + 0.16171)*s))
    p.addLine(to: CGPoint(x: x + (-0.35 + 0.3412 ) * s, y: y + (-0.15 + 0.14081)*s))
    p.addLine(to: CGPoint(x: x + (-0.35 + 0.35981) * s, y: y + (-0.15 + 0.12789)*s))
    p.addLine(to: CGPoint(x: x + (-0.35 + 0.33679) * s, y: y + (-0.15 + 0.12787)*s))
    p.closeSubpath()
}

struct Stars: Shape {
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        
//        p.move(to: rect.origin)
//        p.addLine(to: CGPoint(x: rect.midX, y: rect.midY))
        
        let step = 1.0
        let generator = RandomNumberGeneratorWithSeed(seed: 8927686389246)

        for y in Int(rect.origin.y) ..< Int(rect.height / step ) {
            for x in Int(rect.origin.x) ..< Int(rect.width / step ) {
                if generator.next() < UInt64.max/6000 {
                    addStar(p: &p, s: 100 * Double(generator.next()) / Double(UInt64.max), x: CGFloat(x) * step, y: CGFloat(y) * step)
                }
            }
        }
        
        _ = min(rect.size.width, rect.size.height)
//        addStar(p: &p, s: s, x: 0, y: 0)
        return p
    }
}


struct Previews_Stars_Previews: PreviewProvider {
    static var previews: some View {
        Stars().fill(.white).preferredColorScheme(.dark)
    }
}
