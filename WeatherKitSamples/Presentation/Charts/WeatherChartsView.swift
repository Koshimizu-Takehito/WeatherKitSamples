import SwiftUI

// MARK: - WeatherChartsView

/// A showcase view demonstrating various Swift Charts visualizations.
///
/// This view serves as a gallery of chart types, allowing users to explore
/// different visualization techniques using weather data.
///
/// ## Overview
///
/// The showcase includes:
/// - **Hourly Temperature**: LineMark, AreaMark, PointMark
/// - **Daily Temperature**: BarMark (yStart/yEnd), RuleMark
/// - **Precipitation**: BarMark with annotations
/// - **3D Charts**: Chart3D API (iOS 26+/macOS 26+)
///
/// ## Learning Points
///
/// - Tab-based navigation for chart type selection
/// - Conditional compilation for platform-specific features
/// - Integration of multiple chart components in a single view
///
/// - SeeAlso: [Swift Charts](https://developer.apple.com/documentation/charts)
struct WeatherChartsView {
    @Environment(HomeViewModel.self) private var viewModel

    @State private var selectedTab: ChartTab = .hourlyTemperature
    @State private var showing3DCharts = false

    /// Available chart type tabs.
    enum ChartTab: String, CaseIterable {
        case hourlyTemperature = "Hourly Temp"
        case dailyTemperature = "Daily Temp"
        case precipitation = "Precipitation"
        case charts3D = "3D Charts"
        case all = "All"

        /// SF Symbol name for the tab icon.
        var icon: String {
            switch self {
            case .hourlyTemperature: "clock"
            case .dailyTemperature: "calendar"
            case .precipitation: "drop.fill"
            case .charts3D: "cube.transparent"
            case .all: "chart.bar.xaxis"
            }
        }

        /// Description of the Swift Charts marks used.
        var description: String {
            switch self {
            case .hourlyTemperature: "LineMark, AreaMark, PointMark"
            case .dailyTemperature: "BarMark (yStart/yEnd), RuleMark"
            case .precipitation: "BarMark, RuleMark"
            case .charts3D: "BarMark3D, PointMark3D, LineMark3D"
            case .all: "All charts displayed together"
            }
        }

        /// Whether this tab requires 3D chart capabilities.
        var is3D: Bool {
            self == .charts3D
        }
    }
}

// MARK: View

extension WeatherChartsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView

                tabSelectionView

                chartContentView

                if selectedTab != .all, selectedTab != .charts3D {
                    chartInfoView
                }
            }
            .padding()
        }
        .background(content: backgroundGradient)
        .navigationTitle(Text(.swiftCharts))
        .navigationBarTitleDisplayMode(.inlineOnPhone)
        .navigationDestination(isPresented: $showing3DCharts, destination: charts3DDestination)
        .onChange(of: selectedTab) { _, newValue in
            if newValue == .charts3D {
                showing3DCharts = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectedTab = .hourlyTemperature
                }
            }
        }
    }

    // MARK: - Navigation Destination

    @ViewBuilder
    private func charts3DDestination() -> some View {
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            Weather3DChartsView(
                hourlyData: viewModel.hourlyChartData,
                multiDayData: ChartPreviewData.makeMultiDayGroupedData()
            )
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text(.swiftChartsSamples)
                .font(.title2)
                .fontWeight(.bold)

            Text(.chartImplementationsUsingWeatherData)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Tab Selection View

    private var tabSelectionView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ChartTab.allCases, id: \.self) { tab in
                    tabButton(for: tab)
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func tabButton(for tab: ChartTab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: tab.icon)
                Text(verbatim: tab.rawValue)
            }
            .font(.subheadline)
            .fontWeight(selectedTab == tab ? .semibold : .regular)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                selectedTab == tab
                    ? AnyShapeStyle(Color.accentColor)
                    : AnyShapeStyle(.ultraThinMaterial)
            )
            .foregroundStyle(selectedTab == tab ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Chart Content View

    @ViewBuilder
    private var chartContentView: some View {
        switch selectedTab {
        case .hourlyTemperature:
            HourlyTemperatureChartView(data: viewModel.hourlyChartData)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

        case .dailyTemperature:
            DailyTemperatureRangeChartView(data: viewModel.dailyChartData)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

        case .precipitation:
            PrecipitationChartView(hourlyData: viewModel.hourlyChartData, dailyData: viewModel.dailyChartData)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

        case .charts3D:
            charts3DNavigationCard
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

        case .all:
            allChartsView
                .transition(.opacity)
        }
    }

    private var charts3DNavigationCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "cube.transparent.fill")
                .font(.system(size: 60))
                .foregroundStyle(.indigo)

            Text("3D Charts")
                .font(.title2)
                .fontWeight(.bold)

            Text(._3DChartsUsingChart3DApiAvailableOnIOS26MacOS26)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
                Button {
                    showing3DCharts = true
                } label: {
                    Label(.view3DCharts, systemImage: "arrow.right.circle.fill")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            } else {
                Text(.requiresIOS26MacOS26)
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .padding()
                    .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(.includedCharts)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    chart3DFeature(icon: "chart.bar.fill", name: "BarMark3D")
                    chart3DFeature(icon: "circle.hexagongrid", name: "PointMark3D")
                }
                HStack(spacing: 12) {
                    chart3DFeature(icon: "chart.line.uptrend.xyaxis", name: "LineMark3D")
                    chart3DFeature(icon: "square.3.layers.3d", name: "SurfacePlot")
                }
            }
            .padding(.top, 8)
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func chart3DFeature(icon: String, name: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(.indigo)
                .frame(width: 20)
            Text(verbatim: name)
                .font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.indigo.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }

    private var allChartsView: some View {
        VStack(spacing: 20) {
            chartSection(title: "Hourly Temperature", icon: "clock", description: "LineMark, AreaMark, PointMark") {
                HourlyTemperatureChartView(data: viewModel.hourlyChartData)
            }

            chartSection(title: "Daily Temperature Range", icon: "calendar", description: "BarMark (yStart/yEnd), RuleMark") {
                DailyTemperatureRangeChartView(data: viewModel.dailyChartData)
            }

            chartSection(title: "Precipitation", icon: "drop.fill", description: "BarMark, Annotation") {
                PrecipitationChartView(hourlyData: viewModel.hourlyChartData, dailyData: viewModel.dailyChartData)
            }
        }
    }

    private func chartSection(
        title: String,
        icon: String,
        description: String,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline)

                Spacer()

                Text(verbatim: description)
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
            Label(.swiftChartsComponentsUsed, systemImage: "info.circle")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(verbatim: selectedTab.description)
                .font(.subheadline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

            markDescriptionView
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private var markDescriptionView: some View {
        switch selectedTab {
        case .hourlyTemperature:
            VStack(alignment: .leading, spacing: 8) {
                markDescription(
                    name: "LineMark",
                    description: "Line chart connecting data points"
                )
                markDescription(
                    name: "AreaMark",
                    description: "Filled area under the line"
                )
                markDescription(
                    name: "PointMark",
                    description: "Markers at each data point"
                )
            }

        case .dailyTemperature:
            VStack(alignment: .leading, spacing: 8) {
                markDescription(
                    name: "BarMark (yStart/yEnd)",
                    description: "Range bars with start and end values"
                )
                markDescription(
                    name: "RuleMark",
                    description: "Line marks for thresholds and ranges"
                )
                markDescription(
                    name: "PointMark",
                    description: "High/low temperature point indicators"
                )
            }

        case .precipitation:
            VStack(alignment: .leading, spacing: 8) {
                markDescription(
                    name: "BarMark",
                    description: "Bar chart for percentage values"
                )
                markDescription(
                    name: "annotation",
                    description: "Text labels above bars"
                )
                markDescription(
                    name: "RuleMark",
                    description: "Dashed threshold line at 50%"
                )
            }

        case .charts3D:
            VStack(alignment: .leading, spacing: 8) {
                markDescription(
                    name: "BarMark3D",
                    description: "3D bar chart in spatial view"
                )
                markDescription(
                    name: "PointMark3D",
                    description: "3D scatter plot points"
                )
                markDescription(
                    name: "LineMark3D",
                    description: "3D line connections"
                )
            }

        case .all:
            EmptyView()
        }
    }

    private func markDescription(name: String, description: String) -> some View {
        HStack(alignment: .top) {
            Text(verbatim: "•")
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading) {
                Text(verbatim: name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(verbatim: description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Background

    private func backgroundGradient() -> some View {
        LinearGradient(
            colors: [.blue.opacity(0.3), .cyan.opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Preview

#Preview(traits: .modifier(.mock)) {
    NavigationStack {
        WeatherChartsView()
    }
}
