import SwiftUI

// MARK: - WeatherAttributionView

/// Displays the Apple Weather data attribution notice.
///
/// Shows the Apple logo and "Weather" text when using live data, or a
/// "mock data" label when ``EnvironmentValues/isMockDataEnabled`` is `true`.
///
/// - Note: Apple requires attribution when displaying WeatherKit data.
///   See [WeatherKit attribution requirements](https://developer.apple.com/weatherkit/get-started/#attribution-requirements).
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
