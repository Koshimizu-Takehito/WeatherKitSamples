# WeatherKit Integration

How this project integrates Apple's WeatherKit framework.

## Overview

WeatherKit provides access to Apple Weather data through the
`WeatherService` API. This project demonstrates a clean integration
pattern that isolates WeatherKit types from the rest of the app.

## Integration Pattern

### Framework Isolation

``WeatherKitDataSource`` is the **only** type that imports WeatherKit.
It maps WeatherKit's `Weather`, `CurrentWeather`, `Forecast<HourWeather>`,
and `Forecast<DayWeather>` types into domain entities:

- `CurrentWeather` → ``CurrentWeatherEntity``
- `Forecast<HourWeather>` → `[```HourlyForecastEntity```]`
- `Forecast<DayWeather>` → `[```DailyForecastEntity```]`

This mapping keeps the domain and presentation layers testable without
WeatherKit dependencies.

### Data Flow

```
WeatherService.shared.weather(for:)
        │
        ▼
WeatherKitDataSource (maps to domain entities)
        │
        ▼
WeatherRepository (implements WeatherRepositoryProtocol)
        │
        ▼
WeatherFetcher (use case)
        │
        ▼
HomeViewModel (drives the UI)
```

## Requirements

| Requirement | Details |
|-------------|---------|
| Apple Developer Program | Active membership required |
| App ID Capability | WeatherKit must be enabled |
| Entitlements | `com.apple.developer.weatherkit` |
| Network | Internet access for API calls |

## Mock Mode

For development without a WeatherKit entitlement, use
``MockWeatherDataSource`` by initializing ``AppDependencies`` with
`isMockDataEnabled: true`. This returns realistic static data that
exercises all UI paths.

## Further Reading

- [WeatherKit Documentation](https://developer.apple.com/documentation/weatherkit)
- [Meet WeatherKit (WWDC22)](https://developer.apple.com/videos/play/wwdc2022/10003/)
