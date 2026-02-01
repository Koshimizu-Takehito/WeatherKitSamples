import SwiftUI

// MARK: - Home Error View

/// Displays an error message with a retry action.
///
/// Corresponds to ``HomeViewModel/State/error(_:)``. Tapping the retry
/// button triggers ``HomeViewModel/fetchCurrentWeather()`` again.
struct HomeErrorView: View {
    @Environment(HomeViewModel.self) private var viewModel
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button(.retry) {
                Task { await viewModel.fetchCurrentWeather() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview(traits: .modifier(.mock)) {
    HomeErrorView(message: "エラーが発生しました")
}
