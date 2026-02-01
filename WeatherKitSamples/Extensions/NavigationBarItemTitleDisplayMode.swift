import SwiftUI

extension NavigationBarItem.TitleDisplayMode {
    static var inlineOnPhone: Self {
        #if os(iOS)
        return .inline
        #else
        return .automatic
        #endif
    }
}
