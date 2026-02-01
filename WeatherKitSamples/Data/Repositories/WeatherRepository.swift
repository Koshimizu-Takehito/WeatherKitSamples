import CoreLocation
import Foundation

// MARK: - Weather Repository

/// 天気リポジトリの実装
/// DataSourceを使用してデータを取得し、Domain層に提供する
final class WeatherRepository: WeatherRepositoryProtocol, Sendable {
    private let dataSource: WeatherDataSourceProtocol

    init(dataSource: WeatherDataSourceProtocol) {
        self.dataSource = dataSource
    }

    func fetchWeather(for location: CLLocation) async throws -> WeatherEntity {
        do {
            return try await dataSource.fetchWeather(for: location)
        } catch {
            throw WeatherRepositoryError.fetchFailed(underlying: error)
        }
    }
}
