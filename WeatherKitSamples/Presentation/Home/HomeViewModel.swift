import CoreLocation
import Foundation

// MARK: - Home View Model

/// The view model for the home screen.
///
/// Manages weather data fetching and state for the main weather display.
/// Uses `@Observable` for SwiftUI integration and `@MainActor` for thread safety.
///
/// ## Overview
///
/// This view model handles:
/// - Fetching weather for the current device location
/// - Fetching weather for a user-selected location
/// - Managing loading, error, and loaded states
/// - Providing chart-ready data transformations
///
/// ## Thread Safety
///
/// This class is isolated to the main actor (`@MainActor`), ensuring all
/// property access and method calls occur on the main thread. This is
/// required for safe SwiftUI state updates.
///
/// ## Learning Points
///
/// - **@Observable**: Enables automatic SwiftUI view updates without `@Published`.
/// - **@MainActor**: Guarantees main thread execution for UI safety.
/// - **State Enum**: Represents discrete screen states for clean UI logic.
/// - **Dependency Injection**: Uses case protocols for testability.
///
/// - SeeAlso: ``HomeView`` for the corresponding view.
/// - SeeAlso: ``WeatherFetchable`` for the weather data dependency.
@MainActor
@Observable
final class HomeViewModel {
    // MARK: - Nested Types

    /// Represents the current state of the home screen.
    ///
    /// The view uses this enum to determine which UI to display,
    /// with a 1:1 mapping between states and view components.
    enum State {
        /// Initial state before any data is loaded.
        case initial

        /// Currently fetching weather data.
        case loading

        /// Weather data successfully loaded.
        case loaded(WeatherEntity)

        /// An error occurred during data fetching.
        case error(String)

        /// The weather entity if in loaded state, nil otherwise.
        var weather: WeatherEntity? {
            if case let .loaded(weather) = self { return weather }
            return nil
        }
    }

    // MARK: - State

    /// The current state of the view model.
    ///
    /// - Note: Use `private(set)` to allow external reading but
    ///   prevent external modification.
    private(set) var state: State = .initial

    /// The display name of the current location.
    private(set) var locationName: String = .init(localized: "Fetching location...")

    // MARK: - Dependencies

    private let weatherFetcher: WeatherFetchable
    private let currentLocationFetcher: CurrentLocationFetchable
    private var currentLocation: CLLocation?

    // MARK: - Initialization

    /// Creates a new home view model with the given dependencies.
    ///
    /// - Parameters:
    ///   - weatherFetcher: The use case for fetching weather data.
    ///   - currentLocationFetcher: The use case for fetching device location.
    init(weatherFetcher: WeatherFetchable, currentLocationFetcher: CurrentLocationFetchable) {
        self.weatherFetcher = weatherFetcher
        self.currentLocationFetcher = currentLocationFetcher
    }

    // MARK: - Computed Properties

    /// Indicates whether weather data is available for display.
    var hasWeatherData: Bool {
        guard let weather = state.weather else { return false }
        return !weather.hourlyForecast.isEmpty || !weather.dailyForecast.isEmpty
    }

    /// Hourly forecast data formatted for chart display.
    ///
    /// Transforms ``HourlyForecastEntity`` into ``HourlyChartData``
    /// for use with Swift Charts.
    var hourlyChartData: [HourlyChartData] {
        state.weather?.hourlyForecast.map { HourlyChartData(from: $0) } ?? []
    }

    /// Daily forecast data formatted for chart display.
    ///
    /// Transforms ``DailyForecastEntity`` into ``DailyChartData``
    /// for use with Swift Charts.
    var dailyChartData: [DailyChartData] {
        state.weather?.dailyForecast.map { DailyChartData(from: $0) } ?? []
    }

    // MARK: - Methods

    /// Fetches weather for the device's current location.
    ///
    /// Requests the current GPS location, then fetches weather data
    /// for those coordinates. Updates `locationName` with the place name.
    ///
    /// - Important: Requires location permission to be granted.
    func fetchCurrentWeather() async {
        await loadWeather {
            let locationEntity = try await self.currentLocationFetcher.fetchCurrentLocation()
            self.currentLocation = locationEntity.location
            self.locationName = locationEntity.name
            return try await self.weatherFetcher.fetchWeather(for: locationEntity.location)
        }
    }

    /// Refreshes weather data for the current location.
    ///
    /// Uses the cached location if available, otherwise falls back
    /// to fetching the current device location first.
    func refreshWeather() async {
        guard let location = currentLocation else {
            await fetchCurrentWeather()
            return
        }
        await loadWeather {
            try await self.weatherFetcher.fetchWeather(for: location)
        }
    }

    /// Fetches weather for a specified location.
    ///
    /// Used when the user selects a location from search results
    /// or predefined cities.
    ///
    /// - Parameters:
    ///   - location: The geographic coordinates to fetch weather for.
    ///   - name: The display name for the location.
    func fetchWeather(for location: CLLocation, name: String) async {
        currentLocation = location
        locationName = name
        await loadWeather {
            try await self.weatherFetcher.fetchWeather(for: location)
        }
    }

    /// Executes a weather fetch operation with standardized state handling.
    ///
    /// ## Pattern: State Transition Abstraction
    ///
    /// This method encapsulates the common loading → loaded/error
    /// state transition pattern, reducing duplication in public methods.
    ///
    /// - Parameter operation: The async operation that fetches weather data.
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
