# WeatherKitSamples

A sample weather app built with WeatherKit API, demonstrating Clean Architecture and SwiftUI.

[日本語版 README](README.ja.md)

## Features

- Display weather for current location or searched cities
- Hourly and daily weather forecasts
- 2D/3D weather data visualizations using Swift Charts
- Mock data support for development and testing

## Requirements

- iOS 26.2+ / macOS 26.2+
- Xcode 26.2+
- Swift 6.0+
- Apple Developer account with WeatherKit capability enabled

## Getting Started

### 1. Clone & Setup

```bash
git clone https://github.com/Koshimizu-Takehito/WeatherKitSamples.git
cd WeatherKitSamples
make setup
```

### 2. Configure WeatherKit

1. Add WeatherKit capability to your App ID in the [Apple Developer Portal](https://developer.apple.com/)
2. Open the project in Xcode and configure Signing & Capabilities

### 3. Build & Run

```bash
make open  # Open project in Xcode
```

Or open `WeatherKitSamples.xcodeproj` directly in Xcode.

### Mock Mode

To run without WeatherKit configuration, switch to mock mode with `AppDependencies(isMockDataEnabled: true)`.

## Architecture

This project follows a 3-layer Clean Architecture pattern.

```
┌─────────────────────────────────────────────────────────┐
│                   Presentation Layer                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │    Views    │  │  ViewModels │  │     Charts      │  │
│  │  (SwiftUI)  │  │ (@Observable)│  │ (Swift Charts)  │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                     Domain Layer                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │  Entities   │  │  Interfaces │  │    Use Cases    │  │
│  │             │  │ (Protocols) │  │                 │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                      Data Layer                          │
│  ┌─────────────────────┐  ┌─────────────────────────┐   │
│  │     DataSources     │  │      Repositories       │   │
│  │ (WeatherKit / Mock) │  │                         │   │
│  └─────────────────────┘  └─────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### Directory Structure

```
WeatherKitSamples/
├── App/                    # Application entry point & DI
├── Core/
│   ├── Extensions/         # Environment keys, UI helpers
│   └── WeatherFormatters.swift  # Formatting utilities
├── Domain/
│   ├── Entities/           # Domain models
│   ├── Interfaces/         # Repository protocols
│   └── UseCases/           # Business logic
├── Data/
│   ├── DataSources/        # API clients (WeatherKit / Mock)
│   └── Repositories/       # Repository implementations
└── Presentation/
    ├── Home/               # Home screen
    ├── Weather/            # Weather detail screens
    ├── Location/           # Location search screen
    └── Charts/             # Weather charts (2D/3D)
```

## Development

### Available Commands

```bash
make setup        # Install dependencies
make build        # Build for iOS Simulator
make build-macos  # Build for macOS
make lint         # Run SwiftLint
make format       # Format code with SwiftFormat
make fix          # Run lint-fix + format
make ci           # Run all CI checks
make clean        # Clean build artifacts
```

### Code Style

This project uses [SwiftLint](https://github.com/realm/SwiftLint) and [SwiftFormat](https://github.com/nicklockwood/SwiftFormat).

## Key Design Patterns

### View Implementation

```swift
// Separate struct definition from View conformance
struct HomeView {
    @Environment(HomeViewModel.self) private var viewModel
}

extension HomeView: View {
    var body: some View {
        Group(content: contentView)
            .toolbar(content: toolbarContent)
    }
}
```

### ViewModel Implementation

```swift
@MainActor
@Observable
final class HomeViewModel {
    enum State {
        case initial, loading, loaded(WeatherEntity), error(String)
    }
    
    private(set) var state: State = .initial
    
    func fetchWeather() async { ... }
}
```

### Dependency Injection

```swift
// Inject ViewModel via Environment
ContentView()
    .dependencies(AppDependencies(isMockDataEnabled: false))
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

[takehito](https://github.com/Koshimizu-Takehito)
