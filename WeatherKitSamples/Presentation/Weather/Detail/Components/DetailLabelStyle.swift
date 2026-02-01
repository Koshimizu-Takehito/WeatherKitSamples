import SwiftUI

// MARK: - Detail Label Style

/// 天気詳細カード用のラベルスタイル
struct DetailLabelStyle: LabelStyle {
    let iconColor: Color

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon
                .foregroundStyle(iconColor)
            configuration.title
        }
    }
}
