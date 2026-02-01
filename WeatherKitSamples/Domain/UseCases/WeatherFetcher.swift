import CoreLocation
import Foundation

// MARK: - WeatherFetchable

/// A use case protocol for fetching weather information.
///
/// This protocol defines the interface for weather retrieval operations
/// in the domain layer. ViewModels depend on this protocol rather than
/// concrete implementations, enabling dependency injection and testing.
///
/// ## Overview
///
/// Use cases encapsulate business logic and orchestrate data flow between
/// the presentation and data layers. In this case, the use case is thin
/// and delegates directly to the repository, but it serves as a place to
/// add business rules if needed in the future.
///
/// ## Example
///
/// ```swift
/// let fetcher: WeatherFetchable = WeatherFetcher(weatherRepository: repository)
/// let weather = try await fetcher.fetchWeather(for: location)
/// print("Temperature: \(weather.current.temperature)°C")
/// ```
///
/// - SeeAlso: ``WeatherFetcher`` for the concrete implementation.
/// - SeeAlso: ``WeatherEntity`` for the returned data structure.
protocol WeatherFetchable: Sendable {
    /// Fetches weather information for the specified location.
    ///
    /// - Parameter location: The geographic location to fetch weather for.
    /// - Returns: A ``WeatherEntity`` containing current conditions and forecasts.
    /// - Throws: ``WeatherRepositoryError`` if the fetch operation fails.
    func fetchWeather(for location: CLLocation) async throws -> WeatherEntity
}

// MARK: - WeatherFetcher

/// A use case implementation that fetches weather data.
///
/// This class implements ``WeatherFetchable`` and delegates the actual
/// data fetching to a ``WeatherRepositoryProtocol`` instance. The use case
/// pattern allows for future expansion of business logic without modifying
/// the repository or view model layers.
///
/// ## Learning Points
///
/// - **Dependency Injection**: The repository is injected via the initializer,
///   making the use case testable with mock repositories.
/// - **Protocol-Oriented Design**: Conforms to ``WeatherFetchable``, allowing
///   ViewModels to depend on the protocol rather than this concrete class.
/// - **Sendable Conformance**: Marked as `Sendable` for safe use in async contexts.
///
/// - SeeAlso: ``WeatherFetchable`` for the protocol definition.
/// - SeeAlso: ``WeatherRepositoryProtocol`` for the data access interface.
final class WeatherFetcher: WeatherFetchable, Sendable {
    private let weatherRepository: WeatherRepositoryProtocol

    /// Creates a new weather fetcher with the given repository.
    ///
    /// - Parameter weatherRepository: The repository to use for data access.
    init(weatherRepository: WeatherRepositoryProtocol) {
        self.weatherRepository = weatherRepository
    }

    func fetchWeather(for location: CLLocation) async throws -> WeatherEntity {
        try await weatherRepository.fetchWeather(for: location)
    }
}
