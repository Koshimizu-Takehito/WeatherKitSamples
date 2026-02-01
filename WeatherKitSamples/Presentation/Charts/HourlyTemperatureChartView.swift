import Charts
import SwiftUI

/// A chart view displaying hourly temperature trends.
///
/// Demonstrates the use of `LineMark`, `AreaMark`, and `PointMark`
/// from Swift Charts to create an interactive temperature visualization.
///
/// ## Swift Charts Techniques
///
/// - **LineMark**: Creates a continuous line connecting temperature data points.
/// - **AreaMark**: Fills the area under the line with a gradient.
/// - **PointMark**: Adds interactive markers at each data point.
/// - **Interpolation**: Uses `.catmullRom` for smooth curves.
/// - **Chart Overlay**: Implements drag gesture for data selection.
///
/// ## Learning Points
///
/// - Combining multiple mark types in a single chart
/// - Using `chartOverlay` for custom gesture handling
/// - Calculating chart value from gesture position with `ChartProxy`
/// - Animating selection changes with `.animation` modifier
///
/// - SeeAlso: [Creating a chart using Swift Charts](https://developer.apple.com/documentation/charts/creating-a-chart-using-swift-charts)
struct HourlyTemperatureChartView: View {
    /// The hourly data to display in the chart.
    let data: [HourlyChartData]

    @State private var selectedData: HourlyChartData?
    @State private var showArea: Bool = true
    @State private var showPoints: Bool = true

    private var temperatureRange: ClosedRange<Double> {
        guard !data.isEmpty else { return 0 ... 30 }
        let minTemp = (data.map(\.temperature).min() ?? 0) - 2
        let maxTemp = (data.map(\.temperature).max() ?? 30) + 2
        return minTemp ... maxTemp
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView

            chartView
                .frame(height: 200)

            chartOptionsView

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
            Label("Temperature Trend", systemImage: "thermometer.medium")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("24-hour temperature changes")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Chart View

    /// The main chart combining LineMark, AreaMark, and PointMark.
    ///
    /// ## Implementation Notes
    ///
    /// - AreaMark is rendered first (bottom layer)
    /// - LineMark is rendered on top of the area
    /// - PointMark provides interactive selection targets
    /// - `.catmullRom` interpolation creates smooth curves
    private var chartView: some View {
        Chart(data) { item in
            if showArea {
                AreaMark(
                    x: .value("Time", item.date),
                    y: .value("Temperature", item.temperature)
                )
                .foregroundStyle(areaGradient)
                .interpolationMethod(.catmullRom)
            }

            LineMark(
                x: .value("Time", item.date),
                y: .value("Temperature", item.temperature)
            )
            .foregroundStyle(Color.orange)
            .lineStyle(StrokeStyle(lineWidth: 2))
            .interpolationMethod(.catmullRom)

            if showPoints {
                PointMark(
                    x: .value("Time", item.date),
                    y: .value("Temperature", item.temperature)
                )
                .foregroundStyle(Color.orange)
                .symbolSize(selectedData?.id == item.id ? 100 : 30)
            }
        }
        .chartYScale(domain: temperatureRange)
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: 4)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.hour())
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
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                updateSelection(at: value.location, proxy: proxy, geometry: geometry)
                            }
                            .onEnded { _ in
                                selectedData = nil
                            }
                    )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedData?.id)
    }

    // MARK: - Chart Options

    private var chartOptionsView: some View {
        HStack(spacing: 16) {
            Toggle(isOn: $showArea) {
                Label("Area", systemImage: "square.fill")
                    .font(.caption)
            }
            .toggleStyle(.button)
            .buttonStyle(.bordered)
            .tint(showArea ? .orange : .gray)

            Toggle(isOn: $showPoints) {
                Label("Points", systemImage: "circle.fill")
                    .font(.caption)
            }
            .toggleStyle(.button)
            .buttonStyle(.bordered)
            .tint(showPoints ? .orange : .gray)

            Spacer()
        }
    }

    // MARK: - Selected Data View

    private func selectedDataView(_ data: HourlyChartData) -> some View {
        HStack {
            Image(systemName: data.symbolName)
                .symbolRenderingMode(.multicolor)
                .font(.title2)

            VStack(alignment: .leading) {
                Text(data.date, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(String(format: "%.1f°C", data.temperature))
                    .font(.headline)
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

    private var areaGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.orange.opacity(0.5),
                Color.orange.opacity(0.2),
                Color.orange.opacity(0.05),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Converts gesture location to chart data selection.
    ///
    /// Uses `ChartProxy.value(atX:)` to convert screen coordinates
    /// to data values, then finds the nearest data point.
    private func updateSelection(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        let xPosition = location.x - geometry[proxy.plotFrame!].origin.x

        guard let date: Date = proxy.value(atX: xPosition) else { return }

        selectedData = data.min(by: {
            abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
        })
    }
}

// MARK: - Preview

#Preview(traits: .modifier(.mock)) {
    ScrollView {
        HourlyTemperatureChartView(data: ChartPreviewData.makeHourlyData())
            .padding()
    }
    .background(Color.blue.opacity(0.3))
}
