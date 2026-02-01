import Charts
import Foundation

// MARK: - HourlyChartData

/// 時間ごとのチャートデータをラップする構造体
struct HourlyChartData: Identifiable {
    let id: UUID
    let date: Date
    let temperature: Double
    let precipitationChance: Double
    let symbolName: String

    init(id: UUID = UUID(), date: Date, temperature: Double, precipitationChance: Double, symbolName: String) {
        self.id = id
        self.date = date
        self.temperature = temperature
        self.precipitationChance = precipitationChance
        self.symbolName = symbolName
    }
}

// MARK: - DailyChartData

/// 日ごとのチャートデータをラップする構造体
struct DailyChartData: Identifiable {
    let id: UUID
    let date: Date
    let highTemperature: Double
    let lowTemperature: Double
    let precipitationChance: Double
    let symbolName: String

    init(id: UUID = UUID(), date: Date, highTemperature: Double, lowTemperature: Double, precipitationChance: Double, symbolName: String) {
        self.id = id
        self.date = date
        self.highTemperature = highTemperature
        self.lowTemperature = lowTemperature
        self.precipitationChance = precipitationChance
        self.symbolName = symbolName
    }
}

// MARK: - TimePeriod

/// 時間帯を表す列挙型
enum TimePeriod: String, CaseIterable, Plottable {
    case morning = "朝"
    case afternoon = "昼"
    case evening = "夕"
    case night = "夜"

    var hourRange: ClosedRange<Int> {
        switch self {
        case .morning: 6 ... 11
        case .afternoon: 12 ... 17
        case .evening: 18 ... 21
        case .night: 22 ... 23
        }
    }

    static func from(hour: Int) -> Self {
        switch hour {
        case 6 ... 11: .morning
        case 12 ... 17: .afternoon
        case 18 ... 21: .evening
        default: .night
        }
    }
}

// MARK: - Chart3DDataPoint

/// 3Dチャート用のデータポイント
struct Chart3DDataPoint: Identifiable {
    let id: UUID
    let day: Date
    let dayIndex: Int
    let hour: Int
    let period: TimePeriod
    let temperature: Double
    let precipitationChance: Double

    init(day: Date, dayIndex: Int, hour: Int, temperature: Double, precipitationChance: Double) {
        self.id = UUID()
        self.day = day
        self.dayIndex = dayIndex
        self.hour = hour
        self.period = TimePeriod.from(hour: hour)
        self.temperature = temperature
        self.precipitationChance = precipitationChance
    }

    var dayString: String {
        WeatherFormatters.formatShortDate(day)
    }
}

// MARK: - Chart3DPeriodData

/// 3Dチャート用の日別時間帯データ（棒グラフ用）
struct Chart3DPeriodData: Identifiable {
    let id: UUID
    let day: Date
    let dayIndex: Int
    let period: TimePeriod
    let averageTemperature: Double
    let maxPrecipitationChance: Double

    var dayString: String {
        WeatherFormatters.formatShortDate(day)
    }
}

// MARK: - 3D Chart Data Conversion

extension [HourlyChartData] {
    /// 時間ごとのデータを3Dチャート用データポイントに変換
    func to3DDataPoints() -> [Chart3DDataPoint] {
        let calendar = Calendar.current
        var result: [Chart3DDataPoint] = []

        let grouped = Dictionary(grouping: self) { item in
            calendar.startOfDay(for: item.date)
        }

        let sortedDays = grouped.keys.sorted()

        for (dayIndex, day) in sortedDays.enumerated() {
            guard let items = grouped[day] else { continue }
            for item in items {
                let hour = calendar.component(.hour, from: item.date)
                result.append(Chart3DDataPoint(
                    day: day,
                    dayIndex: dayIndex,
                    hour: hour,
                    temperature: item.temperature,
                    precipitationChance: item.precipitationChance
                ))
            }
        }

        return result
    }

    /// 時間帯別に集約した3Dデータを生成
    func to3DPeriodData() -> [Chart3DPeriodData] {
        let calendar = Calendar.current
        var result: [Chart3DPeriodData] = []

        let grouped = Dictionary(grouping: self) { item in
            calendar.startOfDay(for: item.date)
        }

        let sortedDays = grouped.keys.sorted()

        for (dayIndex, day) in sortedDays.enumerated() {
            guard let items = grouped[day] else { continue }

            for period in TimePeriod.allCases {
                let periodItems = items.filter { item in
                    let hour = calendar.component(.hour, from: item.date)
                    return TimePeriod.from(hour: hour) == period
                }

                guard !periodItems.isEmpty else { continue }

                let avgTemp = periodItems.map(\.temperature).reduce(0, +) / Double(periodItems.count)
                let maxPrecip = periodItems.map(\.precipitationChance).max() ?? 0

                result.append(Chart3DPeriodData(
                    id: UUID(),
                    day: day,
                    dayIndex: dayIndex,
                    period: period,
                    averageTemperature: avgTemp,
                    maxPrecipitationChance: maxPrecip
                ))
            }
        }

        return result
    }
}

// MARK: - Entity Conversion

extension HourlyChartData {
    /// HourlyForecastEntityからHourlyChartDataを生成
    init(from entity: HourlyForecastEntity) {
        self.id = entity.id
        self.date = entity.date
        self.temperature = entity.temperature
        self.precipitationChance = entity.precipitationChance
        self.symbolName = entity.symbolName
    }
}

extension DailyChartData {
    /// DailyForecastEntityからDailyChartDataを生成
    init(from entity: DailyForecastEntity) {
        self.id = entity.id
        self.date = entity.date
        self.highTemperature = entity.highTemperature
        self.lowTemperature = entity.lowTemperature
        self.precipitationChance = entity.precipitationChance
        self.symbolName = entity.symbolName
    }
}

// MARK: - ChartPreviewData

/// チャートプレビュー用のデータファクトリ
enum ChartPreviewData {
    /// 24時間分の時間ごとデータを生成
    static func makeHourlyData() -> [HourlyChartData] {
        let now = Date()
        var result: [HourlyChartData] = []

        for index in 0 ..< 24 {
            let date = now.addingTimeInterval(Double(index) * 3600)
            let temperature = Double(18 + (index % 5))
            let precipitationChance = index % 5 == 0 ? 0.2 : 0.0
            let symbolName = index < 12 ? "sun.max.fill" : "cloud.sun.fill"

            let data = HourlyChartData(
                date: date,
                temperature: temperature,
                precipitationChance: precipitationChance,
                symbolName: symbolName
            )
            result.append(data)
        }

        return result
    }

    /// 10日分の日ごとデータを生成
    static func makeDailyData() -> [DailyChartData] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var result: [DailyChartData] = []

        for index in 0 ..< 10 {
            guard let date = calendar.date(byAdding: .day, value: index, to: today) else {
                continue
            }
            let highTemperature = Double(20 + (index % 5))
            let lowTemperature = Double(12 + (index % 3))
            let precipitationChance = index % 3 == 0 ? 0.7 : 0.0
            let symbolName = index % 3 == 0 ? "cloud.rain.fill" : "sun.max.fill"

            let data = DailyChartData(
                date: date,
                highTemperature: highTemperature,
                lowTemperature: lowTemperature,
                precipitationChance: precipitationChance,
                symbolName: symbolName
            )
            result.append(data)
        }

        return result
    }

    /// 複数日分（3日間）の時間ごとデータを生成
    static func makeMultiDayHourlyData() -> [HourlyChartData] {
        let calendar = Calendar.current
        let now = Date()
        var result: [HourlyChartData] = []

        for dayOffset in 0 ..< 3 {
            guard let dayStart = calendar.date(byAdding: .day, value: dayOffset, to: calendar.startOfDay(for: now)) else {
                continue
            }

            let baseTemps: [Double] = [
                12, 11, 10, 10, 11, 13, 15, 17, 19, 21, 22, 23,
                24, 24, 23, 22, 20, 18, 16, 15, 14, 13, 12, 12,
            ]

            let tempOffset = Double(dayOffset) * 1.5 - 1.5

            for hour in 0 ..< 24 {
                guard let date = calendar.date(byAdding: .hour, value: hour, to: dayStart) else {
                    continue
                }
                let temp = baseTemps[hour] + tempOffset
                let precipChance = (hour >= 12 && hour <= 18) ? 0.3 : 0.05

                let symbolName = if precipChance > 0.25 {
                    "cloud.rain.fill"
                } else if hour >= 6, hour < 18 {
                    "sun.max.fill"
                } else {
                    "moon.fill"
                }

                let data = HourlyChartData(
                    date: date,
                    temperature: temp,
                    precipitationChance: precipChance,
                    symbolName: symbolName
                )
                result.append(data)
            }
        }

        return result
    }

    /// 複数日データを日ごとにグループ化
    static func makeMultiDayGroupedData() -> [[HourlyChartData]] {
        let allData = makeMultiDayHourlyData()
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: allData) { calendar.startOfDay(for: $0.date) }
        let sortedKeys = grouped.keys.sorted()

        var result: [[HourlyChartData]] = []
        for key in sortedKeys {
            let dayData = grouped[key] ?? []
            result.append(dayData)
        }
        return result
    }
}
