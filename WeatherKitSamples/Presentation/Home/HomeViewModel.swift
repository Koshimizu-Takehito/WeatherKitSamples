import CoreLocation
import Foundation

// MARK: - Home View Model

/// ホーム画面のViewModel
@MainActor
@Observable
final class HomeViewModel {
    // MARK: - Nested Types

    /// ホーム画面の表示状態
    enum State {
        case initial
        case loading
        case loaded(WeatherEntity)
        case error(String)

        /// 天気データ（loaded状態の場合のみ）
        var weather: WeatherEntity? {
            if case let .loaded(weather) = self { return weather }
            return nil
        }
    }

    // MARK: - State

    private(set) var state: State = .initial
    private(set) var locationName: String = "現在地を取得中..."

    // MARK: - Dependencies

    private let weatherFetcher: WeatherFetchable
    private let currentLocationFetcher: CurrentLocationFetchable
    private var currentLocation: CLLocation?

    // MARK: - Initialization

    init(weatherFetcher: WeatherFetchable, currentLocationFetcher: CurrentLocationFetchable) {
        self.weatherFetcher = weatherFetcher
        self.currentLocationFetcher = currentLocationFetcher
    }

    // MARK: - Computed Properties

    /// 天気データが利用可能かどうか
    var hasWeatherData: Bool {
        guard let weather = state.weather else { return false }
        return !weather.hourlyForecast.isEmpty || !weather.dailyForecast.isEmpty
    }

    /// チャート用の時間ごとデータ
    var hourlyChartData: [HourlyChartData] {
        state.weather?.hourlyForecast.map { HourlyChartData(from: $0) } ?? []
    }

    /// チャート用の日ごとデータ
    var dailyChartData: [DailyChartData] {
        state.weather?.dailyForecast.map { DailyChartData(from: $0) } ?? []
    }

    // MARK: - Methods

    /// 現在地の天気を取得する
    func fetchCurrentWeather() async {
        await loadWeather {
            let locationEntity = try await self.currentLocationFetcher.fetchCurrentLocation()
            self.currentLocation = locationEntity.location
            self.locationName = locationEntity.name
            return try await self.weatherFetcher.fetchWeather(for: locationEntity.location)
        }
    }

    /// 天気を更新する
    func refreshWeather() async {
        guard let location = currentLocation else {
            await fetchCurrentWeather()
            return
        }
        await loadWeather {
            try await self.weatherFetcher.fetchWeather(for: location)
        }
    }

    /// 指定した場所の天気を取得する
    func fetchWeather(for location: CLLocation, name: String) async {
        currentLocation = location
        locationName = name
        await loadWeather {
            try await self.weatherFetcher.fetchWeather(for: location)
        }
    }

    private func loadWeather(_ operation: () async throws -> WeatherEntity) async {
        state = .loading
        do {
            let weather = try await operation()
            state = .loaded(weather)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
