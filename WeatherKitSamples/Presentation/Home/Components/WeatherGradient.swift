import SwiftUI

// MARK: - Weather Gradient

/// 天気状態に応じた背景グラデーションを提供する列挙型
enum WeatherGradient {
    /// HomeViewModel.Stateからグラデーションカラーを取得
    static func colors(for state: HomeViewModel.State) -> [Color] {
        guard let weather = state.weather else {
            return defaultColors
        }
        return colors(for: weather.current.condition)
    }

    /// 天気コンディションからグラデーションカラーを取得
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

    /// デフォルトのグラデーションカラー
    static var defaultColors: [Color] {
        [.blue.opacity(0.6), .cyan.opacity(0.4)]
    }
}
