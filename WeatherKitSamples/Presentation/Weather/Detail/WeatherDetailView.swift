import SwiftUI

// MARK: - WeatherDetailView

/// Displays detailed weather metrics in a two-column grid of cards.
///
/// Shows UV index, humidity, wind speed, atmospheric pressure, visibility,
/// and apparent temperature, each as a ``DetailCardView``.
///
/// - SeeAlso: ``CurrentWeatherEntity`` for the underlying data.
/// - SeeAlso: ``DetailCardView`` for the individual card component.
struct WeatherDetailView {
    let weather: CurrentWeatherEntity

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
}

// MARK: View

extension WeatherDetailView: View {
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            DetailCardView(
                title: String(localized: .uvIndex),
                value: "\(weather.uvIndex)",
                description: weather.uvIndexCategory,
                systemImage: "sun.max.fill",
                iconColor: uvIndexColor
            )

            DetailCardView(
                title: String(localized: .humidity),
                value: humidityString,
                description: String(localized: .dewPoint(dewPointString)),
                systemImage: "humidity.fill",
                iconColor: .cyan
            )

            DetailCardView(
                title: String(localized: .windSpeed),
                value: windSpeedString,
                description: windDirectionDescription,
                systemImage: "wind",
                iconColor: .teal
            )

            DetailCardView(
                title: String(localized: .pressure),
                value: pressureString,
                description: weather.pressureTrend.description,
                systemImage: "gauge.medium",
                iconColor: .indigo
            )

            DetailCardView(
                title: String(localized: .visibility),
                value: visibilityString,
                description: visibilityDescription,
                systemImage: "eye.fill",
                iconColor: .gray
            )

            DetailCardView(
                title: String(localized: .apparentTemperature),
                value: apparentTemperatureString,
                description: feelsLikeDescription,
                systemImage: "thermometer.medium",
                iconColor: .orange
            )
        }
    }

    // MARK: - Private Computed Properties

    private var uvIndexColor: Color {
        switch weather.uvIndex {
        case 0 ... 2: .green
        case 3 ... 5: .yellow
        case 6 ... 7: .orange
        case 8 ... 10: .red
        default: .purple
        }
    }

    private var humidityString: String {
        String(format: "%.0f%%", weather.humidity * 100)
    }

    private var dewPointString: String {
        String(format: "%.0f°C", weather.dewPoint)
    }

    private var windSpeedString: String {
        String(format: "%.1f km/h", weather.windSpeed)
    }

    private var windDirectionDescription: String {
        String(localized: .wind(weather.windDirection))
    }

    private var pressureString: String {
        String(format: "%.0f hPa", weather.pressure)
    }

    private var visibilityString: String {
        String(format: "%.1f km", weather.visibility)
    }

    private var visibilityDescription: String {
        if weather.visibility >= 10 {
            String(localized: .good)
        } else if weather.visibility >= 5 {
            String(localized: .moderate)
        } else {
            String(localized: .poor)
        }
    }

    private var apparentTemperatureString: String {
        String(format: "%.0f°C", weather.apparentTemperature)
    }

    private var feelsLikeDescription: String {
        let actual = weather.temperature
        let apparent = weather.apparentTemperature
        let diff = apparent - actual

        if abs(diff) < 2 {
            return String(localized: .similarToActualTemperature)
        } else if diff > 0 {
            return String(localized: .feelsWarmerThanActual)
        } else {
            return String(localized: .feelsColderThanActual)
        }
    }
}

#Preview(traits: .modifier(.mock)) {
    ZStack {
        Color.blue.opacity(0.3).ignoresSafeArea()
        WeatherDetailView(
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
            )
        )
        .padding()
    }
}
