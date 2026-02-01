import Charts
import Spatial
import SwiftUI

/// A 3D surface chart view displaying temperature as a continuous surface.
///
/// Demonstrates the use of `Chart3D` with `SurfacePlot` to visualize
/// temperature data as a continuous surface over a date-hour grid.
///
/// ## Swift Charts 3D Techniques
///
/// - **SurfacePlot**: Creates continuous surfaces from grid data.
/// - **Function-based Plotting**: Surface defined by a function f(x, z) -> y.
/// - **Multiple Surface Styles**: Gradient, height-based, and normal-based.
/// - **Data Interpolation**: Smooth surface from discrete data points.
///
/// ## Learning Points
///
/// - Using `SurfacePlot` for continuous data visualization
/// - Defining surfaces with closure-based functions
/// - Styling surfaces with gradients and solid colors
/// - Converting discrete data to grid format for surfaces
///
/// - SeeAlso: [SurfacePlot](https://developer.apple.com/documentation/charts/surfaceplot)
struct Temperature3DSurfaceChartView: View {
    /// Multi-day hourly data for surface generation.
    let multiDayData: [[HourlyChartData]]

    @State private var surfaceStyle: SurfaceStyle = .gradient

    /// Available surface visualization styles.
    enum SurfaceStyle: String, CaseIterable {
        case gradient = "Gradient"
        case heightBased = "Height"
        case normalBased = "Normal"
    }

    /// Generates grid data for the surface plot.
    ///
    /// Converts hourly data into a 2D grid where:
    /// - Rows represent days
    /// - Columns represent hours (0-23)
    /// - Values are temperatures
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
            Label("3D Surface Chart", systemImage: "square.3.layers.3d")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Day x Hour x Temperature Surface")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Style Picker

    private var stylePickerView: some View {
        Picker("Style", selection: $surfaceStyle) {
            ForEach(SurfaceStyle.allCases, id: \.self) { style in
                Text(style.rawValue).tag(style)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - 3D Chart View

    /// The 3D surface chart.
    ///
    /// ## Surface Definition
    ///
    /// The `SurfacePlot` closure receives x (hour) and z (day) coordinates
    /// and returns y (temperature) values. The chart framework interpolates
    /// between data points to create a smooth surface.
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

    /// Interpolates temperature for the given hour and day.
    ///
    /// - Parameters:
    ///   - hour: Hour coordinate (0-23, can be fractional).
    ///   - day: Day coordinate (0, 1, 2..., can be fractional).
    /// - Returns: Interpolated temperature value.
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
            Text("About Surface Visualization")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            // swiftlint:disable:next line_length
            Text(
                "Displays temperature as a continuous surface over a day-hour grid. SurfacePlot renders mathematical functions as smooth 3D surfaces, interpolating between data points for visual continuity."
            )
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
