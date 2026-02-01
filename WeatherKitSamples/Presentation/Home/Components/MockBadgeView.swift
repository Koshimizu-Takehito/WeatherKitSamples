import SwiftUI

// MARK: - Mock Badge View

/// モックデータモードを示すバッジView
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
