import WidgetKit
import SwiftUI

struct FrejWidgetView: View {
    var entry: FrejEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            Color.black
            if let snapshot = entry.snapshot {
                content(snapshot: snapshot)
            } else {
                emptyState
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func content(snapshot: WeatherSnapshot) -> some View {
        let now = entry.date
        let fractionalHour = now.fractionalHour(utcOffsetSeconds: snapshot.utcOffsetSeconds)
        let startOfToday = now.startOfDay(utcOffsetSeconds: snapshot.utcOffsetSeconds)

        let firstStart = fractionalHour < 12 ? 0 : 12
        let secondStart = firstStart + 12
        let firstStartD = Double(firstStart)
        let secondStartD = Double(secondStart)
        let firstShowDials = fractionalHour > firstStartD - 0.5 && fractionalHour < firstStartD + 12 - 0.5
        let secondShowDials = fractionalHour > secondStartD - 0.5 && fractionalHour < secondStartD + 12 - 0.5

        // Each clock in systemSmall and systemMedium renders at roughly half the
        // size of systemLarge, so thin out sun/rain/snow rays to stay readable.
        let densityScale: Double = (family == .systemSmall || family == .systemMedium) ? 0.5 : 1.0

        switch family {
        case .systemMedium:
            HStack(spacing: 0) {
                clock(
                    start: firstStart,
                    showDials: firstShowDials,
                    snapshot: snapshot,
                    now: now,
                    startOfToday: startOfToday,
                    densityScale: densityScale
                )
                clock(
                    start: secondStart,
                    showDials: secondShowDials,
                    snapshot: snapshot,
                    now: now,
                    startOfToday: startOfToday,
                    densityScale: densityScale
                )
            }
        default:
            clock(
                start: firstStart,
                showDials: firstShowDials,
                snapshot: snapshot,
                now: now,
                startOfToday: startOfToday,
                densityScale: densityScale
            )
        }
    }

    private func clock(
        start: Int,
        showDials: Bool,
        snapshot: WeatherSnapshot,
        now: Date,
        startOfToday: Date,
        densityScale: Double
    ) -> some View {
        Clock(
            now: now,
            startOfToday: startOfToday,
            showDials: showDials,
            start: start,
            weather: snapshot.weather,
            sunrise: snapshot.sunrise,
            sunset: snapshot.sunset,
            unit: entry.unit,
            showUVRays: entry.showUVRays,
            utcOffsetSeconds: snapshot.utcOffsetSeconds,
            useApparentTemperature: entry.useApparentTemperature,
            densityScale: densityScale
        )
        .aspectRatio(1, contentMode: .fit)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "sun.max")
                .font(.system(size: 36))
                .foregroundColor(.yellow)
            Text("Open Frej to set up")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
