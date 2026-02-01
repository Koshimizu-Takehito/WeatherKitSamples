import Charts
import SwiftUI

/// 日別気温範囲チャートビュー
/// Swift Charts の BarMark (yStart/yEnd), RuleMark のサンプル
struct DailyTemperatureRangeChartView: View {
    let data: [DailyChartData]

    @State private var selectedData: DailyChartData?
    @State private var chartStyle: ChartStyleType = .bar

    enum ChartStyleType: String, CaseIterable {
        case bar = "バー"
        case rule = "ルール"
        case capsule = "カプセル"
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
            Label("10日間の気温", systemImage: "calendar")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("最高・最低気温の範囲")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Chart View

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

    @ChartContentBuilder
    private func barMarkChart(for item: DailyChartData) -> some ChartContent {
        BarMark(
            x: .value("日付", item.date, unit: .day),
            yStart: .value("最低", item.lowTemperature),
            yEnd: .value("最高", item.highTemperature),
            width: .ratio(0.6)
        )
        .foregroundStyle(temperatureGradient(for: item))
        .cornerRadius(4)
        .opacity(selectedData == nil || selectedData?.id == item.id ? 1.0 : 0.4)
    }

    @ChartContentBuilder
    private func ruleMarkChart(for item: DailyChartData) -> some ChartContent {
        RuleMark(
            x: .value("日付", item.date, unit: .day),
            yStart: .value("最低", item.lowTemperature),
            yEnd: .value("最高", item.highTemperature)
        )
        .foregroundStyle(temperatureGradient(for: item))
        .lineStyle(StrokeStyle(lineWidth: 8, lineCap: .round))
        .opacity(selectedData == nil || selectedData?.id == item.id ? 1.0 : 0.4)

        PointMark(
            x: .value("日付", item.date, unit: .day),
            y: .value("最高", item.highTemperature)
        )
        .foregroundStyle(.orange)
        .symbolSize(40)

        PointMark(
            x: .value("日付", item.date, unit: .day),
            y: .value("最低", item.lowTemperature)
        )
        .foregroundStyle(.cyan)
        .symbolSize(40)
    }

    @ChartContentBuilder
    private func capsuleMarkChart(for item: DailyChartData) -> some ChartContent {
        BarMark(
            x: .value("日付", item.date, unit: .day),
            yStart: .value("最低", item.lowTemperature),
            yEnd: .value("最高", item.highTemperature),
            width: .ratio(0.4)
        )
        .foregroundStyle(temperatureGradient(for: item))
        .clipShape(Capsule())
        .opacity(selectedData == nil || selectedData?.id == item.id ? 1.0 : 0.4)

        PointMark(
            x: .value("日付", item.date, unit: .day),
            y: .value("最高", item.highTemperature + 1.5)
        )
        .symbol {
            Image(systemName: item.symbolName)
                .symbolRenderingMode(.multicolor)
                .font(.caption)
        }
    }

    // MARK: - Style Picker

    private var stylePickerView: some View {
        Picker("スタイル", selection: $chartStyle) {
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
