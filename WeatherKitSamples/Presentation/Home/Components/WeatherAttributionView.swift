import SwiftUI

// MARK: - WeatherAttributionView

/// 天気データの帰属表示View
struct WeatherAttributionView {
    @Environment(\.isMockDataEnabled) private var isMockDataEnabled
}

// MARK: View

extension WeatherAttributionView: View {
    var body: some View {
        VStack(spacing: 4) {
            if isMockDataEnabled {
                Text("モックデータを使用中")
                    .font(.caption2)
            } else {
                Image(systemName: "apple.logo")
                    .font(.caption)
                Text("Weather")
                    .font(.caption2)
            }
        }
        .foregroundStyle(.secondary)
        .padding(.top, 8)
    }
}

#Preview("Real Data") {
    WeatherAttributionView()
}

#Preview("Mock Data") {
    WeatherAttributionView()
        .environment(\.isMockDataEnabled, true)
}
