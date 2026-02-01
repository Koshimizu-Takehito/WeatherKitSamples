import SwiftUI

// MARK: - HomeView

/// ホーム画面のView
struct HomeView {
    @Environment(HomeViewModel.self) private var viewModel
    @State private var isShowingLocationSearch = false
    @State private var isShowingCharts = false
}

// MARK: View

extension HomeView: View {
    var body: some View {
        NavigationStack {
            Group(content: contentView)
                .background(content: backgroundGradient)
                .toolbar(content: homeToolbar)
                .sheet(isPresented: $isShowingLocationSearch, content: locationSearchSheet)
                .sheet(isPresented: $isShowingCharts, content: chartsSheet)
                .navigationBarTitleDisplayMode(.inlineOnPhone)
                .navigationTitle("天気")
        }
        .task(fetchCurrentWeather)
    }

    private func fetchCurrentWeather() async {
        await viewModel.fetchCurrentWeather()
    }

    // MARK: - Content

    @ViewBuilder
    private func contentView() -> some View {
        Group {
            switch viewModel.state {
            case .initial:
                HomeInitialView(isShowingLocationSearch: $isShowingLocationSearch)

            case .loading:
                HomeLoadingView()

            case let .loaded(weather):
                HomeWeatherContentView(weather: weather)

            case let .error(message):
                HomeErrorView(message: message)
            }
        }
        .containerRelativeFrame([.horizontal, .vertical])
    }

    // MARK: - Background

    private func backgroundGradient() -> some View {
        LinearGradient(
            colors: WeatherGradient.colors(for: viewModel.state),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private func homeToolbar() -> some ToolbarContent {
        HomeToolbarContent(
            isShowingCharts: $isShowingCharts,
            isShowingLocationSearch: $isShowingLocationSearch
        )
    }

    // MARK: - Sheets

    private func locationSearchSheet() -> some View {
        LocationSearchView()
    }

    private func chartsSheet() -> some View {
        NavigationStack {
            WeatherChartsView().toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("閉じる") {
                        isShowingCharts = false
                    }
                }
            }
        }
    }
}

#Preview(traits: .modifier(.mock)) {
    HomeView()
}
