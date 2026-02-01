import SwiftUI

@main
struct WeatherKitSamplesApp: App {
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
