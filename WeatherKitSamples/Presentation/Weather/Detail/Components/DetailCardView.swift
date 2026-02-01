import SwiftUI

// MARK: - DetailCardView

/// 天気詳細のカードコンポーネント
struct DetailCardView {
    let title: String
    let value: String
    let description: String
    let systemImage: String
    let iconColor: Color
}

// MARK: View

extension DetailCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .labelStyle(DetailLabelStyle(iconColor: iconColor))

            Text(value)
                .font(.title2)
                .fontWeight(.semibold)

            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
