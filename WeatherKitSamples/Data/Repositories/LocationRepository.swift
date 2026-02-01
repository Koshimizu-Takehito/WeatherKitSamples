import CoreLocation
import Foundation
import MapKit

// MARK: - LocationRepository

/// A repository implementation that provides location services to the domain layer.
///
/// This class implements ``LocationRepositoryProtocol`` and handles all
/// location-related operations including GPS location, geocoding, and search.
///
/// ## Overview
///
/// The repository integrates with:
/// - **CoreLocation**: For device GPS location via `CLLocationManager`
/// - **MapKit**: For reverse geocoding and location search via `MKLocalSearch`
///
/// ## Learning Points
///
/// - **CLLocationManager Delegate**: Uses the delegate pattern with
///   `CheckedContinuation` to bridge callback-based APIs to async/await.
/// - **Permission Handling**: Manages location authorization states
///   and prompts for permission when needed.
/// - **Platform Differences**: Uses conditional compilation for
///   iOS vs macOS authorization methods.
///
/// ## Important
///
/// - Location permission must be requested before accessing location.
/// - The `@unchecked Sendable` conformance is necessary because
///   `CLLocationManager` is not `Sendable`.
///
/// - SeeAlso: ``LocationRepositoryProtocol`` for the interface definition.
/// - SeeAlso: [CLLocationManager](https://developer.apple.com/documentation/corelocation/cllocationmanager)
final class LocationRepository: NSObject, LocationRepositoryProtocol, @unchecked Sendable {
    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - LocationRepositoryProtocol

    /// Fetches the device's current GPS location.
    ///
    /// This method handles authorization state and requests permission
    /// if not yet determined. Uses `CLLocationManager.requestLocation()`
    /// for a single location update.
    ///
    /// - Returns: A ``LocationEntity`` with coordinates and place name.
    /// - Throws: ``LocationRepositoryError/denied`` if permission denied.
    /// - Throws: ``LocationRepositoryError/unknown`` if location unavailable.
    func getCurrentLocation() async throws -> LocationEntity {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            await requestAuthorization()
            return try await getCurrentLocation()

        case .restricted, .denied:
            throw LocationRepositoryError.denied

        case .authorizedWhenInUse, .authorizedAlways:
            break

        @unknown default:
            break
        }

        let location = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<CLLocation, Error>) in
            locationContinuation = continuation
            locationManager.requestLocation()
        }

        let name = try await getLocationName(for: location)

        return LocationEntity(
            coordinate: location.coordinate,
            name: name
        )
    }

    /// Retrieves a place name for the given coordinates using reverse geocoding.
    ///
    /// Uses MapKit's `MKReverseGeocodingRequest` to convert coordinates
    /// to a human-readable place name.
    ///
    /// - Parameter location: The geographic coordinates to reverse geocode.
    /// - Returns: A place name string, or a localized "Unknown Location" if unavailable.
    /// - Throws: ``LocationRepositoryError/searchFailed(underlying:)`` on error.
    func getLocationName(for location: CLLocation) async throws -> String {
        guard let request = MKReverseGeocodingRequest(location: location) else {
            return String(localized: .unknownLocation)
        }

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            request.getMapItems { items, error in
                if let error {
                    continuation.resume(throwing: LocationRepositoryError.searchFailed(underlying: error))
                    return
                }

                guard let item = items?.first else {
                    continuation.resume(returning: String(localized: .unknownLocation))
                    return
                }

                // Prefer MKMapItem's name property
                if let name = item.name, !name.isEmpty {
                    continuation.resume(returning: name)
                    return
                }

                // Fallback to generic location description
                continuation.resume(returning: String(localized: .unknownLocation))
            }
        }
    }

    /// Searches for locations matching the given query string.
    ///
    /// Uses MapKit's `MKLocalSearch` to perform natural language
    /// location searches (e.g., "Tokyo Tower", "Central Park").
    ///
    /// - Parameter query: The search keyword or phrase.
    /// - Returns: An array of ``LocationSearchResult`` items.
    /// - Throws: ``LocationRepositoryError/searchFailed(underlying:)`` on error.
    func searchLocations(query: String) async throws -> [LocationSearchResult] {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        searchRequest.resultTypes = .address

        let search = MKLocalSearch(request: searchRequest)

        do {
            let response = try await search.start()
            return response.mapItems.map { item -> LocationSearchResult in
                let coordinate = item.location.coordinate

                return LocationSearchResult(
                    title: item.name ?? "",
                    subtitle: "",
                    coordinate: coordinate
                )
            }
        } catch {
            throw LocationRepositoryError.searchFailed(underlying: error)
        }
    }

    // MARK: - Private Methods

    /// Requests location authorization from the user.
    ///
    /// Uses platform-specific authorization methods:
    /// - iOS: `requestWhenInUseAuthorization()`
    /// - macOS: `requestAlwaysAuthorization()`
    @MainActor
    private func requestAuthorization() async {
        #if os(macOS)
        locationManager.requestAlwaysAuthorization()
        #else
        locationManager.requestWhenInUseAuthorization()
        #endif
        try? await Task.sleep(for: .milliseconds(500))
    }
}

// MARK: CLLocationManagerDelegate

extension LocationRepository: CLLocationManagerDelegate {
    /// Handles successful location updates from CLLocationManager.
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        locationContinuation?.resume(returning: location)
        locationContinuation = nil
    }

    /// Handles location errors from CLLocationManager.
    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }
}
