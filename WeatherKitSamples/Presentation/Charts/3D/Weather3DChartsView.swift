import SwiftUI

/// 3Dチャートの統合ショーケースビュー
/// Swift Charts 3D API のサンプルとして各種3Dチャートタイプを展示
struct Weather3DChartsView: View {
    let hourlyData: [HourlyChartData]
    let multiDayData: [[HourlyChartData]]

    @State private var selectedTab: Chart3DTab = .point

    enum Chart3DTab: String, CaseIterable {
        case point = "ポイント"
        case multiDay = "複数日"
        case surface = "サーフェス"
        case all = "すべて"

        var icon: String {
            switch self {
            case .point: "circle.hexagongrid"
            case .multiDay: "chart.line.uptrend.xyaxis"
            case .surface: "square.3.layers.3d"
            case .all: "cube.transparent"
            }
        }

        var markName: String {
            switch self {
            case .point: "PointMark + z"
            case .multiDay: "PointMark + z (複数系列)"
            case .surface: "SurfacePlot"
            case .all: "全Mark"
            }
        }

        var description: String {
            switch self {
            case .point: "3D空間にデータポイントをプロット。多変量データの可視化に使用。"
            case .multiDay: "複数日のデータを3D空間で比較表示。"
            case .surface: "連続的なサーフェス（曲面）を表示。グリッドデータの可視化に使用。"
            case .all: "すべての3Dチャートタイプを表示します。"
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
        .navigationTitle("3D Charts")
        .navigationBarTitleDisplayMode(.inlineOnPhone)
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "cube.transparent.fill")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text("Swift Charts 3D サンプル")
                .font(.title2)
                .fontWeight(.bold)

            Text("Chart3D API を使用した3Dチャートの実装例")
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
        Text("iOS 26+ / macOS 26+ / visionOS 26+")
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
                Text(tab.rawValue)
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
            chartSection(title: "3Dポイントグラフ", icon: "circle.hexagongrid", markName: "PointMark + z") {
                Weather3DPointChartView(data: hourlyData.to3DDataPoints())
            }

            chartSection(title: "3D複数日グラフ", icon: "chart.line.uptrend.xyaxis", markName: "PointMark + z") {
                DailyTemperature3DLineChartView(multiDayData: multiDayData)
            }

            chartSection(title: "3Dサーフェスグラフ", icon: "square.3.layers.3d", markName: "SurfacePlot") {
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

                Text(markName)
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
            Label("使用している Chart3D コンポーネント", systemImage: "info.circle")
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack {
                Text(selectedTab.markName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.accentColor.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))

                Spacer()
            }

            Text(selectedTab.description)
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
            Text("Chart3D の特徴")
                .font(.subheadline)
                .fontWeight(.medium)

            featureItem(icon: "hand.draw", text: "ジェスチャーで回転・ズーム可能")
            featureItem(icon: "cube", text: "3軸でデータを可視化")
            featureItem(icon: "paintbrush", text: "foregroundStyle でスタイリング")
            featureItem(icon: "camera", text: "chart3DPose でカメラ位置を設定")
        }
    }

    private func featureItem(icon: String, text: String) -> some View {
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
