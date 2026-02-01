import Charts
import Spatial
import SwiftUI

/// 3Dポイントグラフビュー
/// Swift Charts の Chart3D + PointMark (with z) のサンプル
/// 時間×気温×降水確率を3D空間にプロット
struct Weather3DPointChartView: View {
    let data: [Chart3DDataPoint]

    @State private var colorMode: ColorMode = .temperature

    enum ColorMode: String, CaseIterable {
        case temperature = "気温"
        case precipitation = "降水確率"
        case period = "時間帯"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView

            colorModePicker

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
            Label("3D ポイントグラフ", systemImage: "circle.hexagongrid")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("時間 × 気温 × 降水確率")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Color Mode Picker

    private var colorModePicker: some View {
        Picker("色分け", selection: $colorMode) {
            ForEach(ColorMode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - 3D Chart View

    private var chart3DView: some View {
        Chart3D(data) { item in
            PointMark(
                x: .value("時間", item.hour),
                y: .value("気温", item.temperature),
                z: .value("降水確率", item.precipitationChance * 100)
            )
            .foregroundStyle(pointColor(for: item))
            .symbolSize(symbolSize(for: item))
        }
        .chart3DPose(Chart3DPose(azimuth: .degrees(45), inclination: .degrees(15)))
        .animation(.easeInOut(duration: 0.3), value: colorMode)
    }

    // MARK: - Legend View

    @ViewBuilder
    private var legendView: some View {
        switch colorMode {
        case .temperature:
            temperatureLegend

        case .precipitation:
            precipitationLegend

        case .period:
            periodLegend
        }
    }

    private var temperatureLegend: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("気温による色分け")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                legendItem(color: .cyan, text: "低温")
                legendItem(color: .green, text: "適温")
                legendItem(color: .orange, text: "高温")
            }
            .font(.caption2)
        }
    }

    private var precipitationLegend: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("降水確率による色分け")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                legendItem(color: .green, text: "0-30%")
                legendItem(color: .yellow, text: "30-50%")
                legendItem(color: .blue, text: "50%+")
            }
            .font(.caption2)
        }
    }

    private var periodLegend: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("時間帯による色分け")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                legendItem(color: .yellow, text: "朝")
                legendItem(color: .orange, text: "昼")
                legendItem(color: .purple, text: "夕")
                legendItem(color: .indigo, text: "夜")
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

    private func pointColor(for item: Chart3DDataPoint) -> Color {
        switch colorMode {
        case .temperature:
            temperatureColor(for: item.temperature)

        case .precipitation:
            precipitationColor(for: item.precipitationChance)

        case .period:
            periodColor(for: item.period)
        }
    }

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

    private func precipitationColor(for chance: Double) -> Color {
        switch chance {
        case ..<0.3:
            .green

        case 0.3 ..< 0.5:
            .yellow

        default:
            .blue
        }
    }

    private func periodColor(for period: TimePeriod) -> Color {
        switch period {
        case .morning:
            .yellow

        case .afternoon:
            .orange

        case .evening:
            .purple

        case .night:
            .indigo
        }
    }

    private func symbolSize(for item: Chart3DDataPoint) -> CGFloat {
        let baseSize: CGFloat = 50
        let scale = 1.0 + item.precipitationChance
        return baseSize * scale
    }
}

// MARK: - Preview

#Preview(traits: .modifier(.mock)) {
    ScrollView {
        Weather3DPointChartView(
            data: ChartPreviewData.makeHourlyData().to3DDataPoints()
        )
        .padding()
    }
    .background(Color.blue.opacity(0.3))
}
