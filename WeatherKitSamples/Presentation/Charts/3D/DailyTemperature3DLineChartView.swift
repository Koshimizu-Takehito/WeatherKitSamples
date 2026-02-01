import Charts
import Spatial
import SwiftUI

/// 3D折れ線グラフビュー
/// Swift Charts の Chart3D + RuleMark/PointMark (with z) のサンプル
/// 複数日の気温推移を3D空間で比較表示
struct DailyTemperature3DLineChartView: View {
    let multiDayData: [[HourlyChartData]]

    @State private var showAllDays: Bool = true

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
            Label("3D 気温推移グラフ", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("複数日の気温推移を比較")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Toggle View

    private var toggleView: some View {
        Toggle("全ての日を表示", isOn: $showAllDays)
            .font(.subheadline)
            .tint(.accentColor)
    }

    // MARK: - 3D Chart View

    private var chart3DView: some View {
        Chart3D(processedData) { item in
            PointMark(
                x: .value("時間", item.hour),
                y: .value("日", item.dayIndex),
                z: .value("気温", item.temperature)
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
            Text("日ごとの色分け")
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
            Text(text)
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
        case 0: "今日"
        case 1: "明日"
        case 2: "明後日"
        default: "\(index + 1)日目"
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
