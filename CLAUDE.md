# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリのコードを扱う際のガイダンスを提供します。

## 開発コマンド

以下の Make コマンドを使用して開発を行います:

```bash
make setup       # Mint と依存関係をインストール
make build       # iOS シミュレータ用にビルド
make build-macos # macOS 用にビルド
make test        # テストを実行
make lint        # SwiftLint を実行
make lint-fix    # SwiftLint で自動修正
make format      # SwiftFormat でコード整形
make format-check # フォーマットチェック（変更なし）
make fix         # format + lint-fix を一括実行
make ci          # CI 用の全チェック（lint, format-check, build）
make open        # Xcode でプロジェクトを開く
make clean       # ビルド成果物を削除
```

PR を提出する前に必ず `make ci` を実行してください。

## ビルド & 実行

これはiOS/macOS向けのXcodeプロジェクトです。`WeatherKitSamples.xcodeproj`をXcodeで開き、ビルド・実行してください。

**必要条件:**
- WeatherKit機能が有効なApple Developerアカウント
- 位置情報サービスの許可（現在地の天気取得用）
- ネットワークアクセス（WeatherKit API呼び出し用）

**モックモード:** `AppDependencies(isMockDataEnabled: true)` でモックDataSourceに切り替わります。

## アーキテクチャ

このプロジェクトは3層の**クリーンアーキテクチャ**に従っています:

### ドメイン層 (`Domain/`)
- **Entities**: `WeatherEntity`, `LocationEntity` - フレームワークに依存しないコアデータモデル
- **Interfaces**: データアクセス契約を定義するリポジトリプロトコル
- **UseCases**: ビジネスロジック（プロトコル: `WeatherFetchable`, `CurrentLocationFetchable`, `LocationSearchable`、実装: `WeatherFetcher`, `CurrentLocationFetcher`, `LocationSearcher`）

### データ層 (`Data/`)
- **DataSources**: `WeatherDataSourceProtocol`による抽象的なデータ取得
  - `WeatherKitDataSource`: 実際のWeatherKit API実装
  - `MockWeatherDataSource`: 開発・テスト用のモックデータ
- **Repositories**: ドメインインターフェースを実装し、データソースを調整

### プレゼンテーション層 (`Presentation/`)
- **ViewModels**: `@Observable` + `@MainActor`クラス
- **Views**: 機能別に整理されたSwiftUIビュー (Home, Weather, Location, Charts)
- **Charts**: Swift Chartsを使用した2Dチャート、3D可視化ビュー

### 依存性注入
`AppDependencies`がすべての依存オブジェクトを生成し、`View.dependencies()`経由でEnvironmentに注入します。ViewModelはEnvironmentから直接取得します（バケツリレー不要）。

## 設計パターン

### View の実装パターン

**構造体定義とView準拠の分離:**
```swift
struct HomeView {
    @Environment(HomeViewModel.self) private var viewModel
    @State private var isShowingSheet = false
}

extension HomeView: View {
    var body: some View { ... }
}
```

**メソッド参照によるモディファイア接続:**
```swift
var body: some View {
    Group(content: contentView)
        .background(content: backgroundGradient)
        .toolbar(content: homeToolbar)
        .sheet(isPresented: $isShowingSheet, content: sheetContent)
}
```
クロージャではなくメソッド参照を`content:`引数に渡し、bodyをフラットに保ちます。

**ViewModelの取得:**
- `@Environment(HomeViewModel.self)` でEnvironmentから直接参照
- 子Viewにプロパティで渡さない（各Viewが自身でEnvironmentから取得）
- `@Bindable`が必要な場合は`body`内でローカル変換: `@Bindable var viewModel = viewModel`

**状態の所在:**
- UI固有の状態（sheet表示フラグ等）は`@State`でView自身が管理
- ビジネスに関わる状態はViewModelが管理

**子Viewの分割基準:**
- State enumのcase毎にViewを分割する（`HomeInitialView`, `HomeLoadingView`, `HomeErrorView`, `HomeWeatherContentView`）
- 親Viewのswitch分岐で各子Viewに振り分ける
- 子ViewはEnvironmentからViewModelを直接取得するため、親から状態を渡す必要はない
- UI操作のためのBindingのみ親から渡す（例: `$isShowingLocationSearch`）

**ToolbarContentの分離:**
- ToolbarContentは独立したstructとして定義する
```swift
struct HomeToolbarContent: ToolbarContent {
    @Environment(HomeViewModel.self) private var viewModel
    @Binding var isShowingCharts: Bool
    @Binding var isShowingLocationSearch: Bool

    var body: some ToolbarContent { ... }
}
```

**sheet内Viewの構成:**
- sheetに表示するViewはEnvironmentを親から自動継承する
- sheet内で独自のNavigationStackが必要な場合は、sheet用メソッド内でラップする
```swift
private func chartsSheet() -> some View {
    NavigationStack {
        WeatherChartsView().toolbar { ... }
    }
}
```

**@ViewBuilderの使用方針:**
- switch分岐やif/else分岐を含むメソッドに`@ViewBuilder`を付与する
- 単一のViewを返すメソッドには不要

**ファイル配置規則:**
- 機能のルートView・ViewModelは `Presentation/{Feature}/` に配置
- 子View・ToolbarContentは `Presentation/{Feature}/Components/` に配置
- 例: `Presentation/Home/HomeView.swift`, `Presentation/Home/Components/HomeInitialView.swift`

### ViewModel の実装パターン

**基本構造:**
```swift
@MainActor
@Observable
final class SomeViewModel {
    // ネストされたState enum
    enum State {
        case initial
        case loading
        case loaded(Entity)
        case error(String)
    }

    // 読み取り専用の公開状態
    private(set) var state: State = .initial

    // コンストラクタインジェクション（プロトコル型）
    private let fetcher: SomeFetchable

    init(fetcher: SomeFetchable) {
        self.fetcher = fetcher
    }

    // 公開asyncメソッド（Action enum不使用）
    func fetchData() async { ... }
}
```

**アクセス制御:**
- Viewから参照される状態: `private(set) var`（外部読み取り可、書き込み不可）
- 内部のみで使用する状態: `private var`
- 依存オブジェクト: `private let`

**共通state遷移の抽象化:**
```swift
private func loadWeather(_ operation: () async throws -> WeatherEntity) async {
    state = .loading
    do {
        let weather = try await operation()
        state = .loaded(weather)
    } catch {
        state = .error(error.localizedDescription)
    }
}

// 各公開メソッドから再利用
func fetchCurrentWeather() async {
    await loadWeather {
        try await self.weatherFetcher.fetchWeather(for: location)
    }
}
```
loading→loaded/errorのstate遷移を共通メソッドに抽出し、各公開メソッドはビジネスロジックに集中する。

**原則:**
- `@Observable` + `@MainActor` で状態管理とスレッド安全性を確保
- 画面状態は`State` enumで表現し、Viewのswitch分岐と1対1対応させる
- Action enum/handleパターンは使わず、asyncメソッドを直接公開する
- 共通のstate遷移パターンはクロージャで抽象化する
- Computed Propertyで都度計算し、キャッシュしない（`@Observable`の変更追跡に乗せる）
- 依存はコンストラクタインジェクションでプロトコル型を受け取る

### 命名規則

- **UseCase プロトコル**: `-able`/`-ing`サフィックス（`WeatherFetchable`, `LocationSearchable`）
- **UseCase 実装**: 動作を表す名詞（`WeatherFetcher`, `LocationSearcher`）
- **変数名**: 型名と一致させる（`let weatherFetcher: WeatherFetchable`）
- **Boolプロパティ**: `is`/`has`/`should`プレフィックス（`isMockDataEnabled`, `hasWeatherData`）
- **メソッド**: 実行する処理を表す（`fetchCurrentWeather()`, `fetchWeather(for:name:)`）

### 依存性注入パターン

**AppDependencies:**
```swift
struct AppDependencies {
    init(isMockDataEnabled: Bool) { ... }
}
```
- イニシャライザで全依存オブジェクトを生成
- `View.dependencies()`でEnvironmentに一括注入
- `DependencyModifier`は`private`、View拡張経由でのみ使用

**Preview:**
```swift
#Preview(traits: .modifier(.mock)) {
    SomeView()
}
```
- `PreviewMock`が`AppDependencies(isMockDataEnabled: true)`で依存を生成
- `PreviewModifier`のライフサイクルでオブジェクトを管理

## ブランチ構造

- **メインブランチ**: `main`
- Conventional Commits を使用し、CI がパスしてからマージすること

## 言語

コードコメントとUIテキストは日本語で記述されています。
