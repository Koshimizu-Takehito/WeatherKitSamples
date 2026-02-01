import SwiftUI

// MARK: - CurrentWeatherView

/// Displays the current weather conditions with temperature and location name.
///
/// Shows the SF Symbol for the current condition, the temperature,
/// a condition description, apparent temperature, and today's high/low
/// range when a ``DailyForecastEntity`` is provided.
///
/// - SeeAlso: ``CurrentWeatherEntity`` for the underlying data model.
struct CurrentWeatherView {
    let weather: CurrentWeatherEntity
    let locationName: String
    var todayForecast: DailyForecastEntity?
}

// MARK: View

extension CurrentWeatherView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text(locationName)
                .font(.title2)
                .fontWeight(.medium)

            Image(systemName: weather.symbolName)
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 80))
                .padding(.vertical, 8)

            Text(temperatureString)
                .font(.system(size: 64, weight: .thin))

            Text(weather.condition.description)
                .font(.title3)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Label("体感 \(apparentTemperatureString)", systemImage: "thermometer.medium")

                if let today = todayForecast {
                    Label("H:\(highTemperatureString(today)) L:\(lowTemperatureString(today))", systemImage: "arrow.up.arrow.down")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 32)
    }

    // MARK: - Private Helpers

    private var temperatureString: String {
        String(format: "%.0f°C", weather.temperature)
    }

    private var apparentTemperatureString: String {
        String(format: "%.0f°C", weather.apparentTemperature)
    }

    private func highTemperatureString(_ forecast: DailyForecastEntity) -> String {
        String(format: "%.0f°C", forecast.highTemperature)
    }

    private func lowTemperatureString(_ forecast: DailyForecastEntity) -> String {
        String(format: "%.0f°C", forecast.lowTemperature)
    }
}

#Preview(traits: .modifier(.mock)) {
    ZStack {
        Color.blue.opacity(0.3).ignoresSafeArea()
        CurrentWeatherView(
            weather: CurrentWeatherEntity(
                temperature: 18.5,
                apparentTemperature: 17.0,
                humidity: 0.65,
                windSpeed: 12.5,
                windDirection: "北西",
                condition: .clear,
                symbolName: "sun.max.fill",
                uvIndex: 5,
                uvIndexCategory: "中程度",
                pressure: 1013.25,
                pressureTrend: .steady,
                visibility: 10.0,
                dewPoint: 11.0
            ),
            locationName: "東京",
            todayForecast: DailyForecastEntity(
                date: Date(),
                highTemperature: 22,
                lowTemperature: 14,
                symbolName: "sun.max.fill",
                precipitationChance: 0.0
            )
        )
    }
}
