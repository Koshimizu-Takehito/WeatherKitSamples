import SwiftUI

// MARK: - Home Initial View

/// 初期状態を表示するView
struct HomeInitialView: View {
    @Environment(HomeViewModel.self) private var viewModel
    @Binding var isShowingLocationSearch: Bool

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cloud.sun")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("天気情報を表示するには\n位置情報を許可するか\n都市を検索してください")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Button {
                    Task { await viewModel.fetchCurrentWeather() }
                } label: {
                    Label("現在地", systemImage: "location")
                }
                .buttonStyle(.borderedProminent)

                Button {
                    isShowingLocationSearch = true
                } label: {
                    Label("検索", systemImage: "magnifyingglass")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}

#Preview(traits: .modifier(.mock)) {
    HomeInitialView(isShowingLocationSearch: .constant(false))
}
