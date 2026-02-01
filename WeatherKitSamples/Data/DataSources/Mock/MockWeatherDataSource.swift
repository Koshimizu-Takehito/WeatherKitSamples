import CoreLocation
import Foundation

// MARK: - MockWeatherDataSource

/// A mock data source that returns sample weather data for development and testing.
///
/// This implementation provides realistic weather data without requiring
/// WeatherKit entitlements or network connectivity, making it ideal for:
/// - UI development and prototyping
/// - Unit and integration testing
/// - Demo and presentation purposes
///
/// ## Overview
///
/// The mock data source generates:
/// - Current weather conditions with typical values
/// - 24-hour hourly forecast with varying conditions
/// - 10-day daily forecast with temperature ranges
///
/// ## Usage
///
/// Enable mock mode in `AppDependencies`:
///
/// ```swift
/// let dependencies = AppDependencies(isMockDataEnabled: true)
/// ```
///
/// ## Learning Points
///
/// - **Simulated Latency**: Includes a 500ms delay to simulate network requests.
/// - **Realistic Data**: Generated data follows typical weather patterns.
/// - **Testability**: Enables UI testing without external dependencies.
///
/// - SeeAlso: ``WeatherKitDataSource`` for the production implementation.
final class MockWeatherDataSource: WeatherDataSourceProtocol, Sendable {
    /// Fetches mock weather data with a simulated network delay.
    ///
    /// - Parameter location: The location (ignored in mock implementation).
    /// - Returns: A ``WeatherEntity`` with sample weather data.
    func fetchWeather(for _: CLLocation) async throws -> WeatherEntity {
        // Simulate network latency for realistic behavior
        try await Task.sleep(for: .milliseconds(500))

        return WeatherEntity(
            current: generateCurrentWeather(),
            hourlyForecast: generateHourlyForecast(),
            dailyForecast: generateDailyForecast()
        )
    }

    // MARK: - Private Generation Methods

    /// Generates mock current weather conditions.
    private func generateCurrentWeather() -> CurrentWeatherEntity {
        CurrentWeatherEntity(
            temperature: 18.5,
            apparentTemperature: 17.0,
            humidity: 0.65,
            windSpeed: 12.5,
            windDirection: "NW",
            condition: .clear,
            symbolName: "sun.max.fill",
            uvIndex: 5,
            uvIndexCategory: "Moderate",
            pressure: 1013.25,
            pressureTrend: .steady,
            visibility: 10.0,
            dewPoint: 11.0
        )
    }

    /// Generates a 24-hour mock hourly forecast.
    private func generateHourlyForecast() -> [HourlyForecastEntity] {
        let now = Date()
        let conditions: [(String, WeatherCondition, Double)] = [
            ("sun.max.fill", .clear, 18),
            ("sun.max.fill", .clear, 19),
            ("cloud.sun.fill", .partlyCloudy, 20),
            ("cloud.sun.fill", .partlyCloudy, 21),
            ("cloud.fill", .cloudy, 20),
            ("cloud.fill", .cloudy, 19),
            ("cloud.sun.fill", .partlyCloudy, 18),
            ("sun.max.fill", .clear, 17),
            ("moon.stars.fill", .clear, 16),
            ("moon.fill", .clear, 15),
            ("moon.fill", .clear, 14),
            ("moon.fill", .clear, 13),
            ("moon.fill", .clear, 12),
            ("moon.fill", .clear, 12),
            ("sun.horizon.fill", .clear, 13),
            ("sun.max.fill", .clear, 15),
            ("sun.max.fill", .clear, 17),
            ("sun.max.fill", .clear, 19),
            ("sun.max.fill", .clear, 21),
            ("cloud.sun.fill", .partlyCloudy, 22),
            ("cloud.sun.fill", .partlyCloudy, 22),
            ("cloud.fill", .cloudy, 21),
            ("cloud.fill", .cloudy, 20),
            ("cloud.sun.fill", .partlyCloudy, 19),
        ]

        return conditions.enumerated().map { index, data in
            HourlyForecastEntity(
                date: now.addingTimeInterval(Double(index) * 3600),
                temperature: data.2,
                symbolName: data.0,
                condition: data.1.description,
                precipitationChance: index % 5 == 0 ? 0.2 : 0.0
            )
        }
    }

    /// Generates a 10-day mock daily forecast.
    private func generateDailyForecast() -> [DailyForecastEntity] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let forecasts: [(String, Double, Double, Double)] = [
            ("sun.max.fill", 22, 14, 0.0),
            ("cloud.sun.fill", 20, 13, 0.1),
            ("cloud.rain.fill", 18, 12, 0.7),
            ("cloud.rain.fill", 16, 11, 0.8),
            ("cloud.fill", 17, 10, 0.3),
            ("sun.max.fill", 19, 11, 0.0),
            ("sun.max.fill", 21, 12, 0.0),
            ("cloud.sun.fill", 20, 13, 0.1),
            ("cloud.sun.fill", 19, 12, 0.2),
            ("sun.max.fill", 22, 14, 0.0),
        ]

        return forecasts.enumerated().map { index, data in
            DailyForecastEntity(
                date: calendar.date(byAdding: .day, value: index, to: today)!,
                highTemperature: data.1,
                lowTemperature: data.2,
                symbolName: data.0,
                precipitationChance: data.3
            )
        }
    }
}

// MARK: - Multi-Day Hourly Forecast (for 3D Charts)

extension MockWeatherDataSource {
    /// Generates multi-day (3 days) hourly forecast data for 3D chart visualization.
    ///
    /// This method creates detailed hourly data across multiple days,
    /// which is used to demonstrate 3D charting capabilities with
    /// temperature variations throughout the day.
    ///
    /// ## Data Characteristics
    ///
    /// - **Temperature Pattern**: Follows a realistic diurnal cycle
    ///   (cooler at night, warmer during day).
    /// - **Day Offset**: Each subsequent day has a slight temperature offset
    ///   to show variation over time.
    /// - **Randomization**: Small random variations add realism.
    ///
    /// - Returns: An array of arrays, where each inner array contains
    ///   24 ``HourlyForecastEntity`` items for one day.
    func generateMultiDayHourlyForecast() -> [[HourlyForecastEntity]] {
        let calendar = Calendar.current
        let now = Date()

        return (0 ..< 3).map { dayOffset in
            let dayStart = calendar.date(byAdding: .day, value: dayOffset, to: calendar.startOfDay(for: now))!

            // Typical diurnal temperature pattern (coolest at ~5am, warmest at ~2pm)
            let baseTemps: [Double] = [
                12, 11, 10, 10, 11, 13, 15, 17, 19, 21, 22, 23,
                24, 24, 23, 22, 20, 18, 16, 15, 14, 13, 12, 12,
            ]

            // Offset each day's temperatures slightly
            let tempOffset = Double(dayOffset) * 1.5 - 1.5

            return (0 ..< 24).map { hour in
                let date = calendar.date(byAdding: .hour, value: hour, to: dayStart)!
                let temp = baseTemps[hour] + tempOffset + Double.random(in: -1 ... 1)
                let precipChance = hour >= 12 && hour <= 18 ? Double.random(in: 0 ... 0.4) : Double.random(in: 0 ... 0.1)

                let symbolName: String = if precipChance > 0.3 {
                    "cloud.rain.fill"
                } else if hour >= 6, hour < 18 {
                    precipChance > 0.1 ? "cloud.sun.fill" : "sun.max.fill"
                } else {
                    "moon.fill"
                }

                return HourlyForecastEntity(
                    date: date,
                    temperature: temp,
                    symbolName: symbolName,
                    condition: precipChance > 0.3 ? WeatherCondition.rain.description : WeatherCondition.clear.description,
                    precipitationChance: precipChance
                )
            }
        }
    }
}
