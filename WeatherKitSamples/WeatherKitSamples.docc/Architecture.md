# Architecture

An overview of the three-layer Clean Architecture used in this project.

## Overview

WeatherKitSamples follows a three-layer architecture that separates
concerns and enables testability through dependency injection.

```
┌─────────────────────────────┐
│    Presentation Layer       │
│  (Views, ViewModels)        │
├─────────────────────────────┤
│      Domain Layer           │
│  (Entities, UseCases,       │
│   Repository Protocols)     │
├─────────────────────────────┤
│       Data Layer            │
│  (DataSources, Repositories)│
└─────────────────────────────┘
```

### Dependency Rule

Dependencies point inward only:

- **Presentation** depends on **Domain**
- **Data** depends on **Domain**
- **Domain** depends on nothing

The Domain layer defines repository protocols (e.g., ``WeatherRepositoryProtocol``)
that the Data layer implements. This inversion of control keeps the domain
free of framework dependencies.

## Domain Layer

Contains framework-agnostic business logic:

- **Entities** (``WeatherEntity``, ``LocationEntity``): Pure data models
  with no UIKit or SwiftUI imports.
- **Use Case Protocols** (``WeatherFetchable``, ``CurrentLocationFetchable``,
  ``LocationSearchable``): Define what the app can do.
- **Use Case Implementations** (``WeatherFetcher``, ``CurrentLocationFetcher``,
  ``LocationSearcher``): Orchestrate repository calls.
- **Repository Protocols** (``WeatherRepositoryProtocol``,
  ``LocationRepositoryProtocol``): Contracts for data access.

## Data Layer

Implements data access behind domain-defined protocols:

- **DataSources** (``WeatherDataSourceProtocol``): Abstract data fetching.
  ``WeatherKitDataSource`` calls the real WeatherKit API, while
  ``MockWeatherDataSource`` returns static data.
- **Repositories** (``WeatherRepository``, ``LocationRepository``):
  Coordinate data sources and map external types to domain entities.

## Presentation Layer

SwiftUI views and their corresponding view models:

- **ViewModels** use `@Observable` and `@MainActor` for thread-safe
  state management. State is modeled as a nested `State` enum.
- **Views** obtain ViewModels from `@Environment`, not from initializer
  parameters. Child views are split per state enum case.

## Dependency Injection

``AppDependencies`` creates all dependency objects and injects them into
the SwiftUI environment via the `.dependencies()` view modifier. This
eliminates prop drilling and allows any view in the hierarchy to access
its ViewModel directly from `@Environment`.

For Previews, use `#Preview(traits: .modifier(.mock))` which configures
``AppDependencies`` with `isMockDataEnabled: true`.
