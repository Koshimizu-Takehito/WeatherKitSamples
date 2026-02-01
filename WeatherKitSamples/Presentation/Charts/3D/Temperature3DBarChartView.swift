import Charts
import Spatial
import SwiftUI

/// A 3D bar chart view displaying temperature by day and time period.
///
/// Demonstrates the use of `Chart3D` with `PointMark` and z-axis
/// to visualize date, time period, and temperature in 3D space.
///
/// ## Swift Charts 3D Techniques
///
/// - **PointMark with z-axis**: Uses z for temperature values.
/// - **Categorical Axes**: Date and time period as categorical dimensions.
/// - **Temperature-based Coloring**: Visual encoding of temperature range.
/// - **chart3DPose**: Camera positioning for optimal data view.
///
/// ## Learning Points
///
/// - Using categorical data on x and y axes with numeric z
/// - Color coding for additional data dimension
/// - Aggregated period data for cleaner 3D visualization
///
/// - SeeAlso: ``Chart3DPeriodData`` for the aggregated data structure.
struct Temperature3DBarChartView: View {
    /// The aggregated period data to display.
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
            Label("3D Temperature Chart", systemImage: "cube")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Date x Time Period x Temperature")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - 3D Chart View

    /// The 3D chart with categorical x/y axes and numeric z.
    ///
    /// ## Axis Mapping
    ///
    /// - X-axis: Date (categorical)
    /// - Y-axis: Time period (categorical: Morning, Afternoon, Evening, Night)
    /// - Z-axis: Average temperature during that period
    private var chart3DView: some View {
        Chart3D(data) { item in
            PointMark(
                x: .value("Date", item.dayString),
                y: .value("Period", item.period.rawValue),
                z: .value("Temperature", item.averageTemperature)
            )
            .foregroundStyle(temperatureColor(for: item.averageTemperature))
            .symbolSize(100)
        }
        .chart3DPose(Chart3DPose(azimuth: .degrees(30), inclination: .degrees(20)))
    }

    // MARK: - Legend View

    private var legendView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Color by Temperature")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                legendItem(color: .cyan, text: "Low (<15°C)")
                legendItem(color: .green, text: "Moderate (15-20°C)")
                legendItem(color: .orange, text: "High (>20°C)")
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
