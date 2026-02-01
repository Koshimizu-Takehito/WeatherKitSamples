import SwiftUI

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .dependencies(isMockDataEnabled: false)
        }
    }
}

#Preview(traits: .modifier(.mock)) {
    HomeView()
}
