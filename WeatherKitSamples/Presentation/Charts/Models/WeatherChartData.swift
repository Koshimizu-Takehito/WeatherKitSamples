import Charts
import Foundation

// MARK: - HourlyChartData

/// A data structure for hourly weather chart visualization.
///
/// Wraps weather forecast data in a format optimized for Swift Charts,
/// providing all necessary properties for temperature and precipitation charts.
///
/// ## Learning Points
///
/// - **Identifiable Conformance**: Required for use in `ForEach` and `Chart` views.
/// - **Data Transformation**: Created from ``HourlyForecastEntity`` using the
///   convenience initializer, demonstrating the adapter pattern.
///
/// - SeeAlso: ``DailyChartData`` for daily forecast visualization.
/// - SeeAlso: ``Chart3DDataPoint`` for 3D chart visualization.
struct HourlyChartData: Identifiable {
    /// Unique identifier for chart element tracking.
    let id: UUID

    /// The date and time of this data point.
    let date: Date

    /// Temperature in Celsius.
    let temperature: Double

    /// Probability of precipitation (0.0 to 1.0).
    let precipitationChance: Double

    /// SF Symbol name for the weather condition.
    let symbolName: String

    /// Creates a new hourly chart data point.
    ///
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - date: The date and time of this data point.
    ///   - temperature: Temperature in Celsius.
    ///   - precipitationChance: Precipitation probability (0.0-1.0).
    ///   - symbolName: SF Symbol name for the condition.
    init(id: UUID = UUID(), date: Date, temperature: Double, precipitationChance: Double, symbolName: String) {
        self.id = id
        self.date = date
        self.temperature = temperature
        self.precipitationChance = precipitationChance
        self.symbolName = symbolName
    }
}

// MARK: - DailyChartData

/// A data structure for daily weather chart visualization.
///
/// Wraps daily forecast data for use in temperature range charts,
/// storing both high and low temperatures for range visualization.
///
/// ## Learning Points
///
/// - **Range Visualization**: The `highTemperature` and `lowTemperature`
///   properties are used with `BarMark(yStart:yEnd:)` for range bars.
///
/// - SeeAlso: ``HourlyChartData`` for hourly visualization.
struct DailyChartData: Identifiable {
    /// Unique identifier for chart element tracking.
    let id: UUID

    /// The date of this forecast.
    let date: Date

    /// Predicted high temperature in Celsius.
    let highTemperature: Double

    /// Predicted low temperature in Celsius.
    let lowTemperature: Double

    /// Probability of precipitation (0.0 to 1.0).
    let precipitationChance: Double

    /// SF Symbol name for the weather condition.
    let symbolName: String

    /// Creates a new daily chart data point.
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

/// Represents time periods of the day for data aggregation.
///
/// Used in 3D charts to group hourly data into meaningful periods
/// (morning, afternoon, evening, night) for aggregated visualization.
///
/// ## Learning Points
///
/// - **Plottable Conformance**: Allows direct use as chart axis values.
/// - **CaseIterable**: Enables iteration over all periods for aggregation.
enum TimePeriod: String, CaseIterable, Plottable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    case night = "Night"

    /// The hour range for this time period.
    var hourRange: ClosedRange<Int> {
        switch self {
        case .morning: 6 ... 11
        case .afternoon: 12 ... 17
        case .evening: 18 ... 21
        case .night: 22 ... 23
        }
    }

    /// Determines the time period for a given hour.
    ///
    /// - Parameter hour: Hour of the day (0-23).
    /// - Returns: The corresponding time period.
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

/// A data point for 3D chart visualization.
///
/// Extends hourly data with additional properties needed for 3D charts,
/// including day index and time period classification.
///
/// ## Learning Points
///
/// - **Multi-Dimensional Data**: Combines time (day + hour), value (temperature),
///   and category (period) dimensions for 3D visualization.
/// - **Computed Properties**: `dayString` provides formatted display text.
///
/// - SeeAlso: ``Chart3DPeriodData`` for aggregated period data.
struct Chart3DDataPoint: Identifiable {
    /// Unique identifier.
    let id: UUID

    /// The date of this data point (day only, no time).
    let day: Date

    /// Zero-based index of the day (0, 1, 2...).
    let dayIndex: Int

    /// Hour of the day (0-23).
    let hour: Int

    /// The time period this hour belongs to.
    let period: TimePeriod

    /// Temperature in Celsius.
    let temperature: Double

    /// Probability of precipitation (0.0 to 1.0).
    let precipitationChance: Double

    /// Creates a new 3D chart data point.
    ///
    /// - Parameters:
    ///   - day: The date (day only).
    ///   - dayIndex: Zero-based day index.
    ///   - hour: Hour of the day (0-23).
    ///   - temperature: Temperature in Celsius.
    ///   - precipitationChance: Precipitation probability.
    init(day: Date, dayIndex: Int, hour: Int, temperature: Double, precipitationChance: Double) {
        self.id = UUID()
        self.day = day
        self.dayIndex = dayIndex
        self.hour = hour
        self.period = TimePeriod.from(hour: hour)
        self.temperature = temperature
        self.precipitationChance = precipitationChance
    }

    /// A short formatted string representing the day.
    var dayString: String {
        WeatherFormatters.formatShortDate(day)
    }
}

// MARK: - Chart3DPeriodData

/// Aggregated data for 3D bar charts grouped by time period.
///
/// Provides averaged temperature and maximum precipitation data
/// for each time period within a day, suitable for 3D bar visualization.
///
/// ## Learning Points
///
/// - **Data Aggregation**: Hourly data is aggregated into periods
///   with average temperatures and max precipitation.
/// - **Bar Chart Optimization**: Fewer data points than hourly data
///   make 3D bar charts more readable.
struct Chart3DPeriodData: Identifiable {
    /// Unique identifier.
    let id: UUID

    /// The date of this data (day only).
    let day: Date

    /// Zero-based index of the day.
    let dayIndex: Int

    /// The time period this data represents.
    let period: TimePeriod

    /// Average temperature during this period.
    let averageTemperature: Double

    /// Maximum precipitation chance during this period.
    let maxPrecipitationChance: Double

    /// A short formatted string representing the day.
    var dayString: String {
        WeatherFormatters.formatShortDate(day)
    }
}

// MARK: - 3D Chart Data Conversion

extension [HourlyChartData] {
    /// Converts hourly chart data to 3D data points.
    ///
    /// Groups data by day and creates ``Chart3DDataPoint`` instances
    /// with proper day indices for 3D chart positioning.
    ///
    /// - Returns: An array of 3D data points.
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

    /// Converts hourly data to aggregated period data for 3D bar charts.
    ///
    /// Groups hourly data by day and time period, calculating
    /// average temperatures and maximum precipitation chances.
    ///
    /// - Returns: An array of aggregated period data.
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
    /// Creates chart data from a domain entity.
    ///
    /// - Parameter entity: The hourly forecast entity to convert.
    init(from entity: HourlyForecastEntity) {
        self.id = entity.id
        self.date = entity.date
        self.temperature = entity.temperature
        self.precipitationChance = entity.precipitationChance
        self.symbolName = entity.symbolName
    }
}

extension DailyChartData {
    /// Creates chart data from a domain entity.
    ///
    /// - Parameter entity: The daily forecast entity to convert.
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

/// A factory for generating preview and test chart data.
///
/// Provides static methods to create sample data for SwiftUI previews
/// and development without requiring actual weather data.
///
/// ## Usage
///
/// ```swift
/// #Preview {
///     HourlyTemperatureChartView(data: ChartPreviewData.makeHourlyData())
/// }
/// ```
enum ChartPreviewData {
    /// Generates 24 hours of sample hourly data.
    ///
    /// Creates data starting from the current time with
    /// realistic temperature variations and conditions.
    ///
    /// - Returns: An array of 24 ``HourlyChartData`` items.
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

    /// Generates 10 days of sample daily data.
    ///
    /// - Returns: An array of 10 ``DailyChartData`` items.
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

    /// Generates 3 days of hourly data for 3D charts.
    ///
    /// Creates detailed hourly data with realistic diurnal
    /// temperature patterns across multiple days.
    ///
    /// - Returns: An array of 72 ``HourlyChartData`` items (24 hours x 3 days).
    static func makeMultiDayHourlyData() -> [HourlyChartData] {
        let calendar = Calendar.current
        let now = Date()
        var result: [HourlyChartData] = []

        for dayOffset in 0 ..< 3 {
            guard let dayStart = calendar.date(byAdding: .day, value: dayOffset, to: calendar.startOfDay(for: now)) else {
                continue
            }

            // Typical diurnal temperature pattern
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

    /// Generates multi-day data grouped by day.
    ///
    /// - Returns: An array of arrays, each containing 24 hourly data points.
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
