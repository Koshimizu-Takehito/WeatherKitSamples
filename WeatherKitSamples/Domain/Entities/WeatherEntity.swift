import CoreLocation
import Foundation

// MARK: - WeatherEntity

/// The root domain entity representing complete weather information.
///
/// This entity aggregates current conditions, hourly forecasts, and daily
/// forecasts into a single data structure. It is framework-agnostic and
/// serves as the canonical weather data representation in the domain layer.
///
/// ## Overview
///
/// `WeatherEntity` is returned by ``WeatherRepositoryProtocol/fetchWeather(for:)``
/// and contains all weather data needed by the presentation layer. The data
/// is mapped from WeatherKit's `Weather` type in the data layer.
///
/// ## Learning Points
///
/// - **Framework Isolation**: This entity has no dependencies on WeatherKit,
///   allowing the domain layer to remain testable and portable.
/// - **Composition**: Weather data is organized into nested entities
///   (current, hourly, daily) for clear separation of concerns.
///
/// - SeeAlso: ``CurrentWeatherEntity`` for current conditions.
/// - SeeAlso: ``HourlyForecastEntity`` for hourly predictions.
/// - SeeAlso: ``DailyForecastEntity`` for daily predictions.
struct WeatherEntity: Sendable {
    /// Current weather conditions at the location.
    let current: CurrentWeatherEntity

    /// Hourly forecast for the next 24+ hours.
    let hourlyForecast: [HourlyForecastEntity]

    /// Daily forecast for the next 10 days.
    let dailyForecast: [DailyForecastEntity]
}

// MARK: - CurrentWeatherEntity

/// Current weather conditions at a specific location.
///
/// Contains real-time weather data including temperature, humidity,
/// wind conditions, and atmospheric measurements.
///
/// ## Properties Overview
///
/// | Category | Properties |
/// |----------|------------|
/// | Temperature | `temperature`, `apparentTemperature`, `dewPoint` |
/// | Wind | `windSpeed`, `windDirection` |
/// | Atmosphere | `humidity`, `pressure`, `pressureTrend`, `visibility` |
/// | Sun | `uvIndex`, `uvIndexCategory` |
/// | Condition | `condition`, `symbolName` |
///
/// - SeeAlso: ``WeatherCondition`` for condition categories.
/// - SeeAlso: ``PressureTrend`` for pressure change indicators.
struct CurrentWeatherEntity: Sendable {
    /// The current temperature in Celsius.
    let temperature: Double

    /// The "feels like" temperature accounting for wind and humidity.
    let apparentTemperature: Double

    /// Relative humidity as a decimal (0.0 to 1.0).
    let humidity: Double

    /// Wind speed in meters per second.
    let windSpeed: Double

    /// Wind direction as a compass abbreviation (e.g., "N", "SW").
    let windDirection: String

    /// The current weather condition category.
    let condition: WeatherCondition

    /// SF Symbol name representing the weather condition.
    let symbolName: String

    /// UV index value (0-11+).
    let uvIndex: Int

    /// UV index category description (e.g., "Low", "High", "Extreme").
    let uvIndexCategory: String

    /// Atmospheric pressure in hectopascals (hPa).
    let pressure: Double

    /// The direction of pressure change.
    let pressureTrend: PressureTrend

    /// Visibility distance in meters.
    let visibility: Double

    /// Dew point temperature in Celsius.
    let dewPoint: Double
}

// MARK: - HourlyForecastEntity

/// Weather forecast for a specific hour.
///
/// Represents predicted weather conditions for a single hour,
/// used to display hourly forecast scrollers and charts.
///
/// - SeeAlso: ``DailyForecastEntity`` for daily predictions.
struct HourlyForecastEntity: Identifiable, Sendable {
    /// Unique identifier for list rendering.
    let id: UUID

    /// The date and time of this forecast.
    let date: Date

    /// Predicted temperature in Celsius.
    let temperature: Double

    /// SF Symbol name for the predicted condition.
    let symbolName: String

    /// Human-readable condition description.
    let condition: String

    /// Probability of precipitation as a decimal (0.0 to 1.0).
    let precipitationChance: Double

    /// Creates a new hourly forecast entity.
    ///
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - date: The forecast date and time.
    ///   - temperature: Predicted temperature in Celsius.
    ///   - symbolName: SF Symbol name for the condition.
    ///   - condition: Human-readable condition text.
    ///   - precipitationChance: Precipitation probability (0.0-1.0).
    init(
        id: UUID = UUID(),
        date: Date,
        temperature: Double,
        symbolName: String,
        condition: String,
        precipitationChance: Double
    ) {
        self.id = id
        self.date = date
        self.temperature = temperature
        self.symbolName = symbolName
        self.condition = condition
        self.precipitationChance = precipitationChance
    }
}

// MARK: - DailyForecastEntity

/// Weather forecast for a specific day.
///
/// Represents predicted weather conditions for a single day,
/// including high/low temperatures and precipitation chance.
///
/// - SeeAlso: ``HourlyForecastEntity`` for hourly predictions.
struct DailyForecastEntity: Identifiable, Sendable {
    /// Unique identifier for list rendering.
    let id: UUID

    /// The date of this forecast.
    let date: Date

    /// Predicted high temperature in Celsius.
    let highTemperature: Double

    /// Predicted low temperature in Celsius.
    let lowTemperature: Double

    /// SF Symbol name for the predicted condition.
    let symbolName: String

    /// Probability of precipitation as a decimal (0.0 to 1.0).
    let precipitationChance: Double

    /// Creates a new daily forecast entity.
    ///
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - date: The forecast date.
    ///   - highTemperature: Predicted high temperature in Celsius.
    ///   - lowTemperature: Predicted low temperature in Celsius.
    ///   - symbolName: SF Symbol name for the condition.
    ///   - precipitationChance: Precipitation probability (0.0-1.0).
    init(
        id: UUID = UUID(),
        date: Date,
        highTemperature: Double,
        lowTemperature: Double,
        symbolName: String,
        precipitationChance: Double
    ) {
        self.id = id
        self.date = date
        self.highTemperature = highTemperature
        self.lowTemperature = lowTemperature
        self.symbolName = symbolName
        self.precipitationChance = precipitationChance
    }
}

// MARK: - WeatherCondition

/// Enumeration of weather condition categories.
///
/// Maps WeatherKit's `WeatherCondition` values to a domain-specific
/// enum for use throughout the application.
///
/// ## Learning Points
///
/// - **Framework Isolation**: This enum mirrors WeatherKit's conditions
///   without depending on the framework, keeping the domain layer clean.
/// - **Localization Ready**: The `description` property provides
///   human-readable text that can be localized.
enum WeatherCondition: String, Sendable {
    case clear
    case mostlyClear
    case partlyCloudy
    case cloudy
    case mostlyCloudy
    case rain
    case drizzle
    case heavyRain
    case snow
    case heavySnow
    case flurries
    case thunderstorms
    case foggy
    case haze
    case unknown

    /// A localized description of the weather condition.
    var description: String {
        switch self {
        case .clear: "Clear"
        case .mostlyClear: "Mostly Clear"
        case .partlyCloudy: "Partly Cloudy"
        case .cloudy: "Cloudy"
        case .mostlyCloudy: "Mostly Cloudy"
        case .rain: "Rain"
        case .drizzle: "Drizzle"
        case .heavyRain: "Heavy Rain"
        case .snow: "Snow"
        case .heavySnow: "Heavy Snow"
        case .flurries: "Flurries"
        case .thunderstorms: "Thunderstorms"
        case .foggy: "Foggy"
        case .haze: "Haze"
        case .unknown: "Unknown"
        }
    }
}

// MARK: - PressureTrend

/// Indicates the direction of atmospheric pressure change.
///
/// Used to show whether pressure is rising, falling, or stable,
/// which can indicate approaching weather changes.
enum PressureTrend: String, Sendable {
    /// Pressure is increasing, often indicating improving weather.
    case rising

    /// Pressure is decreasing, often indicating approaching storms.
    case falling

    /// Pressure is stable with no significant change.
    case steady

    /// Pressure trend could not be determined.
    case unknown

    /// A localized description of the pressure trend.
    var description: String {
        switch self {
        case .rising: "Rising"
        case .falling: "Falling"
        case .steady: "Steady"
        case .unknown: ""
        }
    }
}

// MARK: - LocationEntity

/// A domain entity representing a geographic location.
///
/// Contains coordinates and a human-readable place name,
/// used to specify where weather data should be fetched.
///
/// - SeeAlso: ``LocationSearchResult`` for search-specific location data.
struct LocationEntity: Sendable {
    /// The geographic coordinates of the location.
    let coordinate: CLLocationCoordinate2D

    /// A human-readable name for the location (e.g., "Tokyo").
    let name: String

    /// A `CLLocation` instance created from the coordinate.
    var location: CLLocation {
        CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

// MARK: - CLLocationCoordinate2D + @retroactive @unchecked Sendable

extension CLLocationCoordinate2D: @retroactive @unchecked Sendable {}
