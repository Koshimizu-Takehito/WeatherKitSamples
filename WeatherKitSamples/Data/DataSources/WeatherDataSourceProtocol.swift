import CoreLocation
import Foundation

// MARK: - Weather Data Source Protocol

/// A protocol defining the interface for weather data retrieval.
///
/// This protocol abstracts the data fetching layer, enabling seamless
/// switching between different data sources such as the WeatherKit API
/// and mock data for development and testing.
///
/// ## Overview
///
/// The data source protocol is implemented by:
/// - ``WeatherKitDataSource``: Production implementation using Apple's WeatherKit
/// - ``MockWeatherDataSource``: Mock implementation for development and testing
///
/// ## Learning Points
///
/// - **Strategy Pattern**: Different data source implementations can be
///   swapped at runtime through dependency injection.
/// - **Testability**: The mock implementation allows UI development and
///   testing without WeatherKit entitlements or network access.
///
/// - SeeAlso: ``WeatherKitDataSource`` for the WeatherKit implementation.
/// - SeeAlso: ``MockWeatherDataSource`` for the mock implementation.
protocol WeatherDataSourceProtocol: Sendable {
    /// Fetches weather information for the specified location.
    ///
    /// - Parameter location: The geographic location to fetch weather for.
    /// - Returns: A ``WeatherEntity`` containing current and forecast data.
    /// - Throws: An error if the weather data cannot be retrieved.
    func fetchWeather(for location: CLLocation) async throws -> WeatherEntity
}
