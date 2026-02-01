import CoreLocation
import Foundation

// MARK: - Weather Data Source Protocol

/// 天気データソースのプロトコル
/// Remote/Mockの切り替えはこのプロトコルで抽象化される
protocol WeatherDataSourceProtocol: Sendable {
    /// 指定された位置の天気情報を取得する
    /// - Parameter location: 位置情報
    /// - Returns: 天気エンティティ
    func fetchWeather(for location: CLLocation) async throws -> WeatherEntity
}
