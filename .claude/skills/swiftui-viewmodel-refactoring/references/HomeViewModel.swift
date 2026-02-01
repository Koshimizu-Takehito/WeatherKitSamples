import CoreLocation
import Foundation

// MARK: - View State

/// ホーム画面の表示状態
enum HomeViewState {
    case initial
    case loading
    case loaded(WeatherEntity)
    case error(String)

    /// 天気データ（loaded状態の場合のみ）
    var weather: WeatherEntity? {
        if case .loaded(let weather) = self { return weather }
        return nil
    }

    /// ローディング中かどうか
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

// MARK: - Home Action

/// ホーム画面のアクション
enum HomeAction {
    case fetchCurrentLocation
    case refresh
    case selectLocation(CLLocation, name: String)
}

// MARK: - Home View Model

/// ホーム画面のViewModel
@MainActor
@Observable
final class HomeViewModel {

    // MARK: - State

    private(set) var state: HomeViewState = .initial
    private(set) var locationName: String = "現在地を取得中..."

    // MARK: - Dependencies

    private let getWeatherUseCase: GetWeatherUseCaseProtocol
    private let getCurrentLocationUseCase: GetCurrentLocationUseCaseProtocol
    private var currentLocation: CLLocation?

    // MARK: - Initialization

    init(
        getWeatherUseCase: GetWeatherUseCaseProtocol,
        getCurrentLocationUseCase: GetCurrentLocationUseCaseProtocol
    ) {
        self.getWeatherUseCase = getWeatherUseCase
        self.getCurrentLocationUseCase = getCurrentLocationUseCase
    }

    // MARK: - Computed Properties

    var hasWeatherData: Bool {
        guard let weather = state.weather else { return false }
        return !weather.hourlyForecast.isEmpty || !weather.dailyForecast.isEmpty
    }

    // MARK: - Actions

    func handle(_ action: HomeAction) {
        Task {
            switch action {
            case .fetchCurrentLocation:
                await fetchWeather()
            case .refresh:
                await refreshWeather()
            case .selectLocation(let location, let name):
                await fetchWeather(for: location, name: name)
            }
        }
    }

    func refreshWeather() async {
        guard let location = currentLocation else {
            await fetchWeather()
            return
        }
        await performFetch {
            try await self.getWeatherUseCase.execute(for: location)
        }
    }

    // MARK: - Private Methods

    private func fetchWeather() async {
        await performFetch {
            let locationEntity = try await self.getCurrentLocationUseCase.execute()
            self.currentLocation = locationEntity.location
            self.locationName = locationEntity.name
            return try await self.getWeatherUseCase.execute(for: locationEntity.location)
        }
    }

    private func fetchWeather(for location: CLLocation, name: String) async {
        currentLocation = location
        locationName = name
        await performFetch {
            try await self.getWeatherUseCase.execute(for: location)
        }
    }

    private func performFetch(_ operation: () async throws -> WeatherEntity) async {
        state = .loading
        do {
            let weather = try await operation()
            state = .loaded(weather)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
