import SwiftUI

// MARK: - HomeView

/// The main home screen displaying weather information.
///
/// Switches between child views based on ``HomeViewModel/State``:
/// ``HomeInitialView``, ``HomeLoadingView``, ``HomeWeatherContentView``,
/// or ``HomeErrorView``.
///
/// ## Learning Points
/// - **State-driven routing**: A `switch` on the ViewModel's state enum
///   maps each case to a dedicated child view.
/// - **Method references**: Closures like `content:` accept method references
///   (e.g., `contentView`) to keep `body` flat and readable.
/// - **Environment-based DI**: The ViewModel is obtained from `@Environment`,
///   not passed as a parameter.
///
/// - SeeAlso: ``HomeViewModel`` for the state management logic.
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
                .navigationTitle(Text(.weather))
                .navigationSubtitle(navigationSubtitle)
        }
        .task(fetchCurrentWeather)
    }

    private var navigationSubtitle: String {
        if case .loaded = viewModel.state {
            return viewModel.locationName
        }
        return ""
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
                    Button(role: .close) {
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
