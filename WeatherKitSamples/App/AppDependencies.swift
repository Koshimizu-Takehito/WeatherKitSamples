import SwiftUI

// MARK: - AppDependencies

/// アプリケーション全体の依存オブジェクト
struct AppDependencies {
    let isMockDataEnabled: Bool
    let homeViewModel: HomeViewModel
    let locationSearchViewModel: LocationSearchViewModel

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

/// アプリケーション全体の依存関係を解決するViewModifier
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
    func dependencies(isMockDataEnabled: Bool) -> some View {
        dependencies(AppDependencies(isMockDataEnabled: isMockDataEnabled))
    }

    func dependencies(_ dependencies: AppDependencies) -> some View {
        modifier(DependencyModifier(dependencies: dependencies))
    }
}

// MARK: - MockPreviewModifier

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
    static var mock: Self { .init() }
}
