import SwiftUI

// MARK: - AppDependencies

/// The application's dependency container.
///
/// Creates and holds all dependency objects needed by the application,
/// including repositories, use cases, and view models.
///
/// ## Overview
///
/// `AppDependencies` implements the Composition Root pattern, where all
/// dependencies are created and wired together in one place. This enables:
/// - Easy switching between production and mock implementations
/// - Centralized dependency management
/// - Clean separation of object creation from usage
///
/// ## Usage
///
/// ```swift
/// // In App.swift
/// ContentView()
///     .dependencies(isMockDataEnabled: false)
///
/// // In SwiftUI Previews
/// #Preview(traits: .modifier(.mock)) {
///     SomeView()
/// }
/// ```
///
/// ## Learning Points
///
/// - **Composition Root**: All dependencies are created in the initializer.
/// - **Mock Switching**: `isMockDataEnabled` toggles between real and mock data.
/// - **Environment Injection**: Dependencies are injected via SwiftUI Environment.
///
/// - SeeAlso: ``View/dependencies(isMockDataEnabled:)`` for injection.
struct AppDependencies {
    /// Whether mock data sources are enabled.
    let isMockDataEnabled: Bool

    /// The view model for the home screen.
    let homeViewModel: HomeViewModel

    /// The view model for location search.
    let locationSearchViewModel: LocationSearchViewModel

    /// Creates a new dependency container.
    ///
    /// Instantiates all dependencies in the correct order, wiring
    /// together data sources, repositories, use cases, and view models.
    ///
    /// - Parameter isMockDataEnabled: If true, uses ``MockWeatherDataSource``;
    ///   otherwise uses ``WeatherKitDataSource``.
    init(isMockDataEnabled: Bool) {
        let weatherDataSource: WeatherDataSourceProtocol = isMockDataEnabled
            ? MockWeatherDataSource()
            : WeatherKitDataSource()
        let weatherRepository = WeatherRepository(dataSource: weatherDataSource)
        let locationRepository = LocationRepository()

        self.isMockDataEnabled = isMockDataEnabled
        self.homeViewModel = HomeViewModel(
            weatherFetcher: WeatherFetcher(weatherRepository: weatherRepository),
            currentLocationFetcher: CurrentLocationFetcher(locationRepository: locationRepository)
        )
        self.locationSearchViewModel = LocationSearchViewModel(
            locationSearcher: LocationSearcher(locationRepository: locationRepository)
        )
    }
}

// MARK: - DependencyModifier

/// A view modifier that injects application dependencies into the environment.
private struct DependencyModifier: ViewModifier {
    let dependencies: AppDependencies

    func body(content: Content) -> some View {
        content
            .environment(\.isMockDataEnabled, dependencies.isMockDataEnabled)
            .environment(dependencies.homeViewModel)
            .environment(dependencies.locationSearchViewModel)
    }
}

// MARK: - View Extension

extension View {
    /// Injects dependencies with the specified mock mode.
    ///
    /// - Parameter isMockDataEnabled: Whether to use mock data sources.
    /// - Returns: A view with dependencies injected into the environment.
    func dependencies(isMockDataEnabled: Bool) -> some View {
        dependencies(AppDependencies(isMockDataEnabled: isMockDataEnabled))
    }

    /// Injects the given dependencies into the environment.
    ///
    /// - Parameter dependencies: The dependency container to inject.
    /// - Returns: A view with dependencies injected into the environment.
    func dependencies(_ dependencies: AppDependencies) -> some View {
        modifier(DependencyModifier(dependencies: dependencies))
    }
}

// MARK: - MockPreviewModifier

/// A preview modifier that provides mock dependencies for SwiftUI previews.
///
/// ## Usage
///
/// ```swift
/// #Preview(traits: .modifier(.mock)) {
///     SomeView()
/// }
/// ```
struct MockPreviewModifier: PreviewModifier {
    static func makeSharedContext() throws -> AppDependencies {
        AppDependencies(isMockDataEnabled: true)
    }

    func body(content: Content, context: AppDependencies) -> some View {
        content.dependencies(context)
    }
}

// MARK: - PreviewModifier

extension PreviewModifier where Self == MockPreviewModifier {
    /// A preview modifier that uses mock data sources.
    static var mock: Self { .init() }
}
