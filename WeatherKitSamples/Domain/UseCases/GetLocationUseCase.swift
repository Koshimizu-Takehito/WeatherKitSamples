import CoreLocation
import Foundation

// MARK: - CurrentLocationFetchable

/// 現在地を取得するユースケースのプロトコル
protocol CurrentLocationFetchable: Sendable {
    /// 現在地を取得する
    /// - Returns: 位置情報エンティティ
    func fetchCurrentLocation() async throws -> LocationEntity
}

// MARK: - CurrentLocationFetcher

/// 現在地を取得するユースケース
final class CurrentLocationFetcher: CurrentLocationFetchable, Sendable {
    private let locationRepository: LocationRepositoryProtocol

    init(locationRepository: LocationRepositoryProtocol) {
        self.locationRepository = locationRepository
    }

    func fetchCurrentLocation() async throws -> LocationEntity {
        try await locationRepository.getCurrentLocation()
    }
}

// MARK: - LocationSearchable

/// 位置を検索するユースケースのプロトコル
protocol LocationSearchable: Sendable {
    /// キーワードで位置を検索する
    /// - Parameter query: 検索キーワード
    /// - Returns: 検索結果の位置情報リスト
    func searchLocations(query: String) async throws -> [LocationSearchResult]
}

// MARK: - LocationSearcher

/// 位置を検索するユースケース
final class LocationSearcher: LocationSearchable, Sendable {
    private let locationRepository: LocationRepositoryProtocol

    init(locationRepository: LocationRepositoryProtocol) {
        self.locationRepository = locationRepository
    }

    func searchLocations(query: String) async throws -> [LocationSearchResult] {
        try await locationRepository.searchLocations(query: query)
    }
}
