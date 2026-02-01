import CoreLocation
import Foundation

// MARK: - MockWeatherDataSource

/// モックデータを返すデータソース（開発・テスト用）
final class MockWeatherDataSource: WeatherDataSourceProtocol, Sendable {
    func fetchWeather(for _: CLLocation) async throws -> WeatherEntity {
        // 実際のAPI呼び出しをシミュレートするための遅延
        try await Task.sleep(for: .milliseconds(500))

        return WeatherEntity(
            current: generateCurrentWeather(),
            hourlyForecast: generateHourlyForecast(),
            dailyForecast: generateDailyForecast()
        )
    }

    // MARK: - Private Generation Methods

    private func generateCurrentWeather() -> CurrentWeatherEntity {
        CurrentWeatherEntity(
            temperature: 18.5,
            apparentTemperature: 17.0,
            humidity: 0.65,
            windSpeed: 12.5,
            windDirection: "北西",
            condition: .clear,
            symbolName: "sun.max.fill",
            uvIndex: 5,
            uvIndexCategory: "中程度",
            pressure: 1013.25,
            pressureTrend: .steady,
            visibility: 10.0,
            dewPoint: 11.0
        )
    }

    private func generateHourlyForecast() -> [HourlyForecastEntity] {
        let now = Date()
        let conditions: [(String, String, Double)] = [
            ("sun.max.fill", "晴れ", 18),
            ("sun.max.fill", "晴れ", 19),
            ("cloud.sun.fill", "晴れ時々曇り", 20),
            ("cloud.sun.fill", "晴れ時々曇り", 21),
            ("cloud.fill", "曇り", 20),
            ("cloud.fill", "曇り", 19),
            ("cloud.sun.fill", "晴れ時々曇り", 18),
            ("sun.max.fill", "晴れ", 17),
            ("moon.stars.fill", "晴れ", 16),
            ("moon.fill", "晴れ", 15),
            ("moon.fill", "晴れ", 14),
            ("moon.fill", "晴れ", 13),
            ("moon.fill", "晴れ", 12),
            ("moon.fill", "晴れ", 12),
            ("sun.horizon.fill", "晴れ", 13),
            ("sun.max.fill", "晴れ", 15),
            ("sun.max.fill", "晴れ", 17),
            ("sun.max.fill", "晴れ", 19),
            ("sun.max.fill", "晴れ", 21),
            ("cloud.sun.fill", "晴れ時々曇り", 22),
            ("cloud.sun.fill", "晴れ時々曇り", 22),
            ("cloud.fill", "曇り", 21),
            ("cloud.fill", "曇り", 20),
            ("cloud.sun.fill", "晴れ時々曇り", 19),
        ]

        return conditions.enumerated().map { index, data in
            HourlyForecastEntity(
                date: now.addingTimeInterval(Double(index) * 3600),
                temperature: data.2,
                symbolName: data.0,
                condition: data.1,
                precipitationChance: index % 5 == 0 ? 0.2 : 0.0
            )
        }
    }

    private func generateDailyForecast() -> [DailyForecastEntity] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let forecasts: [(String, Double, Double, Double)] = [
            ("sun.max.fill", 22, 14, 0.0),
            ("cloud.sun.fill", 20, 13, 0.1),
            ("cloud.rain.fill", 18, 12, 0.7),
            ("cloud.rain.fill", 16, 11, 0.8),
            ("cloud.fill", 17, 10, 0.3),
            ("sun.max.fill", 19, 11, 0.0),
            ("sun.max.fill", 21, 12, 0.0),
            ("cloud.sun.fill", 20, 13, 0.1),
            ("cloud.sun.fill", 19, 12, 0.2),
            ("sun.max.fill", 22, 14, 0.0),
        ]

        return forecasts.enumerated().map { index, data in
            DailyForecastEntity(
                date: calendar.date(byAdding: .day, value: index, to: today)!,
                highTemperature: data.1,
                lowTemperature: data.2,
                symbolName: data.0,
                precipitationChance: data.3
            )
        }
    }
}

// MARK: - Multi-Day Hourly Forecast (for 3D Charts)

extension MockWeatherDataSource {
    /// 複数日分（3日間）の時間ごと予報データを生成
    func generateMultiDayHourlyForecast() -> [[HourlyForecastEntity]] {
        let calendar = Calendar.current
        let now = Date()

        return (0 ..< 3).map { dayOffset in
            let dayStart = calendar.date(byAdding: .day, value: dayOffset, to: calendar.startOfDay(for: now))!

            let baseTemps: [Double] = [
                12, 11, 10, 10, 11, 13, 15, 17, 19, 21, 22, 23,
                24, 24, 23, 22, 20, 18, 16, 15, 14, 13, 12, 12,
            ]

            let tempOffset = Double(dayOffset) * 1.5 - 1.5

            return (0 ..< 24).map { hour in
                let date = calendar.date(byAdding: .hour, value: hour, to: dayStart)!
                let temp = baseTemps[hour] + tempOffset + Double.random(in: -1 ... 1)
                let precipChance = hour >= 12 && hour <= 18 ? Double.random(in: 0 ... 0.4) : Double.random(in: 0 ... 0.1)

                let symbolName: String = if precipChance > 0.3 {
                    "cloud.rain.fill"
                } else if hour >= 6, hour < 18 {
                    precipChance > 0.1 ? "cloud.sun.fill" : "sun.max.fill"
                } else {
                    "moon.fill"
                }

                return HourlyForecastEntity(
                    date: date,
                    temperature: temp,
                    symbolName: symbolName,
                    condition: precipChance > 0.3 ? "雨" : "晴れ",
                    precipitationChance: precipChance
                )
            }
        }
    }
}
