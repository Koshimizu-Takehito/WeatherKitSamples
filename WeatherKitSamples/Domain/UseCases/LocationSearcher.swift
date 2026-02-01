import CoreLocation
import Foundation

// MARK: - LocationSearchable

/// A use case protocol for searching locations by keyword.
///
/// This protocol defines the interface for location search operations
/// in the domain layer. It enables users to find specific places by
/// name or address for weather queries.
///
/// ## Example
///
/// ```swift
/// let searcher: LocationSearchable = LocationSearcher(
///     locationRepository: repository
/// )
/// let results = try await searcher.searchLocations(query: "Tokyo")
/// for result in results {
///     print("\(result.title): \(result.subtitle)")
/// }
/// ```
///
/// - SeeAlso: ``LocationSearcher`` for the concrete implementation.
/// - SeeAlso: ``LocationSearchResult`` for the search result structure.
protocol LocationSearchable: Sendable {
    /// Searches for locations matching the given query.
    ///
    /// - Parameter query: The search keyword or phrase.
    /// - Returns: An array of ``LocationSearchResult`` items.
    /// - Throws: ``LocationRepositoryError/searchFailed(underlying:)`` on failure.
    func searchLocations(query: String) async throws -> [LocationSearchResult]
}

// MARK: - LocationSearcher

/// A use case implementation that searches for locations.
///
/// This class implements ``LocationSearchable`` and delegates the
/// search operation to a ``LocationRepositoryProtocol`` instance.
///
/// ## Learning Points
///
/// - **Separation of Concerns**: Search logic is separate from current
///   location fetching (``CurrentLocationFetcher``), following the
///   Single Responsibility Principle.
/// - **Testability**: By depending on ``LocationRepositoryProtocol``,
///   this use case can be tested with a mock repository.
///
/// - SeeAlso: ``LocationSearchable`` for the protocol definition.
/// - SeeAlso: ``CurrentLocationFetchable`` for current location operations.
final class LocationSearcher: LocationSearchable, Sendable {
    private let locationRepository: LocationRepositoryProtocol

    /// Creates a new location searcher with the given repository.
    ///
    /// - Parameter locationRepository: The repository to use for search operations.
    init(locationRepository: LocationRepositoryProtocol) {
        self.locationRepository = locationRepository
    }

    func searchLocations(query: String) async throws -> [LocationSearchResult] {
        try await locationRepository.searchLocations(query: query)
    }
}
