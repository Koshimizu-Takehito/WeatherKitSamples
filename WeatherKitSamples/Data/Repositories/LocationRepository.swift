import CoreLocation
import Foundation
import MapKit

// MARK: - LocationRepository

/// 位置情報リポジトリの実装
final class LocationRepository: NSObject, LocationRepositoryProtocol, @unchecked Sendable {
    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - LocationRepositoryProtocol

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

    func getLocationName(for location: CLLocation) async throws -> String {
        guard let request = MKReverseGeocodingRequest(location: location) else {
            return "不明な場所"
        }

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            request.getMapItems { items, error in
                if let error {
                    continuation.resume(throwing: LocationRepositoryError.searchFailed(underlying: error))
                    return
                }

                guard let item = items?.first else {
                    continuation.resume(returning: "不明な場所")
                    return
                }

                // MKMapItemのnameを優先使用
                if let name = item.name, !name.isEmpty {
                    continuation.resume(returning: name)
                    return
                }

                // locationのdescriptionをフォールバックとして使用
                continuation.resume(returning: "不明な場所")
            }
        }
    }

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
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        locationContinuation?.resume(returning: location)
        locationContinuation = nil
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }
}
