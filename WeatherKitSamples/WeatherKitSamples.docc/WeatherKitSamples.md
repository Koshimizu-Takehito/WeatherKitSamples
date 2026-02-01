# ``WeatherKitSamples``

A demo app showcasing WeatherKit and Swift Charts integration with Clean Architecture.

## Overview

WeatherKitSamples is a sample iOS/macOS app that demonstrates how to:

- Fetch and display weather data using Apple's **WeatherKit** framework
- Visualize weather data with **Swift Charts** (2D) and **RealityKit** (3D)
- Structure a SwiftUI app using **Clean Architecture** with dependency injection

The project is designed as a learning resource for developers exploring
WeatherKit, Swift Charts, and modern SwiftUI architecture patterns.

### Requirements

- Apple Developer Program membership with WeatherKit capability enabled
- Location services permission (for current location weather)
- Network access (for WeatherKit API calls)

### Mock Mode

Pass `isMockDataEnabled: true` to ``AppDependencies`` to switch all data
sources to ``MockWeatherDataSource``, enabling development and testing
without a WeatherKit entitlement.

## Topics

### App Entry Point

- ``App``
- ``AppDependencies``

### Domain Layer

- ``WeatherEntity``
- ``CurrentWeatherEntity``
- ``HourlyForecastEntity``
- ``DailyForecastEntity``
- ``LocationEntity``
- ``WeatherRepositoryProtocol``
- ``LocationRepositoryProtocol``
- ``WeatherFetchable``
- ``WeatherFetcher``
- ``CurrentLocationFetchable``
- ``CurrentLocationFetcher``
- ``LocationSearchable``
- ``LocationSearcher``

### Data Layer

- ``WeatherDataSourceProtocol``
- ``WeatherKitDataSource``
- ``MockWeatherDataSource``
- ``WeatherRepository``
- ``LocationRepository``

### Presentation - Home

- ``HomeView``
- ``HomeViewModel``
- ``HomeInitialView``
- ``HomeLoadingView``
- ``HomeErrorView``
- ``HomeWeatherContentView``
- ``HomeToolbarContent``

### Presentation - Weather Display

- ``CurrentWeatherView``
- ``HourlyForecastView``
- ``HourlyForecastItemView``
- ``DailyForecastView``
- ``DailyForecastItemView``
- ``WeatherDetailView``
- ``DetailCardView``
- ``DetailLabelStyle``

### Presentation - Location Search

- ``LocationSearchView``
- ``LocationSearchViewModel``

### Presentation - Charts (2D)

- ``WeatherChartsView``
- ``HourlyTemperatureChartView``
- ``DailyTemperatureRangeChartView``
- ``PrecipitationChartView``

### Presentation - Charts (3D)

- ``Weather3DChartsView``
- ``Temperature3DBarChartView``
- ``DailyTemperature3DLineChartView``
- ``Temperature3DSurfaceChartView``
- ``Weather3DPointChartView``

### Utilities

- ``WeatherFormatters``
- ``WeatherGradient``
- ``MockBadgeView``
- ``WeatherAttributionView``
