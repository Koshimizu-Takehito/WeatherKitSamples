import CoreLocation
import Foundation

// MARK: - CurrentLocationFetchable

/// A use case protocol for fetching the device's current location.
///
/// This protocol defines the interface for current location retrieval
/// in the domain layer. ViewModels depend on this protocol to obtain
/// the user's geographic position for weather queries.
///
/// ## Example
///
/// ```swift
/// let fetcher: CurrentLocationFetchable = CurrentLocationFetcher(
///     locationRepository: repository
/// )
/// let location = try await fetcher.fetchCurrentLocation()
/// print("Current location: \(location.name)")
/// ```
///
/// - Important: Requires location permission to be granted.
/// - SeeAlso: ``CurrentLocationFetcher`` for the concrete implementation.
/// - SeeAlso: ``LocationEntity`` for the returned data structure.
protocol CurrentLocationFetchable: Sendable {
    /// Fetches the device's current location.
    ///
    /// - Returns: A ``LocationEntity`` with coordinates and place name.
    /// - Throws: ``LocationRepositoryError/denied`` if permission is not granted.
    /// - Throws: ``LocationRepositoryError/unknown`` if location cannot be determined.
    func fetchCurrentLocation() async throws -> LocationEntity
}

// MARK: - CurrentLocationFetcher

/// A use case implementation that fetches the current device location.
///
/// This class implements ``CurrentLocationFetchable`` and delegates
/// location retrieval to a ``LocationRepositoryProtocol`` instance.
///
/// ## Learning Points
///
/// - **Single Responsibility**: This use case handles only current location
///   fetching, while ``LocationSearcher`` handles search operations.
/// - **Clean Architecture**: The use case depends on the repository protocol,
///   not on CoreLocation directly, keeping the domain layer clean.
///
/// - SeeAlso: ``CurrentLocationFetchable`` for the protocol definition.
/// - SeeAlso: ``LocationSearchable`` for location search operations.
final class CurrentLocationFetcher: CurrentLocationFetchable, Sendable {
    private let locationRepository: LocationRepositoryProtocol

    /// Creates a new location fetcher with the given repository.
    ///
    /// - Parameter locationRepository: The repository to use for location access.
    init(locationRepository: LocationRepositoryProtocol) {
        self.locationRepository = locationRepository
    }

    func fetchCurrentLocation() async throws -> LocationEntity {
        try await locationRepository.getCurrentLocation()
    }
}
