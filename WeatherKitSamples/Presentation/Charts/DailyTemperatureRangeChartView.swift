import Charts
import SwiftUI

/// A chart view displaying daily temperature ranges (high/low).
///
/// Demonstrates the use of `BarMark` with `yStart`/`yEnd` parameters
/// and `RuleMark` for range visualization in Swift Charts.
///
/// ## Swift Charts Techniques
///
/// - **BarMark with yStart/yEnd**: Creates bars spanning from low to high temperature.
/// - **RuleMark**: Alternative visualization showing temperature range as a line.
/// - **Capsule Clip Shape**: Custom bar styling with rounded ends.
/// - **PointMark with Custom Symbol**: Weather icons at temperature points.
/// - **Gradient Fill**: Temperature-based color gradient for visual appeal.
///
/// ## Learning Points
///
/// - Using `yStart` and `yEnd` for range bars (not just height)
/// - Multiple chart style options in a single view
/// - Combining marks for richer visualizations
/// - Interactive tap selection with `SpatialTapGesture`
///
/// - SeeAlso: [BarMark](https://developer.apple.com/documentation/charts/barmark)
struct DailyTemperatureRangeChartView: View {
    /// The daily forecast data to display.
    let data: [DailyChartData]

    @State private var selectedData: DailyChartData?
    @State private var chartStyle: ChartStyleType = .bar

    /// Available chart visualization styles.
    enum ChartStyleType: String, CaseIterable {
        case bar = "Bar"
        case rule = "Rule"
        case capsule = "Capsule"
    }

    private var temperatureRange: ClosedRange<Double> {
        guard !data.isEmpty else { return 0 ... 30 }
        let minTemp = (data.map(\.lowTemperature).min() ?? 0) - 3
        let maxTemp = (data.map(\.highTemperature).max() ?? 30) + 3
        return minTemp ... maxTemp
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView

            chartView
                .frame(height: 220)

            stylePickerView

            if let selected = selectedData {
                selectedDataView(selected)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("10-Day Temperature", systemImage: "calendar")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("High and low temperature range")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Chart View

    /// The main chart with switchable visualization styles.
    ///
    /// ## Style Descriptions
    ///
    /// - **Bar**: Traditional bar chart with rounded corners
    /// - **Rule**: Line-based range with point markers
    /// - **Capsule**: Pill-shaped bars with weather icons
    private var chartView: some View {
        Chart(data) { item in
            switch chartStyle {
            case .bar:
                barMarkChart(for: item)

            case .rule:
                ruleMarkChart(for: item)

            case .capsule:
                capsuleMarkChart(for: item)
            }
        }
        .chartYScale(domain: temperatureRange)
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let temp = value.as(Double.self) {
                        Text("\(Int(temp))°")
                    }
                }
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        SpatialTapGesture()
                            .onEnded { value in
                                updateSelection(at: value.location, proxy: proxy, geometry: geometry)
                            }
                    )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: chartStyle)
        .animation(.easeInOut(duration: 0.2), value: selectedData?.id)
    }

    // MARK: - Chart Marks

    /// Bar chart style using BarMark with yStart/yEnd.
    ///
    /// This demonstrates how to create range bars that span
    /// from one value to another (not starting from zero).
    @ChartContentBuilder
    private func barMarkChart(for item: DailyChartData) -> some ChartContent {
        BarMark(
            x: .value("Date", item.date, unit: .day),
            yStart: .value("Low", item.lowTemperature),
            yEnd: .value("High", item.highTemperature),
            width: .ratio(0.6)
        )
        .foregroundStyle(temperatureGradient(for: item))
        .cornerRadius(4)
        .opacity(selectedData == nil || selectedData?.id == item.id ? 1.0 : 0.4)
    }

    /// Rule chart style using RuleMark with point markers.
    ///
    /// Shows the temperature range as a thick line with
    /// colored points at high and low values.
    @ChartContentBuilder
    private func ruleMarkChart(for item: DailyChartData) -> some ChartContent {
        RuleMark(
            x: .value("Date", item.date, unit: .day),
            yStart: .value("Low", item.lowTemperature),
            yEnd: .value("High", item.highTemperature)
        )
        .foregroundStyle(temperatureGradient(for: item))
        .lineStyle(StrokeStyle(lineWidth: 8, lineCap: .round))
        .opacity(selectedData == nil || selectedData?.id == item.id ? 1.0 : 0.4)

        PointMark(
            x: .value("Date", item.date, unit: .day),
            y: .value("High", item.highTemperature)
        )
        .foregroundStyle(.orange)
        .symbolSize(40)

        PointMark(
            x: .value("Date", item.date, unit: .day),
            y: .value("Low", item.lowTemperature)
        )
        .foregroundStyle(.cyan)
        .symbolSize(40)
    }

    /// Capsule chart style with weather icons.
    ///
    /// Uses `.clipShape(Capsule())` for rounded bar ends
    /// and custom symbols for weather condition display.
    @ChartContentBuilder
    private func capsuleMarkChart(for item: DailyChartData) -> some ChartContent {
        BarMark(
            x: .value("Date", item.date, unit: .day),
            yStart: .value("Low", item.lowTemperature),
            yEnd: .value("High", item.highTemperature),
            width: .ratio(0.4)
        )
        .foregroundStyle(temperatureGradient(for: item))
        .clipShape(Capsule())
        .opacity(selectedData == nil || selectedData?.id == item.id ? 1.0 : 0.4)

        PointMark(
            x: .value("Date", item.date, unit: .day),
            y: .value("High", item.highTemperature + 1.5)
        )
        .symbol {
            Image(systemName: item.symbolName)
                .symbolRenderingMode(.multicolor)
                .font(.caption)
        }
    }

    // MARK: - Style Picker

    private var stylePickerView: some View {
        Picker("Style", selection: $chartStyle) {
            ForEach(ChartStyleType.allCases, id: \.self) { style in
                Text(style.rawValue).tag(style)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Selected Data View

    private func selectedDataView(_ data: DailyChartData) -> some View {
        HStack {
            Image(systemName: data.symbolName)
                .symbolRenderingMode(.multicolor)
                .font(.title2)

            VStack(alignment: .leading) {
                Text(data.date, format: .dateTime.month().day().weekday())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Label(String(format: "%.0f°", data.highTemperature), systemImage: "arrow.up")
                        .foregroundStyle(.orange)
                    Label(String(format: "%.0f°", data.lowTemperature), systemImage: "arrow.down")
                        .foregroundStyle(.cyan)
                }
                .font(.subheadline)
                .fontWeight(.medium)
            }

            Spacer()

            if data.precipitationChance > 0 {
                Label(String(format: "%.0f%%", data.precipitationChance * 100), systemImage: "drop.fill")
                    .font(.caption)
                    .foregroundStyle(.cyan)
            }
        }
        .padding()
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
        .transition(.opacity)
    }

    // MARK: - Helpers

    private func temperatureGradient(for _: DailyChartData) -> LinearGradient {
        LinearGradient(
            colors: [.orange, .yellow, .cyan],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func updateSelection(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        let xPosition = location.x - geometry[proxy.plotFrame!].origin.x

        guard let date: Date = proxy.value(atX: xPosition) else {
            selectedData = nil
            return
        }

        let calendar = Calendar.current
        if let found = data.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            selectedData = selectedData?.id == found.id ? nil : found
        }
    }
}

// MARK: - Preview

#Preview(traits: .modifier(.mock)) {
    ScrollView {
        DailyTemperatureRangeChartView(data: ChartPreviewData.makeDailyData())
            .padding()
    }
    .background(Color.blue.opacity(0.3))
}
