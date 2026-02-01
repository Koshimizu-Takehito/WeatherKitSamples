import SwiftUI

// MARK: - WeatherChartsView

/// 天気チャートの統合ショーケースビュー
/// Swift Charts のサンプルとして各種チャートタイプを展示
struct WeatherChartsView {
    @Environment(HomeViewModel.self) private var viewModel

    @State private var selectedTab: ChartTab = .hourlyTemperature
    @State private var showing3DCharts = false

    enum ChartTab: String, CaseIterable {
        case hourlyTemperature = "時間別気温"
        case dailyTemperature = "日別気温"
        case precipitation = "降水確率"
        case charts3D = "3D Charts"
        case all = "すべて"

        var icon: String {
            switch self {
            case .hourlyTemperature: "clock"
            case .dailyTemperature: "calendar"
            case .precipitation: "drop.fill"
            case .charts3D: "cube.transparent"
            case .all: "chart.bar.xaxis"
            }
        }

        var description: String {
            switch self {
            case .hourlyTemperature: "LineMark, AreaMark, PointMark"
            case .dailyTemperature: "BarMark (yStart/yEnd), RuleMark"
            case .precipitation: "BarMark, RuleMark"
            case .charts3D: "BarMark3D, PointMark3D, LineMark3D"
            case .all: "すべてのチャートを表示"
            }
        }

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
        .navigationTitle("Swift Charts")
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

            Text("Swift Charts サンプル")
                .font(.title2)
                .fontWeight(.bold)

            Text("天気データを使用した各種チャートの実装例")
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
                Text(tab.rawValue)
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

            Text("iOS 26+ / macOS 26+ で利用可能な\nChart3D APIを使用した3Dチャート")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
                Button {
                    showing3DCharts = true
                } label: {
                    Label("3Dチャートを表示", systemImage: "arrow.right.circle.fill")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            } else {
                Text("iOS 26+ / macOS 26+ が必要です")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .padding()
                    .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("含まれるチャート:")
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
            Text(name)
                .font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.indigo.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }

    private var allChartsView: some View {
        VStack(spacing: 20) {
            chartSection(title: "時間別気温", icon: "clock", description: "LineMark, AreaMark, PointMark") {
                HourlyTemperatureChartView(data: viewModel.hourlyChartData)
            }

            chartSection(title: "日別気温範囲", icon: "calendar", description: "BarMark (yStart/yEnd), RuleMark") {
                DailyTemperatureRangeChartView(data: viewModel.dailyChartData)
            }

            chartSection(title: "降水確率", icon: "drop.fill", description: "BarMark, アノテーション") {
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

                Text(description)
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
            Label("使用している Swift Charts コンポーネント", systemImage: "info.circle")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(selectedTab.description)
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
                    description: "データポイントを線で結ぶ折れ線グラフ"
                )
                markDescription(
                    name: "AreaMark",
                    description: "線の下を塗りつぶすエリアチャート"
                )
                markDescription(
                    name: "PointMark",
                    description: "各データポイントを示すマーカー"
                )
            }

        case .dailyTemperature:
            VStack(alignment: .leading, spacing: 8) {
                markDescription(
                    name: "BarMark (yStart/yEnd)",
                    description: "開始と終了値を指定した範囲バー"
                )
                markDescription(
                    name: "RuleMark",
                    description: "線状のマーク（しきい値や範囲表示に使用）"
                )
                markDescription(
                    name: "PointMark",
                    description: "最高/最低気温のポイント表示"
                )
            }

        case .precipitation:
            VStack(alignment: .leading, spacing: 8) {
                markDescription(
                    name: "BarMark",
                    description: "値を棒グラフで表示"
                )
                markDescription(
                    name: "annotation",
                    description: "バーの上に値を表示するアノテーション"
                )
                markDescription(
                    name: "RuleMark",
                    description: "しきい値（50%）を示す破線"
                )
            }

        case .charts3D:
            VStack(alignment: .leading, spacing: 8) {
                markDescription(
                    name: "BarMark3D",
                    description: "3D空間に棒グラフを配置"
                )
                markDescription(
                    name: "PointMark3D",
                    description: "3D空間にデータポイントをプロット"
                )
                markDescription(
                    name: "LineMark3D",
                    description: "3D空間に折れ線を描画"
                )
            }

        case .all:
            EmptyView()
        }
    }

    private func markDescription(name: String, description: String) -> some View {
        HStack(alignment: .top) {
            Text("•")
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
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
