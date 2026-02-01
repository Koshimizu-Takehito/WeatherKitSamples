import SwiftUI

// MARK: - Home Error View

/// エラー状態を表示するView
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

            Button("再試行") {
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
