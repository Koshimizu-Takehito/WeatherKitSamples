import SwiftUI

// MARK: - HourlyForecastView

/// Displays a horizontally scrollable list of hourly weather forecasts.
///
/// Each hour is rendered by ``HourlyForecastItemView`` inside a material
/// background card.
///
/// - SeeAlso: ``HourlyForecastEntity`` for the underlying data model.
struct HourlyForecastView {
    let forecast: [HourlyForecastEntity]
}

// MARK: View

extension HourlyForecastView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(.hourlyForecast, systemImage: "clock")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(forecast) { hour in
                        HourlyForecastItemView(forecast: hour)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - HourlyForecastViewPreview

private enum HourlyForecastViewPreview {
    static func makeForecast() -> [HourlyForecastEntity] {
        let now = Date()
        var result: [HourlyForecastEntity] = []

        for index in 0 ..< 24 {
            let date = now.addingTimeInterval(Double(index) * 3600)
            let temperature = Double(18 + (index % 5))
            let symbolName = index < 12 ? "sun.max.fill" : "cloud.sun.fill"
            let precipitationChance = index % 5 == 0 ? 0.2 : 0.0

            let entity = HourlyForecastEntity(
                date: date,
                temperature: temperature,
                symbolName: symbolName,
                condition: "晴れ",
                precipitationChance: precipitationChance
            )
            result.append(entity)
        }

        return result
    }
}

#Preview(traits: .modifier(.mock)) {
    ZStack {
        Color.blue.opacity(0.3).ignoresSafeArea()
        HourlyForecastView(forecast: HourlyForecastViewPreview.makeForecast())
            .padding()
    }
}
