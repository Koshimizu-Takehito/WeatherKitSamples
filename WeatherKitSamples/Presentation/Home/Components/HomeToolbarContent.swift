import SwiftUI

// MARK: - Home Toolbar Content

/// ホーム画面のツールバーコンテンツ
struct HomeToolbarContent: ToolbarContent {
    @Environment(HomeViewModel.self) private var viewModel
    @Binding var isShowingCharts: Bool
    @Binding var isShowingLocationSearch: Bool

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem(placement: .primaryAction) { searchButton }
        ToolbarItem(placement: .primaryAction) { chartsButton }
        ToolbarItem(placement: .navigation) { locationButton }
        #else
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 16) {
                chartsButton
                searchButton
            }
        }
        ToolbarItem(placement: .topBarLeading) { locationButton }
        #endif
    }

    // MARK: - Buttons

    private var chartsButton: some View {
        Button {
            isShowingCharts = true
        } label: {
            Image(systemName: "chart.xyaxis.line")
        }
        .disabled(!viewModel.hasWeatherData)
    }

    private var searchButton: some View {
        Button {
            isShowingLocationSearch = true
        } label: {
            Image(systemName: "magnifyingglass")
        }
    }

    private var locationButton: some View {
        Button {
            Task { await viewModel.fetchCurrentWeather() }
        } label: {
            Image(systemName: "location")
        }
    }
}
