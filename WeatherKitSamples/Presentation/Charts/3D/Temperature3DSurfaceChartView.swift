import Charts
import Spatial
import SwiftUI

/// 3Dサーフェスグラフビュー
/// Swift Charts の Chart3D + SurfacePlot のサンプル
/// 日付×時間に対する気温を連続的なサーフェス（曲面）で表示
struct Temperature3DSurfaceChartView: View {
    let multiDayData: [[HourlyChartData]]

    @State private var surfaceStyle: SurfaceStyle = .gradient

    enum SurfaceStyle: String, CaseIterable {
        case gradient = "グラデーション"
        case heightBased = "高さベース"
        case normalBased = "法線ベース"
    }

    /// サーフェス用のグリッドデータを生成
    private nonisolated var surfaceData: [[Double]] {
        multiDayData.map { dayData in
            var hourlyTemps = Array(repeating: 15.0, count: 24)
            let calendar = Calendar.current

            for item in dayData {
                let hour = calendar.component(.hour, from: item.date)
                if hour < 24 {
                    hourlyTemps[hour] = item.temperature
                }
            }

            return hourlyTemps
        }
    }

    private var temperatureRange: ClosedRange<Double> {
        let allTemps = surfaceData.flatMap(\.self)
        let minTemp = (allTemps.min() ?? 0) - 2
        let maxTemp = (allTemps.max() ?? 30) + 2
        return minTemp ... maxTemp
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView

            stylePickerView

            chart3DView
                .frame(height: 350)

            infoView
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("3D サーフェスグラフ", systemImage: "square.3.layers.3d")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("日 × 時間 × 気温のサーフェス")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Style Picker

    private var stylePickerView: some View {
        Picker("スタイル", selection: $surfaceStyle) {
            ForEach(SurfaceStyle.allCases, id: \.self) { style in
                Text(style.rawValue).tag(style)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - 3D Chart View

    private var chart3DView: some View {
        Chart3D {
            SurfacePlot(x: "hour", y: "temperature", z: "day") { hour, day in
                interpolatedTemperature(hour: hour, day: day)
            }
            .foregroundStyle(surfaceForegroundStyle)
        }
        .chart3DPose(Chart3DPose(azimuth: .degrees(35), inclination: .degrees(25)))
        .animation(.easeInOut(duration: 0.3), value: surfaceStyle)
    }

    /// 時間と日から補間された気温を計算
    private nonisolated func interpolatedTemperature(hour: Double, day: Double) -> Double {
        let dayIndex = Int(day.rounded())
        let hourIndex = Int(hour.rounded())

        guard dayIndex >= 0, dayIndex < surfaceData.count else {
            return 15.0
        }

        let dayTemps = surfaceData[dayIndex]
        guard hourIndex >= 0, hourIndex < dayTemps.count else {
            return 15.0
        }

        return dayTemps[hourIndex]
    }

    private var surfaceForegroundStyle: some ShapeStyle {
        switch surfaceStyle {
        case .gradient:
            AnyShapeStyle(
                LinearGradient(
                    colors: [.blue, .cyan, .green, .yellow, .orange, .red],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )

        case .heightBased:
            AnyShapeStyle(Color.cyan)

        case .normalBased:
            AnyShapeStyle(Color.purple)
        }
    }

    // MARK: - Info View

    private var infoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("サーフェス表示について")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Text("日付と時間の2次元グリッド上に気温をY軸で表示し、連続的なサーフェス（曲面）として可視化しています。SurfacePlotは数学的な関数をサーフェスとして描画します。")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
}

// MARK: - Preview

#Preview(traits: .modifier(.mock)) {
    ScrollView {
        Temperature3DSurfaceChartView(
            multiDayData: ChartPreviewData.makeMultiDayGroupedData()
        )
        .padding()
    }
    .background(Color.blue.opacity(0.3))
}
