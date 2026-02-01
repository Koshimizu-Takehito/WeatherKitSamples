import SwiftUI

// MARK: - Home Weather Content View

/// 天気情報を表示するView
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
