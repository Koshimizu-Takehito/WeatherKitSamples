import SwiftUI

/// Cross-platform helpers for `NavigationBarItem.TitleDisplayMode`.
extension NavigationBarItem.TitleDisplayMode {
    /// Returns `.inline` on iOS and `.automatic` on macOS.
    ///
    /// This abstraction avoids `#if os()` checks at each call site when
    /// a compact navigation bar title is desired only on iPhone.
    static var inlineOnPhone: Self {
        #if os(iOS)
        return .inline
        #else
        return .automatic
        #endif
    }
}
