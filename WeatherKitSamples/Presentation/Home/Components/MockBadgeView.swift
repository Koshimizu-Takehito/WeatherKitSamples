import SwiftUI

// MARK: - Mock Badge View

/// A capsule badge indicating that mock data is in use.
///
/// Displayed at the top of ``HomeWeatherContentView`` when the app is
/// running with ``MockWeatherDataSource`` enabled.
struct MockBadgeView: View {
    var body: some View {
        Text("モックデータモード")
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(.orange.opacity(0.8), in: Capsule())
            .foregroundStyle(.white)
    }
}

#Preview(traits: .modifier(.mock)) {
    MockBadgeView()
}
