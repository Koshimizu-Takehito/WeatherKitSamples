import CoreLocation
import Foundation
import WeatherKit

// MARK: - WeatherKit Data Source

/// WeatherKitを使用したリモートデータソース
final class WeatherKitDataSource: WeatherDataSourceProtocol, Sendable {
    private let weatherService = WeatherService.shared

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

    private func mapPressureTrend(_ trend: WeatherKit.PressureTrend) -> WeatherKitSamples.PressureTrend {
        switch trend {
        case .rising: return .rising
        case .falling: return .falling
        case .steady: return .steady
        @unknown default: return .unknown
        }
    }
}
