import CoreLocation
import Foundation

// MARK: - WeatherRepositoryProtocol

/// 天気データのリポジトリインターフェース
/// Domain層では具象実装を知らず、このプロトコルのみに依存する
protocol WeatherRepositoryProtocol: Sendable {
    /// 指定された位置の天気情報を取得する
    /// - Parameter location: 位置情報
    /// - Returns: 天気エンティティ
    func fetchWeather(for location: CLLocation) async throws -> WeatherEntity
}

// MARK: - WeatherRepositoryError

/// 天気リポジトリのエラー
enum WeatherRepositoryError: LocalizedError {
    case fetchFailed(underlying: Error)
    case invalidData
    case networkError

    var errorDescription: String? {
        switch self {
        case let .fetchFailed(error):
            "天気情報の取得に失敗しました: \(error.localizedDescription)"

        case .invalidData:
            "天気データが無効です"

        case .networkError:
            "ネットワークエラーが発生しました"
        }
    }
}
