import Foundation

// MARK: - WeatherFormatters

/// 天気データのフォーマットユーティリティ
enum WeatherFormatters {
    // MARK: - Date Formatters

    static let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "H時"
        return formatter
    }()

    static let dayOfWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E"
        return formatter
    }()

    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter
    }()

    // MARK: - Temperature Formatting

    static func formatTemperature(_ value: Double) -> String {
        String(format: "%.0f°C", value)
    }

    static func formatTemperatureShort(_ value: Double) -> String {
        String(format: "%.0f°", value)
    }

    // MARK: - Percentage Formatting

    static func formatPercentage(_ value: Double) -> String {
        String(format: "%.0f%%", value * 100)
    }

    // MARK: - Wind Speed Formatting

    static func formatWindSpeed(_ value: Double) -> String {
        String(format: "%.1f km/h", value)
    }

    // MARK: - Pressure Formatting

    static func formatPressure(_ value: Double) -> String {
        String(format: "%.0f hPa", value)
    }

    // MARK: - Visibility Formatting

    static func formatVisibility(_ value: Double) -> String {
        String(format: "%.1f km", value)
    }

    // MARK: - Day of Week Formatting

    static func formatDayOfWeek(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            "今日"
        } else if Calendar.current.isDateInTomorrow(date) {
            "明日"
        } else {
            dayOfWeekFormatter.string(from: date)
        }
    }

    static func formatHour(_ date: Date) -> String {
        hourFormatter.string(from: date)
    }

    static func formatShortDate(_ date: Date) -> String {
        shortDateFormatter.string(from: date)
    }
}

// MARK: - CurrentWeatherEntity Formatting Extension

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
