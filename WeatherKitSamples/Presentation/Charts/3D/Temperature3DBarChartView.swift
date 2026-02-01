import Charts
import Spatial
import SwiftUI

/// 3D棒グラフビュー
/// Swift Charts の Chart3D + PointMark (with z) のサンプル
/// 日付×時間帯×気温を3D空間で表示
struct Temperature3DBarChartView: View {
    let data: [Chart3DPeriodData]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView

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
            Label("3D 気温グラフ", systemImage: "cube")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("日付 × 時間帯 × 気温")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - 3D Chart View

    private var chart3DView: some View {
        Chart3D(data) { item in
            PointMark(
                x: .value("日付", item.dayString),
                y: .value("時間帯", item.period.rawValue),
                z: .value("気温", item.averageTemperature)
            )
            .foregroundStyle(temperatureColor(for: item.averageTemperature))
            .symbolSize(100)
        }
        .chart3DPose(Chart3DPose(azimuth: .degrees(30), inclination: .degrees(20)))
    }

    // MARK: - Legend View

    private var legendView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("気温による色分け")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                legendItem(color: .cyan, text: "低温 (<15°C)")
                legendItem(color: .green, text: "適温 (15-20°C)")
                legendItem(color: .orange, text: "高温 (>20°C)")
            }
            .font(.caption2)
        }
    }

    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(text)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Helpers

    private func temperatureColor(for temperature: Double) -> Color {
        switch temperature {
        case ..<15:
            .cyan

        case 15 ..< 20:
            .green

        default:
            .orange
        }
    }
}

// MARK: - Preview

#Preview(traits: .modifier(.mock)) {
    ScrollView {
        Temperature3DBarChartView(
            data: ChartPreviewData.makeHourlyData().to3DPeriodData()
        )
        .padding()
    }
    .background(Color.blue.opacity(0.3))
}
