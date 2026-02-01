import Charts
import Spatial
import SwiftUI

/// A 3D chart view comparing temperature trends across multiple days.
///
/// Demonstrates the use of `Chart3D` with `PointMark` to visualize
/// multi-day temperature data in 3D space for comparison.
///
/// ## Swift Charts 3D Techniques
///
/// - **Multi-Series Visualization**: Each day as a separate series.
/// - **Day-based Coloring**: Different colors for each day.
/// - **Toggle Interaction**: Show/hide days for focused comparison.
/// - **chart3DPose**: Camera angle for multi-series comparison.
///
/// ## Learning Points
///
/// - Visualizing multiple data series in 3D space
/// - Using day index as a spatial dimension
/// - Interactive filtering with toggle controls
/// - Color-coding series for easy identification
///
/// - SeeAlso: ``Chart3DDataPoint`` for the data structure.
struct DailyTemperature3DLineChartView: View {
    /// Multi-day hourly data, grouped by day.
    let multiDayData: [[HourlyChartData]]

    @State private var showAllDays: Bool = true

    /// Processes raw data into 3D data points.
    private var processedData: [Chart3DDataPoint] {
        var result: [Chart3DDataPoint] = []
        let calendar = Calendar.current

        for (dayIndex, dayData) in multiDayData.enumerated() {
            guard showAllDays || dayIndex == 0 else { continue }

            for item in dayData {
                let hour = calendar.component(.hour, from: item.date)
                let day = calendar.startOfDay(for: item.date)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView

            toggleView

            chart3DView
                .frame(height: 350)

            legendView
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(._3DTemperatureTrend, systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(.compareTemperatureTrendsAcrossDays)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Toggle View

    private var toggleView: some View {
        Toggle(.showAllDays, isOn: $showAllDays)
            .font(.subheadline)
            .tint(.accentColor)
    }

    // MARK: - 3D Chart View

    /// The 3D chart for multi-day comparison.
    ///
    /// ## Axis Mapping
    ///
    /// - X-axis: Hour of day (0-23)
    /// - Y-axis: Day index (0, 1, 2...)
    /// - Z-axis: Temperature in Celsius
    private var chart3DView: some View {
        Chart3D(processedData) { item in
            PointMark(
                x: .value("Hour", item.hour),
                y: .value("Day", item.dayIndex),
                z: .value("Temperature", item.temperature)
            )
            .foregroundStyle(dayColor(for: item.dayIndex))
            .symbolSize(60)
        }
        .chart3DPose(Chart3DPose(azimuth: .degrees(25), inclination: .degrees(15)))
        .animation(.easeInOut(duration: 0.3), value: showAllDays)
    }

    // MARK: - Legend View

    private var legendView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(.colorByDay)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                ForEach(0 ..< min(multiDayData.count, 3), id: \.self) { index in
                    legendItem(color: dayColor(for: index), text: dayLabel(for: index))
                }
            }
            .font(.caption2)
        }
    }

    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(verbatim: text)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Helpers

    private func dayColor(for index: Int) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink]
        return colors[index % colors.count]
    }

    private func dayLabel(for index: Int) -> String {
        switch index {
        case 0: String(localized: .today)
        case 1: String(localized: .tomorrow)
        case 2: String(localized: .dayAfter)
        default: String(localized: .day(index + 1))
        }
    }
}

// MARK: - Preview

#Preview(traits: .modifier(.mock)) {
    ScrollView {
        DailyTemperature3DLineChartView(
            multiDayData: ChartPreviewData.makeMultiDayGroupedData()
        )
        .padding()
    }
    .background(Color.blue.opacity(0.3))
}
