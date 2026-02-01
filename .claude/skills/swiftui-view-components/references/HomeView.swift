import SwiftUI

// MARK: - Home View

struct HomeView: View {
    @Environment(\.diContainer) private var diContainer
    @State private var viewModel: HomeViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    HomeContentView(
                        viewModel: viewModel,
                        useMockData: diContainer.useMockData
                    )
                } else {
                    ProgressView()
                }
            }
        }
        .task {
            if viewModel == nil {
                viewModel = diContainer.makeHomeViewModel()
                viewModel?.handle(.fetchCurrentLocation)
            }
        }
    }
}

// MARK: - Home Content View

private struct HomeContentView: View {
    @Bindable var viewModel: HomeViewModel
    let useMockData: Bool

    @State private var showingLocationSearch = false
    @State private var showingCharts = false

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            contentView
        }
        .navigationTitle("天気")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            HomeToolbarContent(
                hasWeatherData: viewModel.hasWeatherData,
                onShowCharts: { showingCharts = true },
                onShowSearch: { showingLocationSearch = true },
                onFetchLocation: { viewModel.handle(.fetchCurrentLocation) }
            )
        }
        .sheet(isPresented: $showingLocationSearch) {
            locationSearchSheet
        }
        .sheet(isPresented: $showingCharts) {
            chartsSheet
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: WeatherGradient.colors(for: viewModel.state),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Content

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .initial:
            HomeInitialView(
                onFetchLocation: { viewModel.handle(.fetchCurrentLocation) },
                onShowSearch: { showingLocationSearch = true }
            )
        case .loading:
            HomeLoadingView()
        case .loaded(let weather):
            HomeWeatherContentView(
                weather: weather,
                locationName: viewModel.locationName,
                useMockData: useMockData
            ) {
                await viewModel.refreshWeather()
            }
        case .error(let message):
            HomeErrorView(message: message) {
                viewModel.handle(.fetchCurrentLocation)
            }
        }
    }

    // MARK: - Sheets

    private var locationSearchSheet: some View {
        LocationSearchView { location, name in
            viewModel.handle(.selectLocation(location, name: name))
        }
    }

    private var chartsSheet: some View {
        NavigationStack {
            WeatherChartsView(
                hourlyData: viewModel.hourlyChartData,
                dailyData: viewModel.dailyChartData
            )
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("閉じる") {
                        showingCharts = false
                    }
                }
            }
        }
    }
}
