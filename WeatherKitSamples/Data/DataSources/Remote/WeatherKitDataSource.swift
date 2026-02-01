import CoreLocation
import Foundation
import WeatherKit

// MARK: - WeatherKit Data Source

/// A data source that fetches weather using Apple's WeatherKit framework.
///
/// This implementation demonstrates how to integrate WeatherKit into a
/// Clean Architecture project, mapping WeatherKit types to domain entities.
///
/// ## Overview
///
/// `WeatherKitDataSource` uses `WeatherService.shared` to request weather data
/// and maps the response to ``WeatherEntity`` for use in the domain layer.
///
/// ## Requirements
///
/// - **Apple Developer Program**: WeatherKit requires an active membership.
/// - **App ID Capability**: Enable WeatherKit capability in your App ID.
/// - **Entitlements**: Add WeatherKit entitlement to your app.
///
/// ## Learning Points
///
/// - **WeatherService**: The shared singleton that handles all WeatherKit requests.
/// - **Type Mapping**: WeatherKit types (`CurrentWeather`, `HourWeather`, etc.)
///   are mapped to framework-agnostic domain entities.
/// - **Measurement Handling**: WeatherKit uses `Measurement<Unit>` types;
///   extract `.value` for raw numbers.
///
/// ## Example
///
/// ```swift
/// let dataSource = WeatherKitDataSource()
/// let weather = try await dataSource.fetchWeather(for: location)
/// print("Current temp: \(weather.current.temperature)°C")
/// ```
///
/// - SeeAlso: [WeatherKit Documentation](https://developer.apple.com/documentation/weatherkit)
/// - SeeAlso: ``MockWeatherDataSource`` for development without WeatherKit.
final class WeatherKitDataSource: WeatherDataSourceProtocol, Sendable {
    /// The shared WeatherKit service instance.
    private let weatherService = WeatherService.shared

    /// Fetches weather data from WeatherKit for the specified location.
    ///
    /// This method requests current conditions, hourly forecasts, and daily
    /// forecasts from WeatherKit, then maps them to domain entities.
    ///
    /// - Parameter location: The geographic location to fetch weather for.
    /// - Returns: A ``WeatherEntity`` containing all weather data.
    /// - Throws: WeatherKit errors if the request fails.
    func fetchWeather(for location: CLLocation) async throws -> WeatherEntity {
        let weather = try await weatherService.weather(for: location)

        let currentWeather = mapCurrentWeather(weather.currentWeather)
        let hourlyForecast = mapHourlyForecast(weather.hourlyForecast)
        let dailyForecast = mapDailyForecast(weather.dailyForecast)

        return WeatherEntity(
            current: currentWeather,
            hourlyForecast: hourlyForecast,
            dailyForecast: dailyForecast
        )
    }

    // MARK: - Private Mapping Methods

    /// Maps WeatherKit's `CurrentWeather` to a domain entity.
    ///
    /// ## Mapping Details
    ///
    /// - Temperature values are extracted from `Measurement<UnitTemperature>`.
    /// - Wind speed is extracted from `Measurement<UnitSpeed>`.
    /// - Visibility is converted to kilometers before extraction.
    /// - Condition and pressure trend use dedicated mapping functions.
    private func mapCurrentWeather(_ weather: CurrentWeather) -> CurrentWeatherEntity {
        CurrentWeatherEntity(
            temperature: weather.temperature.value,
            apparentTemperature: weather.apparentTemperature.value,
            humidity: weather.humidity,
            windSpeed: weather.wind.speed.value,
            windDirection: weather.wind.compassDirection.description,
            condition: mapCondition(weather.condition),
            symbolName: weather.symbolName,
            uvIndex: weather.uvIndex.value,
            uvIndexCategory: weather.uvIndex.category.description,
            pressure: weather.pressure.value,
            pressureTrend: mapPressureTrend(weather.pressureTrend),
            visibility: weather.visibility.converted(to: .kilometers).value,
            dewPoint: weather.dewPoint.value
        )
    }

    /// Maps WeatherKit's hourly forecast to domain entities.
    ///
    /// Filters the forecast to include only the next 24 hours.
    private func mapHourlyForecast(_ forecast: Forecast<HourWeather>) -> [HourlyForecastEntity] {
        let now = Date()
        let next24Hours = now.addingTimeInterval(24 * 60 * 60)

        return forecast
            .filter { $0.date >= now && $0.date <= next24Hours }
            .map { hour in
                HourlyForecastEntity(
                    date: hour.date,
                    temperature: hour.temperature.value,
                    symbolName: hour.symbolName,
                    condition: hour.condition.description,
                    precipitationChance: hour.precipitationChance
                )
            }
    }

    /// Maps WeatherKit's daily forecast to domain entities.
    ///
    /// Limits the forecast to the next 10 days.
    private func mapDailyForecast(_ forecast: Forecast<DayWeather>) -> [DailyForecastEntity] {
        Array(forecast.prefix(10)).map { day in
            DailyForecastEntity(
                date: day.date,
                highTemperature: day.highTemperature.value,
                lowTemperature: day.lowTemperature.value,
                symbolName: day.symbolName,
                precipitationChance: day.precipitationChance
            )
        }
    }

    /// Maps WeatherKit's condition enum to the domain condition enum.
    ///
    /// This mapping isolates the domain layer from WeatherKit types,
    /// allowing the domain to remain framework-agnostic.
    private func mapCondition(_ condition: WeatherKit.WeatherCondition) -> WeatherKitSamples.WeatherCondition {
        switch condition {
        case .clear: .clear
        case .mostlyClear: .mostlyClear
        case .partlyCloudy: .partlyCloudy
        case .cloudy: .cloudy
        case .mostlyCloudy: .mostlyCloudy
        case .rain: .rain
        case .drizzle: .drizzle
        case .heavyRain: .heavyRain
        case .snow: .snow
        case .heavySnow: .heavySnow
        case .flurries: .flurries
        case .thunderstorms: .thunderstorms
        case .foggy: .foggy
        case .haze: .haze
        default: .unknown
        }
    }

    /// Maps WeatherKit's pressure trend to the domain pressure trend.
    private func mapPressureTrend(_ trend: WeatherKit.PressureTrend) -> WeatherKitSamples.PressureTrend {
        switch trend {
        case .rising: return .rising
        case .falling: return .falling
        case .steady: return .steady
        @unknown default: return .unknown
        }
    }
}
