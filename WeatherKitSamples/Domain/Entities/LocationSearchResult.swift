import CoreLocation
import Foundation

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
