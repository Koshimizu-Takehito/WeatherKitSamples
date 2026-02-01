import SwiftUI

#if os(iOS)
/// Cross-platform helpers for `NavigationBarItem.TitleDisplayMode`.
extension NavigationBarItem.TitleDisplayMode {
    static var inlineOnPhone: Self {
        return .inline
    }
}
#else
/// Cross-platform helpers for `NavigationBarItem.TitleDisplayMode`.
enum NavigationBarItem {
    enum TitleDisplayMode {
        case inlineOnPhone
    }
}

extension View {
    func navigationBarTitleDisplayMode(_: NavigationBarItem.TitleDisplayMode) -> some View {
        // No Operation
        self
    }
}
#endif
