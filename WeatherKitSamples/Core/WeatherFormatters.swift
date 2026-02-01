import Foundation

// MARK: - WeatherFormatters

/// Formatting utilities for weather data display.
///
/// Provides static formatters and methods for converting raw weather values
/// (temperatures, percentages, wind speeds, etc.) into localized display strings.
///
/// ## Overview
///
/// All formatting is centralized here to ensure consistent display across
/// the app. Entity extensions below provide convenient computed properties
/// so Views can access formatted strings directly.
///
/// - SeeAlso: ``CurrentWeatherEntity`` for current weather formatting extensions.
/// - SeeAlso: ``HourlyForecastEntity`` for hourly forecast formatting extensions.
/// - SeeAlso: ``DailyForecastEntity`` for daily forecast formatting extensions.
enum WeatherFormatters {
    // MARK: - Date Formatters

    /// Formats a date as hour in Japanese style (e.g., "14時").
    static let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "H時"
        return formatter
    }()

    /// Formats a date as a Japanese day-of-week abbreviation (e.g., "月").
    static let dayOfWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E"
        return formatter
    }()

    /// Formats a date as a short month/day string (e.g., "3/15").
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter
    }()

    // MARK: - Temperature Formatting

    /// Formats a temperature value with the Celsius unit suffix (e.g., "18°C").
    ///
    /// - Parameter value: The temperature in degrees Celsius.
    /// - Returns: A formatted string with no decimal places.
    static func formatTemperature(_ value: Double) -> String {
        String(format: "%.0f°C", value)
    }

    /// Formats a temperature value with only the degree symbol (e.g., "18°").
    ///
    /// - Parameter value: The temperature in degrees Celsius.
    /// - Returns: A compact formatted string without the unit name.
    static func formatTemperatureShort(_ value: Double) -> String {
        String(format: "%.0f°", value)
    }

    // MARK: - Percentage Formatting

    /// Formats a 0.0–1.0 ratio as a percentage string (e.g., "65%").
    ///
    /// - Parameter value: A ratio where 1.0 represents 100%.
    /// - Returns: A formatted percentage string with no decimal places.
    static func formatPercentage(_ value: Double) -> String {
        String(format: "%.0f%%", value * 100)
    }

    // MARK: - Wind Speed Formatting

    /// Formats a wind speed value in km/h (e.g., "12.5 km/h").
    ///
    /// - Parameter value: The wind speed in kilometers per hour.
    static func formatWindSpeed(_ value: Double) -> String {
        String(format: "%.1f km/h", value)
    }

    // MARK: - Pressure Formatting

    /// Formats an atmospheric pressure value in hPa (e.g., "1013 hPa").
    ///
    /// - Parameter value: The pressure in hectopascals.
    static func formatPressure(_ value: Double) -> String {
        String(format: "%.0f hPa", value)
    }

    // MARK: - Visibility Formatting

    /// Formats a visibility distance in km (e.g., "10.0 km").
    ///
    /// - Parameter value: The visibility in kilometers.
    static func formatVisibility(_ value: Double) -> String {
        String(format: "%.1f km", value)
    }

    // MARK: - Day of Week Formatting

    /// Formats a date as a relative day label or day-of-week abbreviation.
    ///
    /// Returns "今日" for today, "明日" for tomorrow, or the abbreviated
    /// day-of-week (e.g., "月") for other dates.
    ///
    /// - Parameter date: The date to format.
    static func formatDayOfWeek(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            "今日"
        } else if Calendar.current.isDateInTomorrow(date) {
            "明日"
        } else {
            dayOfWeekFormatter.string(from: date)
        }
    }

    /// Formats a date as a Japanese hour string using ``hourFormatter``.
    static func formatHour(_ date: Date) -> String {
        hourFormatter.string(from: date)
    }

    /// Formats a date as a short month/day string using ``shortDateFormatter``.
    static func formatShortDate(_ date: Date) -> String {
        shortDateFormatter.string(from: date)
    }
}

// MARK: - CurrentWeatherEntity Formatting Extension

/// Convenience formatting properties for ``CurrentWeatherEntity``.
extension CurrentWeatherEntity {
    var temperatureString: String {
        WeatherFormatters.formatTemperature(temperature)
    }

    var apparentTemperatureString: String {
        WeatherFormatters.formatTemperature(apparentTemperature)
    }

    var humidityString: String {
        WeatherFormatters.formatPercentage(humidity)
    }

    var windSpeedString: String {
        WeatherFormatters.formatWindSpeed(windSpeed)
    }

    var pressureString: String {
        WeatherFormatters.formatPressure(pressure)
    }

    var visibilityString: String {
        WeatherFormatters.formatVisibility(visibility)
    }

    var dewPointString: String {
        WeatherFormatters.formatTemperature(dewPoint)
    }
}

// MARK: - HourlyForecastEntity Formatting Extension

/// Convenience formatting properties for ``HourlyForecastEntity``.
extension HourlyForecastEntity {
    var temperatureString: String {
        WeatherFormatters.formatTemperature(temperature)
    }

    var hourString: String {
        WeatherFormatters.formatHour(date)
    }

    var precipitationChanceString: String {
        WeatherFormatters.formatPercentage(precipitationChance)
    }
}

// MARK: - DailyForecastEntity Formatting Extension

/// Convenience formatting properties for ``DailyForecastEntity``.
extension DailyForecastEntity {
    var highTemperatureString: String {
        WeatherFormatters.formatTemperature(highTemperature)
    }

    var lowTemperatureString: String {
        WeatherFormatters.formatTemperature(lowTemperature)
    }

    var dayOfWeekString: String {
        WeatherFormatters.formatDayOfWeek(date)
    }

    var precipitationChanceString: String {
        WeatherFormatters.formatPercentage(precipitationChance)
    }
}
