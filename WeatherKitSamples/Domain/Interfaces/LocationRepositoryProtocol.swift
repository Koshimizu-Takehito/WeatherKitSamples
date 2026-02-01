import CoreLocation
import Foundation

// MARK: - LocationRepositoryProtocol

/// 位置情報のリポジトリインターフェース
protocol LocationRepositoryProtocol: Sendable {
    /// 現在地を取得する
    /// - Returns: 位置情報エンティティ
    func getCurrentLocation() async throws -> LocationEntity

    /// 位置情報から地名を取得する
    /// - Parameter location: 位置情報
    /// - Returns: 地名
    func getLocationName(for location: CLLocation) async throws -> String

    /// キーワードで位置を検索する
    /// - Parameter query: 検索キーワード
    /// - Returns: 検索結果の位置情報リスト
    func searchLocations(query: String) async throws -> [LocationSearchResult]
}

// MARK: - LocationSearchResult

/// 位置検索の結果
struct LocationSearchResult: Identifiable, Sendable {
    let id: UUID
    let title: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D

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

    var location: CLLocation {
        CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    var displayName: String {
        if subtitle.isEmpty {
            return title
        }
        return "\(title), \(subtitle)"
    }
}

// MARK: - LocationRepositoryError

/// 位置リポジトリのエラー
enum LocationRepositoryError: LocalizedError {
    case denied
    case unknown
    case geocodingFailed
    case searchFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .denied:
            "位置情報へのアクセスが拒否されています。設定から許可してください。"

        case .unknown:
            "位置情報の取得に失敗しました。"

        case .geocodingFailed:
            "地名の取得に失敗しました。"

        case let .searchFailed(error):
            "位置検索に失敗しました: \(error.localizedDescription)"
        }
    }
}
