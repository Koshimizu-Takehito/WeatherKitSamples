import SwiftUI

// MARK: - Environment Key

/// Custom environment values for app-wide configuration.
///
/// ## Learning Points
/// - **`@Entry` macro**: Simplifies `EnvironmentKey` boilerplate by generating
///   the key type and default value automatically (available since Swift 5.10).
extension EnvironmentValues {
    /// Indicates whether the app is using mock data instead of live WeatherKit API.
    ///
    /// Set to `true` via ``AppDependencies`` to switch all data sources to
    /// ``MockWeatherDataSource``. Views can read this to display a mock-mode badge.
    @Entry var isMockDataEnabled = false
}
