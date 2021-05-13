// https://stackoverflow.com/questions/57334125/how-to-make-text-stroke-in-swiftui
// https://www.smhi.se/data/oppna-data/meteorologiska-data/api-for-vaderprognosdata-1.34233

import SwiftUI


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

struct Clock : View {
    var now: Date;
    var showDials: Bool
    @State var frame: CGSize = .zero
    
    var body : some View {
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second, Calendar.Component.nanosecond], from: now)
        let hour = Double(components.hour!)
        let minutes = Double(components.minute!)
        let seconds = Double(components.second!) + Double(components.nanosecond!) / 1_000_000_000.0
        let color = showDials ? Color.white : Color.gray

        ZStack {
            GeometryReader { (geometry) in
                self.makeView(geometry)
            }
            ClockDial(now: now, progress: hour / 12, extraSize: 0.4).stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
            ClockDial(now: now, progress: minutes / 60.0, extraSize: 0.9).stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
            ClockDial(now: now, progress: seconds / 60.0, extraSize: 0.9).stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round))
            ForEach((0..<12), id: \.self) { id in
                let radians : CGFloat = CGFloat.pi - 2.0 * CGFloat.pi / 12.0 * CGFloat(id)
                let size : CGFloat = frame.height / 2.0 * 1.2
                let x = sin(radians) * size + frame.width / 2
                let y = cos(radians) * size + frame.height / 2
                
                Text("\(id)").font(.system(size: 35)).position(x: x, y: y)
            }
        }
        .background(Circle().stroke(Color.white)).foregroundColor(Color.white)
        .padding(55)
    }
    
    func makeView(_ geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async { self.frame = geometry.size }
        return Text("")
    }
}

struct ContentView: View {
    @State var now: Date = Date()

    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.hour], from: now)
        
        VStack {
            Clock(now: now, showDials: components.hour! <= 12)
            .onReceive(timer) { input in
                now = input
            }

            Clock(now: now, showDials: components.hour! > 12)
            .onReceive(timer) { input in
                now = input
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
