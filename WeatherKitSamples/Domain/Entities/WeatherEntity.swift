import CoreLocation
import Foundation

// MARK: - WeatherEntity

/// 天気情報のドメインエンティティ
struct WeatherEntity: Sendable {
    let current: CurrentWeatherEntity
    let hourlyForecast: [HourlyForecastEntity]
    let dailyForecast: [DailyForecastEntity]
}

// MARK: - CurrentWeatherEntity

/// 現在の天気情報
struct CurrentWeatherEntity: Sendable {
    let temperature: Double
    let apparentTemperature: Double
    let humidity: Double
    let windSpeed: Double
    let windDirection: String
    let condition: WeatherCondition
    let symbolName: String
    let uvIndex: Int
    let uvIndexCategory: String
    let pressure: Double
    let pressureTrend: PressureTrend
    let visibility: Double
    let dewPoint: Double
}

// MARK: - HourlyForecastEntity

/// 時間ごとの予報
struct HourlyForecastEntity: Identifiable, Sendable {
    let id: UUID
    let date: Date
    let temperature: Double
    let symbolName: String
    let condition: String
    let precipitationChance: Double

    init(
        id: UUID = UUID(),
        date: Date,
        temperature: Double,
        symbolName: String,
        condition: String,
        precipitationChance: Double
    ) {
        self.id = id
        self.date = date
        self.temperature = temperature
        self.symbolName = symbolName
        self.condition = condition
        self.precipitationChance = precipitationChance
    }
}

// MARK: - DailyForecastEntity

/// 日ごとの予報
struct DailyForecastEntity: Identifiable, Sendable {
    let id: UUID
    let date: Date
    let highTemperature: Double
    let lowTemperature: Double
    let symbolName: String
    let precipitationChance: Double

    init(
        id: UUID = UUID(),
        date: Date,
        highTemperature: Double,
        lowTemperature: Double,
        symbolName: String,
        precipitationChance: Double
    ) {
        self.id = id
        self.date = date
        self.highTemperature = highTemperature
        self.lowTemperature = lowTemperature
        self.symbolName = symbolName
        self.precipitationChance = precipitationChance
    }
}

// MARK: - WeatherCondition

/// 天気状態
enum WeatherCondition: String, Sendable {
    case clear
    case mostlyClear
    case partlyCloudy
    case cloudy
    case mostlyCloudy
    case rain
    case drizzle
    case heavyRain
    case snow
    case heavySnow
    case flurries
    case thunderstorms
    case foggy
    case haze
    case unknown

    var description: String {
        switch self {
        case .clear: "晴れ"
        case .mostlyClear: "晴れ"
        case .partlyCloudy: "晴れ時々曇り"
        case .cloudy: "曇り"
        case .mostlyCloudy: "曇り"
        case .rain: "雨"
        case .drizzle: "小雨"
        case .heavyRain: "大雨"
        case .snow: "雪"
        case .heavySnow: "大雪"
        case .flurries: "にわか雪"
        case .thunderstorms: "雷雨"
        case .foggy: "霧"
        case .haze: "もや"
        case .unknown: "不明"
        }
    }
}

// MARK: - PressureTrend

/// 気圧の傾向
enum PressureTrend: String, Sendable {
    case rising
    case falling
    case steady
    case unknown

    var description: String {
        switch self {
        case .rising: "上昇中"
        case .falling: "下降中"
        case .steady: "安定"
        case .unknown: ""
        }
    }
}

// MARK: - LocationEntity

/// 位置情報のドメインエンティティ
struct LocationEntity: Sendable {
    let coordinate: CLLocationCoordinate2D
    let name: String

    var location: CLLocation {
        CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

// MARK: - CLLocationCoordinate2D + @retroactive @unchecked Sendable

extension CLLocationCoordinate2D: @retroactive @unchecked Sendable {}
