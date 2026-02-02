import SwiftUI

// MARK: - Home Initial View

/// Displays the initial state before any weather data is loaded.
///
/// Prompts the user to either grant location access or search for a city.
/// Corresponds to ``HomeViewModel/State/initial``.
///
/// - SeeAlso: ``HomeView`` for the parent routing logic.
struct HomeInitialView: View {
    @Environment(HomeViewModel.self) private var viewModel
    @Binding var isShowingLocationSearch: Bool

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cloud.sun")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text(.toDisplayWeatherInformationPleaseAllowLocationAccessOrSearchForACity)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Button {
                    Task { await viewModel.fetchCurrentWeather() }
                } label: {
                    Label(.currentLocation, systemImage: "location")
                }
                .buttonStyle(.glassProminent)

                Button {
                    isShowingLocationSearch = true
                } label: {
                    Label(.search, systemImage: "magnifyingglass")
                }
                .buttonStyle(.glass)
            }
        }
        .padding()
    }
}

#Preview(traits: .modifier(.mock)) {
    HomeInitialView(isShowingLocationSearch: .constant(false))
}
