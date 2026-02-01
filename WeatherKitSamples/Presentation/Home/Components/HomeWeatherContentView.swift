import SwiftUI

// MARK: - Home Weather Content View

/// Displays the loaded weather data in a scrollable layout.
///
/// Composes ``CurrentWeatherView``, ``HourlyForecastView``,
/// ``DailyForecastView``, ``WeatherDetailView``, and
/// ``WeatherAttributionView`` into a single content view.
/// Supports pull-to-refresh via `.refreshable`.
///
/// Corresponds to ``HomeViewModel/State/loaded(_:)``.
struct HomeWeatherContentView: View {
    @Environment(\.isMockDataEnabled) private var isMockDataEnabled
    @Environment(HomeViewModel.self) private var viewModel
    let weather: WeatherEntity

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isMockDataEnabled {
                    MockBadgeView()
                }

                CurrentWeatherView(
                    weather: weather.current,
                    locationName: viewModel.locationName,
                    todayForecast: weather.dailyForecast.first
                )

                if !weather.hourlyForecast.isEmpty {
                    HourlyForecastView(forecast: weather.hourlyForecast)
                }

                if !weather.dailyForecast.isEmpty {
                    DailyForecastView(forecast: weather.dailyForecast)
                }

                WeatherDetailView(weather: weather.current)

                WeatherAttributionView()
            }
            .padding()
        }
        .refreshable {
            await viewModel.refreshWeather()
        }
    }
}
