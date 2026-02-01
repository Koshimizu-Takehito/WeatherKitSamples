import CoreLocation
import Foundation

// MARK: - Weather Repository

/// A repository implementation that provides weather data to the domain layer.
///
/// This class implements ``WeatherRepositoryProtocol`` and delegates data
/// fetching to a ``WeatherDataSourceProtocol`` instance. It serves as the
/// bridge between the domain and data layers.
///
/// ## Overview
///
/// The repository pattern in this architecture:
/// 1. Receives requests from use cases in the domain layer
/// 2. Delegates to the appropriate data source
/// 3. Transforms errors into domain-specific error types
///
/// ## Learning Points
///
/// - **Repository Pattern**: The repository abstracts data access, allowing
///   the domain layer to remain unaware of data source details.
/// - **Error Transformation**: Data source errors are wrapped in
///   ``WeatherRepositoryError`` for consistent error handling.
/// - **Dependency Injection**: The data source is injected, enabling
///   easy switching between production and mock implementations.
///
/// - SeeAlso: ``WeatherRepositoryProtocol`` for the interface definition.
/// - SeeAlso: ``WeatherDataSourceProtocol`` for the data source contract.
final class WeatherRepository: WeatherRepositoryProtocol, Sendable {
    private let dataSource: WeatherDataSourceProtocol

    /// Creates a new weather repository with the given data source.
    ///
    /// - Parameter dataSource: The data source to use for fetching weather.
    init(dataSource: WeatherDataSourceProtocol) {
        self.dataSource = dataSource
    }

    /// Fetches weather data for the specified location.
    ///
    /// Delegates to the data source and wraps any errors in
    /// ``WeatherRepositoryError/fetchFailed(underlying:)``.
    ///
    /// - Parameter location: The geographic location to fetch weather for.
    /// - Returns: A ``WeatherEntity`` containing weather data.
    /// - Throws: ``WeatherRepositoryError/fetchFailed(underlying:)`` on failure.
    func fetchWeather(for location: CLLocation) async throws -> WeatherEntity {
        do {
            return try await dataSource.fetchWeather(for: location)
        } catch {
            throw WeatherRepositoryError.fetchFailed(underlying: error)
        }
    }
}
