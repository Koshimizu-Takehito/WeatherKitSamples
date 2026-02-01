import SwiftUI

// MARK: - DailyForecastView

/// Displays a 10-day weather forecast in a vertical list.
///
/// Each day is rendered by ``DailyForecastItemView`` with a temperature
/// range bar normalized across the entire forecast period.
///
/// - SeeAlso: ``DailyForecastEntity`` for the underlying data model.
struct DailyForecastView {
    let forecast: [DailyForecastEntity]
}

// MARK: View

extension DailyForecastView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("10日間の天気", systemImage: "calendar")
                .font(.headline)

            VStack(spacing: 0) {
                ForEach(forecast) { day in
                    DailyForecastItemView(
                        forecast: day,
                        temperatureRange: temperatureRange
                    )

                    if day.id != forecast.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var temperatureRange: ClosedRange<Double> {
        let lows = forecast.map(\.lowTemperature)
        let highs = forecast.map(\.highTemperature)
        let min = lows.min() ?? 0
        let max = highs.max() ?? 30
        return min ... max
    }
}

#Preview(traits: .modifier(.mock)) {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())

    let forecast = (0 ..< 10).map { index in
        DailyForecastEntity(
            date: calendar.date(byAdding: .day, value: index, to: today)!,
            highTemperature: Double(20 + (index % 5)),
            lowTemperature: Double(12 + (index % 3)),
            symbolName: index % 3 == 0 ? "cloud.rain.fill" : "sun.max.fill",
            precipitationChance: index % 3 == 0 ? 0.7 : 0.0
        )
    }

    return ZStack {
        Color.blue.opacity(0.3).ignoresSafeArea()
        DailyForecastView(forecast: forecast)
            .padding()
    }
}
