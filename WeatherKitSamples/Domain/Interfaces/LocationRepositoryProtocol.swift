import CoreLocation
import Foundation

// MARK: - LocationRepositoryProtocol

/// A repository interface for location-related operations.
///
/// This protocol defines the contract for accessing device location and
/// performing geocoding operations. The domain layer depends only on this
/// protocol, allowing different implementations for production and testing.
///
/// ## Overview
///
/// Location operations include:
/// - Fetching the device's current GPS location
/// - Reverse geocoding coordinates to human-readable place names
/// - Searching for locations by keyword using MapKit
///
/// - Important: Location access requires user permission. Ensure authorization
///   is granted before calling ``getCurrentLocation()``.
/// - SeeAlso: ``LocationEntity`` for the location data structure.
/// - SeeAlso: ``LocationSearchResult`` for search result items.
/// - SeeAlso: ``LocationRepositoryError`` for possible errors.
protocol LocationRepositoryProtocol: Sendable {
    /// Fetches the device's current location.
    ///
    /// - Returns: A ``LocationEntity`` containing the current coordinates and place name.
    /// - Throws: ``LocationRepositoryError/denied`` if location permission is not granted.
    /// - Throws: ``LocationRepositoryError/unknown`` if location cannot be determined.
    /// - Precondition: Location services must be enabled and authorized.
    func getCurrentLocation() async throws -> LocationEntity

    /// Retrieves a human-readable place name for the given coordinates.
    ///
    /// Uses reverse geocoding to convert geographic coordinates into
    /// a locality name (e.g., "Tokyo", "San Francisco").
    ///
    /// - Parameter location: The geographic coordinates to reverse geocode.
    /// - Returns: A place name string for the location.
    /// - Throws: ``LocationRepositoryError/geocodingFailed`` if reverse geocoding fails.
    func getLocationName(for location: CLLocation) async throws -> String

    /// Searches for locations matching the given query string.
    ///
    /// Performs a natural language search using MapKit to find places
    /// that match the query (e.g., "Tokyo Tower", "Central Park").
    ///
    /// - Parameter query: The search keyword or phrase.
    /// - Returns: An array of ``LocationSearchResult`` matching the query.
    /// - Throws: ``LocationRepositoryError/searchFailed(underlying:)`` if the search fails.
    func searchLocations(query: String) async throws -> [LocationSearchResult]
}

// MARK: - LocationSearchResult

/// A search result item representing a found location.
///
/// This struct holds the data returned from a location search query,
/// including the place name and its geographic coordinates.
///
/// - SeeAlso: ``LocationRepositoryProtocol/searchLocations(query:)``
struct LocationSearchResult: Identifiable, Sendable {
    /// A unique identifier for this search result.
    let id: UUID

    /// The primary name of the location (e.g., "Tokyo Tower").
    let title: String

    /// Additional context about the location (e.g., "Minato, Tokyo").
    let subtitle: String

    /// The geographic coordinates of the location.
    let coordinate: CLLocationCoordinate2D

    /// Creates a new location search result.
    ///
    /// - Parameters:
    ///   - id: A unique identifier. Defaults to a new UUID.
    ///   - title: The primary name of the location.
    ///   - subtitle: Additional context or address information.
    ///   - coordinate: The geographic coordinates.
    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        coordinate: CLLocationCoordinate2D
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }

    /// A `CLLocation` instance created from the coordinate.
    var location: CLLocation {
        CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    /// A formatted display name combining title and subtitle.
    ///
    /// Returns just the title if subtitle is empty, otherwise
    /// returns "title, subtitle" format.
    var displayName: String {
        if subtitle.isEmpty {
            return title
        }
        return "\(title), \(subtitle)"
    }
}

// MARK: - LocationRepositoryError

/// Errors that can occur during location operations.
///
/// These errors are thrown by ``LocationRepositoryProtocol`` implementations
/// when location operations fail.
enum LocationRepositoryError: LocalizedError {
    /// Location access was denied by the user.
    ///
    /// The user has not granted location permission, or has explicitly
    /// denied access. Direct users to Settings to enable location access.
    case denied

    /// The location could not be determined for an unknown reason.
    case unknown

    /// Reverse geocoding failed to produce a place name.
    case geocodingFailed

    /// Location search failed with an underlying error.
    case searchFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .denied:
            "Location access denied. Please enable location services in Settings."

        case .unknown:
            "Failed to determine location."

        case .geocodingFailed:
            "Failed to retrieve place name."

        case let .searchFailed(error):
            "Location search failed: \(error.localizedDescription)"
        }
    }
}
