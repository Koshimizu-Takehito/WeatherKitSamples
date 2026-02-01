---
name: swiftui-view-components
description: 大きなSwiftUI Viewを単責任のコンポーネントに分割するリファクタリング。struct+extension分離、メソッド参照パターン、状態別View分割、ToolbarContent共通化、インライン定義の子View分離を適用する場合に使用。「Viewを分割」「コンポーネント化」「可読性を向上」などのリクエストで使用。
---

# SwiftUI View コンポーネント分割

大きなViewを単責任のコンポーネントに分割するパターン集。

## struct定義とView準拠の分離

すべてのViewでstruct定義とView準拠をextensionで分離する。

```swift
struct FeatureView {
    @Environment(FeatureViewModel.self) private var viewModel
    @State private var isShowingSheet = false
}

extension FeatureView: View {
    var body: some View { ... }
}
```

コンポーネントViewも同様:

```swift
struct DetailCardView {
    let title: String
    let value: String
}

extension DetailCardView: View {
    var body: some View { ... }
}
```

## メソッド参照によるモディファイア接続

bodyではクロージャではなくメソッド参照を`content:`引数に渡し、フラットに保つ。

```swift
var body: some View {
    Group(content: contentView)
        .background(content: backgroundGradient)
        .overlay(content: loadingOverlay)
        .toolbar(content: featureToolbar)
        .sheet(isPresented: $isShowingSheet, content: sheetContent)
        .navigationDestination(isPresented: $isShowingDetail, destination: detailDestination)
}

// content: に渡すメソッドはfuncで定義
private func backgroundGradient() -> some View {
    LinearGradient(...)
        .ignoresSafeArea()
}

// @ViewBuilder: if/switch分岐を含む場合に付与
@ViewBuilder
private func contentView() -> some View {
    switch viewModel.state { ... }
}

// @ToolbarContentBuilder: ToolbarContent返却に使用
@ToolbarContentBuilder
private func featureToolbar() -> some ToolbarContent {
    ToolbarItem(placement: .cancellationAction) { ... }
}
```

`@Bindable`が必要な場合、body内でローカル変換してからBindingを渡す:

```swift
var body: some View {
    @Bindable var viewModel = viewModel

    List {
        searchSection(searchText: $viewModel.searchText)
    }
}

private func searchSection(searchText: Binding<String>) -> some View {
    Section {
        TextField("検索", text: searchText)
    }
}
```

## 状態別View分割

ViewModelのState enumの各caseに対応するViewをComponents/に作成する。

### ディレクトリ構成

```
Feature/
├── FeatureView.swift          # メインView（struct+extension分離）
├── FeatureViewModel.swift     # ViewModel + State enum
└── Components/
    ├── FeatureInitialView.swift
    ├── FeatureLoadingView.swift
    ├── FeatureErrorView.swift
    ├── FeatureContentView.swift
    └── FeatureToolbarContent.swift
```

### 設計原則

- 子ViewはEnvironmentからViewModelを直接取得（親からプロパティで渡さない）
- UI操作のためのBindingのみ親から渡す（例: `$isShowingLocationSearch`）
- Preview可能な単位で分割

### 実装例: ErrorView

```swift
struct FeatureErrorView {
    @Environment(FeatureViewModel.self) private var viewModel
    let message: String
}

extension FeatureErrorView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("再試行") {
                Task { await viewModel.retry() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
```

## インライン定義の子View分離

View内にprivate structとしてインライン定義されたコンポーネントをComponents/に分離する。

### Before

```swift
// DailyForecastView.swift
struct DailyForecastView: View { ... }

private struct DailyForecastItemView: View { ... }
```

### After

```swift
// DailyForecastView.swift
struct DailyForecastView { ... }
extension DailyForecastView: View { ... }

// Components/DailyForecastItemView.swift
struct DailyForecastItemView { ... }
extension DailyForecastItemView: View { ... }
```

分離時に`private`を`internal`（デフォルト）に変更する。

## ToolbarContent の共通化

ToolbarContentは独立したstructとして定義し、EnvironmentからViewModelを直接取得する。

```swift
struct FeatureToolbarContent: ToolbarContent {
    @Environment(FeatureViewModel.self) private var viewModel
    @Binding var isShowingCharts: Bool
    @Binding var isShowingSearch: Bool

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem(placement: .primaryAction) { searchButton }
        ToolbarItem(placement: .primaryAction) { chartsButton }
        #else
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 16) {
                chartsButton
                searchButton
            }
        }
        #endif
    }

    private var chartsButton: some View {
        Button { isShowingCharts = true } label: {
            Image(systemName: "chart.xyaxis.line")
        }
    }

    private var searchButton: some View {
        Button { isShowingSearch = true } label: {
            Image(systemName: "magnifyingglass")
        }
    }
}
```

## UI表現ロジックの分離

ViewModelからUI固有のロジック（Color, Font等）を分離する。

```swift
// WeatherGradient.swift（Components/に配置）
enum WeatherGradient {
    static func colors(for state: HomeViewModel.State) -> [Color] {
        guard let weather = state.weather else {
            return defaultColors
        }
        return colors(for: weather.current.condition)
    }

    static var defaultColors: [Color] {
        [.blue.opacity(0.6), .cyan.opacity(0.4)]
    }
}
```

## 適用手順

1. **struct+extension分離**: すべての対象Viewにstruct定義とView準拠の分離を適用
2. **メソッド参照化**: bodyのクロージャをメソッド参照に変換
3. **状態分析**: ViewModelのState enumの各caseを特定
4. **コンポーネント作成**: 各状態に対応するViewをComponents/に作成
5. **インライン子View分離**: private structをComponents/に分離
6. **ToolbarContent抽出**: 独立したstructとして定義
7. **UIロジック分離**: Color計算等を専用enumに移動

実装例は [references/HomeView.swift](references/HomeView.swift) を参照。
