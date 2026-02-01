import SwiftUI

/// The application entry point.
///
/// Configures the root ``HomeView`` with production dependencies injected
/// via the `.dependencies()` modifier. Set `isMockDataEnabled` to `true`
/// to use ``MockWeatherDataSource`` instead of live WeatherKit.
///
/// - SeeAlso: ``AppDependencies`` for the dependency injection setup.
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
