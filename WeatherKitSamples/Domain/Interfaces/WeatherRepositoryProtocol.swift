import CoreLocation
import Foundation

// MARK: - WeatherRepositoryProtocol

/// A repository interface for fetching weather data.
///
/// This protocol defines the contract for weather data access in the domain layer.
/// The domain layer depends only on this protocol, not on concrete implementations,
/// enabling easy substitution of data sources (e.g., WeatherKit API vs. mock data).
///
/// ## Overview
///
/// In Clean Architecture, repository protocols live in the domain layer and are
/// implemented by the data layer. This inversion of dependencies keeps the domain
/// layer free from framework-specific code.
///
/// - SeeAlso: ``WeatherEntity`` for the returned weather data structure.
/// - SeeAlso: ``WeatherRepositoryError`` for possible errors.
protocol WeatherRepositoryProtocol: Sendable {
    /// Fetches weather information for the specified location.
    ///
    /// - Parameter location: The geographic location to fetch weather for.
    /// - Returns: A ``WeatherEntity`` containing current conditions and forecasts.
    /// - Throws: ``WeatherRepositoryError`` if the fetch operation fails.
    func fetchWeather(for location: CLLocation) async throws -> WeatherEntity
}

// MARK: - WeatherRepositoryError

/// Errors that can occur during weather data retrieval.
///
/// These errors are thrown by ``WeatherRepositoryProtocol`` implementations
/// when weather data cannot be fetched successfully.
///
/// - ``fetchFailed(underlying:)``: The underlying API request failed.
/// - ``invalidData``: The response data could not be parsed or validated.
/// - ``networkError``: A network connectivity issue prevented the request.
enum WeatherRepositoryError: LocalizedError {
    /// The weather fetch operation failed with an underlying error.
    case fetchFailed(underlying: Error)

    /// The received weather data was invalid or could not be parsed.
    case invalidData

    /// A network error occurred during the request.
    case networkError

    var errorDescription: String? {
        switch self {
        case let .fetchFailed(error):
            "Failed to fetch weather data: \(error.localizedDescription)"

        case .invalidData:
            "Invalid weather data received"

        case .networkError:
            "A network error occurred"
        }
    }
}
