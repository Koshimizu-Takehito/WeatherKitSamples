import SwiftUI

// MARK: - Detail Label Style

/// A custom `LabelStyle` that applies a specific color to the icon.
///
/// Used by ``DetailCardView`` to tint each card's SF Symbol independently
/// while keeping the title in the default style.
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
