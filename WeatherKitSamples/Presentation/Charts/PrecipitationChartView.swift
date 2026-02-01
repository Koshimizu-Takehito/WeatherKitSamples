import Charts
import SwiftUI

/// A chart view displaying precipitation probability.
///
/// Demonstrates the use of `BarMark` with conditional coloring,
/// annotations, and threshold indicators using `RuleMark`.
///
/// ## Swift Charts Techniques
///
/// - **BarMark**: Vertical bars for precipitation percentage.
/// - **Conditional Coloring**: Bars colored based on precipitation level.
/// - **RuleMark (Threshold)**: Dashed line indicating high probability threshold.
/// - **Annotations**: Text labels displayed above bars.
/// - **Dual Data Views**: Switching between hourly and daily data.
///
/// ## Learning Points
///
/// - Using `.foregroundStyle` with computed colors
/// - Adding threshold indicators with `RuleMark`
/// - Using `.annotation` modifier for value labels
/// - Implementing data type switching in a single chart view
///
/// - SeeAlso: [Customizing charts](https://developer.apple.com/documentation/charts/customizing-charts)
struct PrecipitationChartView: View {
    /// Hourly precipitation data.
    let hourlyData: [HourlyChartData]

    /// Daily precipitation data.
    let dailyData: [DailyChartData]

    @State private var dataType: DataType = .hourly
    @State private var selectedHourly: HourlyChartData?
    @State private var selectedDaily: DailyChartData?

    /// Data granularity selection.
    enum DataType: String, CaseIterable {
        case hourly = "Hourly"
        case daily = "Daily"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView

            dataTypePickerView

            chartView
                .frame(height: 180)

            legendView

            if let selected = selectedHourly {
                selectedHourlyView(selected)
            } else if let selected = selectedDaily {
                selectedDailyView(selected)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Header View

    private var precipitationSubtitle: LocalizedStringResource {
        dataType == .hourly
            ? ._24HourPrecipitationProbability
            : ._10DayPrecipitationProbability
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(.precipitation, systemImage: "drop.fill")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(precipitationSubtitle)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Data Type Picker

    private var dataTypePickerView: some View {
        Picker(.dataType, selection: $dataType) {
            ForEach(DataType.allCases, id: \.self) { type in
                Text(verbatim: type.rawValue).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: dataType) { _, _ in
            selectedHourly = nil
            selectedDaily = nil
        }
    }

    // MARK: - Chart View

    @ViewBuilder
    private var chartView: some View {
        switch dataType {
        case .hourly:
            hourlyChartView

        case .daily:
            dailyChartView
        }
    }

    /// Hourly precipitation chart with threshold line.
    ///
    /// ## Implementation Notes
    ///
    /// - Bar colors change based on precipitation probability
    /// - A dashed RuleMark at 50% indicates high probability threshold
    /// - Drag gesture enables scrubbing through data points
    private var hourlyChartView: some View {
        Chart(hourlyData) { item in
            BarMark(
                x: .value("Time", item.date),
                y: .value("Precipitation", item.precipitationChance * 100)
            )
            .foregroundStyle(precipitationColor(for: item.precipitationChance))
            .cornerRadius(2)
            .opacity(selectedHourly == nil || selectedHourly?.id == item.id ? 1.0 : 0.4)

            if item.precipitationChance >= 0.5 {
                RuleMark(y: .value("High", 50))
                    .foregroundStyle(.red.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
            }
        }
        .chartYScale(domain: 0 ... 100)
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: 4)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.hour())
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 25, 50, 75, 100]) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let percent = value.as(Double.self) {
                        Text("\(Int(percent))%")
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
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                updateHourlySelection(at: value.location, proxy: proxy, geometry: geometry)
                            }
                            .onEnded { _ in
                                selectedHourly = nil
                            }
                    )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedHourly?.id)
    }

    /// Daily precipitation chart with value annotations.
    ///
    /// ## Implementation Notes
    ///
    /// - Uses `.annotation` modifier to display percentage above bars
    /// - Tap gesture for selection (vs drag for hourly)
    private var dailyChartView: some View {
        Chart(dailyData) { item in
            BarMark(
                x: .value("Date", item.date, unit: .day),
                y: .value("Precipitation", item.precipitationChance * 100),
                width: .ratio(0.7)
            )
            .foregroundStyle(precipitationColor(for: item.precipitationChance))
            .cornerRadius(4)
            .opacity(selectedDaily == nil || selectedDaily?.id == item.id ? 1.0 : 0.4)
            .annotation(position: .top) {
                if item.precipitationChance > 0 {
                    Text(String(format: "%.0f%%", item.precipitationChance * 100))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .chartYScale(domain: 0 ... 100)
        .chartXAxis {
            AxisMarks { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 25, 50, 75, 100]) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let percent = value.as(Double.self) {
                        Text("\(Int(percent))%")
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
                                updateDailySelection(at: value.location, proxy: proxy, geometry: geometry)
                            }
                    )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedDaily?.id)
    }

    // MARK: - Legend View

    private var legendView: some View {
        HStack(spacing: 16) {
            legendItem(color: .green, text: .low030)
            legendItem(color: .yellow, text: .medium3050)
            legendItem(color: .cyan, text: .high50)
        }
        .font(.caption2)
    }

    private func legendItem(color: Color, text: LocalizedStringResource) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Selected Data Views

    private func selectedHourlyView(_ data: HourlyChartData) -> some View {
        HStack {
            Image(systemName: data.symbolName)
                .symbolRenderingMode(.multicolor)
                .font(.title2)

            VStack(alignment: .leading) {
                Text(data.date, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(.precipitation(Int(data.precipitationChance * 100)))
                    .font(.headline)
            }

            Spacer()

            Text(String(format: "%.0f°C", data.temperature))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
        .transition(.opacity)
    }

    private func selectedDailyView(_ data: DailyChartData) -> some View {
        HStack {
            Image(systemName: data.symbolName)
                .symbolRenderingMode(.multicolor)
                .font(.title2)

            VStack(alignment: .leading) {
                Text(data.date, format: .dateTime.month().day().weekday())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(.precipitation(Int(data.precipitationChance * 100)))
                    .font(.headline)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(String(format: "H: %.0f°", data.highTemperature))
                    .foregroundStyle(.orange)
                Text(String(format: "L: %.0f°", data.lowTemperature))
                    .foregroundStyle(.cyan)
            }
            .font(.caption)
        }
        .padding()
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
        .transition(.opacity)
    }

    // MARK: - Helpers

    /// Returns a color based on precipitation probability level.
    ///
    /// - Green: Low probability (0-30%)
    /// - Yellow: Medium probability (30-50%)
    /// - Cyan: High probability (50%+)
    private func precipitationColor(for chance: Double) -> Color {
        switch chance {
        case 0 ..< 0.3:
            .green

        case 0.3 ..< 0.5:
            .yellow

        default:
            .cyan
        }
    }

    private func updateHourlySelection(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        let xPosition = location.x - geometry[proxy.plotFrame!].origin.x

        guard let date: Date = proxy.value(atX: xPosition) else { return }

        selectedHourly = hourlyData.min(by: {
            abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
        })
    }

    private func updateDailySelection(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        let xPosition = location.x - geometry[proxy.plotFrame!].origin.x

        guard let date: Date = proxy.value(atX: xPosition) else {
            selectedDaily = nil
            return
        }

        let calendar = Calendar.current
        if let found = dailyData.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            selectedDaily = selectedDaily?.id == found.id ? nil : found
        }
    }
}

// MARK: - Preview

#Preview(traits: .modifier(.mock)) {
    ScrollView {
        PrecipitationChartView(
            hourlyData: ChartPreviewData.makeHourlyData(),
            dailyData: ChartPreviewData.makeDailyData()
        )
        .padding()
    }
    .background(Color.blue.opacity(0.3))
}
