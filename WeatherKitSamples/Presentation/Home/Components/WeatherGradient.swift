import SwiftUI

// MARK: - Weather Gradient

/// Provides background gradient colors based on weather conditions.
///
/// Maps ``WeatherCondition`` cases to pairs of `Color` values used by
/// `LinearGradient` in ``HomeView`` to create a dynamic background.
enum WeatherGradient {
    /// Returns gradient colors derived from the current ``HomeViewModel/State``.
    ///
    /// Extracts the weather condition from a loaded state, falling back
    /// to ``defaultColors`` for non-loaded states.
    static func colors(for state: HomeViewModel.State) -> [Color] {
        guard let weather = state.weather else {
            return defaultColors
        }
        return colors(for: weather.current.condition)
    }

    /// Returns gradient colors for a specific weather condition.
    ///
    /// - Parameter condition: The current weather condition.
    /// - Returns: An array of two colors for the linear gradient.
    static func colors(for condition: WeatherCondition) -> [Color] {
        switch condition {
        case .clear, .mostlyClear:
            [.blue, .cyan.opacity(0.6)]

        case .cloudy, .mostlyCloudy, .partlyCloudy:
            [.gray.opacity(0.8), .blue.opacity(0.4)]

        case .rain, .drizzle, .heavyRain:
            [.gray, .blue.opacity(0.6)]

        case .snow, .heavySnow, .flurries:
            [.white.opacity(0.8), .blue.opacity(0.3)]

        case .thunderstorms:
            [.indigo, .gray.opacity(0.8)]

        default:
            defaultColors
        }
    }

    /// The fallback gradient used when no weather data is available.
    static var defaultColors: [Color] {
        [.blue.opacity(0.6), .cyan.opacity(0.4)]
    }
}
