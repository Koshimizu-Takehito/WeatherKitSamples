import SwiftUI

// MARK: - Home Toolbar Content

/// Toolbar buttons for the home screen.
///
/// Provides chart, search, and current-location buttons. Uses conditional
/// compilation (`#if os(macOS)`) to adjust toolbar placement per platform.
///
/// ## Learning Points
/// - **`ToolbarContent` protocol**: Extracts toolbar items into a
///   dedicated struct, keeping the parent View's `body` clean.
/// - **Platform adaptation**: `#if os()` allows different `placement`
///   values for iOS and macOS without duplicating button definitions.
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
        ToolbarItem(placement: .topBarTrailing) { searchButton }
        ToolbarSpacer(.fixed)
        ToolbarItem(placement: .topBarTrailing) { chartsButton }
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
