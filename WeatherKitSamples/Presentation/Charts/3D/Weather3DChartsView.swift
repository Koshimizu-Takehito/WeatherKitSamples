import SwiftUI

/// A showcase view demonstrating various 3D chart visualizations.
///
/// This view serves as a gallery of Chart3D types available in iOS 26+,
/// using weather data to demonstrate different 3D visualization techniques.
///
/// ## Overview
///
/// The showcase includes:
/// - **Point Chart**: 3D scatter plot using PointMark with z-axis
/// - **Multi-Day Chart**: Multiple day comparison in 3D space
/// - **Surface Chart**: Continuous surface visualization with SurfacePlot
///
/// ## Learning Points
///
/// - Using `Chart3D` container for 3D visualizations
/// - Setting camera position with `chart3DPose`
/// - Gesture-based rotation and zoom interaction
/// - Platform availability handling with `@available`
///
/// - SeeAlso: [Charts 3D](https://developer.apple.com/documentation/charts)
struct Weather3DChartsView: View {
    /// Hourly weather data for single-day charts.
    let hourlyData: [HourlyChartData]

    /// Multi-day hourly data for comparison charts.
    let multiDayData: [[HourlyChartData]]

    @State private var selectedTab: Chart3DTab = .point

    /// Available 3D chart type tabs.
    enum Chart3DTab: String, CaseIterable {
        case point = "Point"
        case multiDay = "Multi-Day"
        case surface = "Surface"
        case all = "All"

        /// SF Symbol name for the tab icon.
        var icon: String {
            switch self {
            case .point: "circle.hexagongrid"
            case .multiDay: "chart.line.uptrend.xyaxis"
            case .surface: "square.3.layers.3d"
            case .all: "cube.transparent"
            }
        }

        /// The Chart3D mark type name.
        var markName: String {
            switch self {
            case .point: "PointMark + z"
            case .multiDay: "PointMark + z (Multi-series)"
            case .surface: "SurfacePlot"
            case .all: "All Marks"
            }
        }

        /// Description of what the chart demonstrates.
        var description: String {
            switch self {
            case .point: "Plots data points in 3D space. Used for multi-variate data visualization."
            case .multiDay: "Compares multiple days of data in 3D space."
            case .surface: "Displays continuous surfaces. Used for grid data visualization."
            case .all: "Displays all 3D chart types together."
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView

                tabSelectionView

                chartContentView

                if selectedTab != .all {
                    chartInfoView
                }
            }
            .padding()
        }
        .background(backgroundGradient.ignoresSafeArea())
        .navigationTitle(Text(._3DCharts))
        .navigationBarTitleDisplayMode(.inlineOnPhone)
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "cube.transparent.fill")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text(.swiftCharts3DSamples)
                .font(.title2)
                .fontWeight(.bold)

            Text(.chart3DApiImplementationExamples)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            availabilityBadge
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var availabilityBadge: some View {
        Text(verbatim: "iOS 26+ / macOS 26+ / visionOS 26+")
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(.blue.opacity(0.2), in: Capsule())
            .foregroundStyle(.blue)
    }

    // MARK: - Tab Selection View

    private var tabSelectionView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Chart3DTab.allCases, id: \.self) { tab in
                    tabButton(for: tab)
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func tabButton(for tab: Chart3DTab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.title3)
                Text(verbatim: tab.rawValue)
                    .font(.caption2)
            }
            .frame(width: 70, height: 56)
            .background(
                selectedTab == tab
                    ? AnyShapeStyle(Color.accentColor)
                    : AnyShapeStyle(.ultraThinMaterial)
            )
            .foregroundStyle(selectedTab == tab ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Chart Content View

    @ViewBuilder
    private var chartContentView: some View {
        switch selectedTab {
        case .point:
            Weather3DPointChartView(
                data: hourlyData.to3DDataPoints()
            )
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))

        case .multiDay:
            DailyTemperature3DLineChartView(
                multiDayData: multiDayData
            )
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))

        case .surface:
            Temperature3DSurfaceChartView(
                multiDayData: multiDayData
            )
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))

        case .all:
            allChartsView
                .transition(.opacity)
        }
    }

    private var allChartsView: some View {
        VStack(spacing: 20) {
            chartSection(title: "3D Point Chart", icon: "circle.hexagongrid", markName: "PointMark + z") {
                Weather3DPointChartView(data: hourlyData.to3DDataPoints())
            }

            chartSection(title: "3D Multi-Day Chart", icon: "chart.line.uptrend.xyaxis", markName: "PointMark + z") {
                DailyTemperature3DLineChartView(multiDayData: multiDayData)
            }

            chartSection(title: "3D Surface Chart", icon: "square.3.layers.3d", markName: "SurfacePlot") {
                Temperature3DSurfaceChartView(multiDayData: multiDayData)
            }
        }
    }

    private func chartSection(
        title: String,
        icon: String,
        markName: String,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline)

                Spacer()

                Text(verbatim: markName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.quaternary, in: Capsule())
            }

            content()
        }
    }

    // MARK: - Chart Info View

    private var chartInfoView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(.chart3DComponentUsed, systemImage: "info.circle")
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack {
                Text(verbatim: selectedTab.markName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.accentColor.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))

                Spacer()
            }

            Text(verbatim: selectedTab.description)
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            chart3DFeatures
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var chart3DFeatures: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(.chart3DFeatures)
                .font(.subheadline)
                .fontWeight(.medium)

            featureItem(icon: "hand.draw", text: .rotateAndZoomWithGestures)
            featureItem(icon: "cube", text: .visualizeDataAcross3Axes)
            featureItem(icon: "paintbrush", text: .styleWithForegroundStyle)
            featureItem(icon: "camera", text: .setCameraPositionWithChart3Dpose)
        }
    }

    private func featureItem(icon: String, text: LocalizedStringResource) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Color.accentColor)
                .frame(width: 20)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [.indigo.opacity(0.3), .purple.opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Preview

#Preview(traits: .modifier(.mock)) {
    NavigationStack {
        Weather3DChartsView(
            hourlyData: ChartPreviewData.makeHourlyData(),
            multiDayData: ChartPreviewData.makeMultiDayGroupedData()
        )
    }
}
