import Charts
import Spatial
import SwiftUI

/// A 3D scatter plot view displaying weather data points.
///
/// Demonstrates the use of `Chart3D` with `PointMark` using the z-axis
/// to plot time, temperature, and precipitation in 3D space.
///
/// ## Swift Charts 3D Techniques
///
/// - **PointMark with z-axis**: Creates 3D scatter plot points.
/// - **Dynamic Coloring**: Points colored based on selectable criteria.
/// - **Variable Symbol Size**: Point size scales with precipitation chance.
/// - **chart3DPose**: Sets initial camera angle for optimal viewing.
///
/// ## Learning Points
///
/// - Using `Chart3D` container for 3D visualizations
/// - Adding z-axis dimension to existing marks
/// - Implementing multiple color modes for data exploration
/// - Gesture-based interaction for 3D charts
///
/// - SeeAlso: [PointMark](https://developer.apple.com/documentation/charts/pointmark)
struct Weather3DPointChartView: View {
    /// The 3D data points to display.
    let data: [Chart3DDataPoint]

    @State private var colorMode: ColorMode = .temperature

    /// Color mode options for point visualization.
    enum ColorMode: String, CaseIterable {
        case temperature = "Temperature"
        case precipitation = "Precipitation"
        case period = "Time Period"
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
            Label("3D Point Chart", systemImage: "circle.hexagongrid")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Hour x Temperature x Precipitation")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Color Mode Picker

    private var colorModePicker: some View {
        Picker("Color by", selection: $colorMode) {
            ForEach(ColorMode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - 3D Chart View

    /// The 3D chart using PointMark with z-axis.
    ///
    /// ## Implementation Notes
    ///
    /// - X-axis: Hour of day (0-23)
    /// - Y-axis: Temperature in Celsius
    /// - Z-axis: Precipitation probability (0-100%)
    /// - Point color: Based on selected color mode
    /// - Point size: Scales with precipitation chance
    private var chart3DView: some View {
        Chart3D(data) { item in
            PointMark(
                x: .value("Hour", item.hour),
                y: .value("Temperature", item.temperature),
                z: .value("Precipitation", item.precipitationChance * 100)
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
            Text("Color by Temperature")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                legendItem(color: .cyan, text: "Low")
                legendItem(color: .green, text: "Moderate")
                legendItem(color: .orange, text: "High")
            }
            .font(.caption2)
        }
    }

    private var precipitationLegend: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Color by Precipitation")
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
            Text("Color by Time Period")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                legendItem(color: .yellow, text: "Morning")
                legendItem(color: .orange, text: "Afternoon")
                legendItem(color: .purple, text: "Evening")
                legendItem(color: .indigo, text: "Night")
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
