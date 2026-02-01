import Charts
import SwiftUI

/// 降水確率チャートビュー
/// Swift Charts の BarMark のサンプル（色分け、アノテーション）
struct PrecipitationChartView: View {
    let hourlyData: [HourlyChartData]
    let dailyData: [DailyChartData]

    @State private var dataType: DataType = .hourly
    @State private var selectedHourly: HourlyChartData?
    @State private var selectedDaily: DailyChartData?

    enum DataType: String, CaseIterable {
        case hourly = "時間ごと"
        case daily = "日ごと"
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

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("降水確率", systemImage: "drop.fill")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(dataType == .hourly ? "24時間の降水確率" : "10日間の降水確率")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Data Type Picker

    private var dataTypePickerView: some View {
        Picker("データタイプ", selection: $dataType) {
            ForEach(DataType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
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

    private var hourlyChartView: some View {
        Chart(hourlyData) { item in
            BarMark(
                x: .value("時間", item.date),
                y: .value("降水確率", item.precipitationChance * 100)
            )
            .foregroundStyle(precipitationColor(for: item.precipitationChance))
            .cornerRadius(2)
            .opacity(selectedHourly == nil || selectedHourly?.id == item.id ? 1.0 : 0.4)

            if item.precipitationChance >= 0.5 {
                RuleMark(y: .value("高確率", 50))
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

    private var dailyChartView: some View {
        Chart(dailyData) { item in
            BarMark(
                x: .value("日付", item.date, unit: .day),
                y: .value("降水確率", item.precipitationChance * 100),
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
            legendItem(color: .green, text: "低 (0-30%)")
            legendItem(color: .yellow, text: "中 (30-50%)")
            legendItem(color: .cyan, text: "高 (50%+)")
        }
        .font(.caption2)
    }

    private func legendItem(color: Color, text: String) -> some View {
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
                Text(String(format: "降水確率: %.0f%%", data.precipitationChance * 100))
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
                Text(String(format: "降水確率: %.0f%%", data.precipitationChance * 100))
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
