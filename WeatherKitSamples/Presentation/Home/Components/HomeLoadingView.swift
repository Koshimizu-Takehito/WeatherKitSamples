import SwiftUI

// MARK: - Home Loading View

/// Displays a loading indicator while weather data is being fetched.
///
/// Corresponds to ``HomeViewModel/State/loading``.
struct HomeLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text(.fetchingWeather)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview(traits: .modifier(.mock)) {
    HomeLoadingView()
}
