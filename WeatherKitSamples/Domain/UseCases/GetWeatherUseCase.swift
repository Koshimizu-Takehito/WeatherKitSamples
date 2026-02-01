import CoreLocation
import Foundation

// MARK: - WeatherFetchable

/// 天気情報を取得するユースケースのプロトコル
protocol WeatherFetchable: Sendable {
    /// 指定された位置の天気情報を取得する
    /// - Parameter location: 位置情報
    /// - Returns: 天気エンティティ
    func fetchWeather(for location: CLLocation) async throws -> WeatherEntity
}

// MARK: - WeatherFetcher

/// 天気情報を取得するユースケース
final class WeatherFetcher: WeatherFetchable, Sendable {
    private let weatherRepository: WeatherRepositoryProtocol

    init(weatherRepository: WeatherRepositoryProtocol) {
        self.weatherRepository = weatherRepository
    }

    func fetchWeather(for location: CLLocation) async throws -> WeatherEntity {
        try await weatherRepository.fetchWeather(for: location)
    }
}
