# WeatherKitSamples

WeatherKit API を使用した天気予報アプリのサンプル実装です。

[English README](README.md)

## 機能

- 現在地または検索した都市の天気情報を表示
- 時間別・日別の天気予報
- Swift Charts を使用した 2D/3D 天気データ可視化
- モックデータによる開発・テストサポート

## 動作要件

- iOS 26.2+ / macOS 26.2+
- Xcode 26.2+
- Swift 6.0+
- WeatherKit 機能が有効な Apple Developer アカウント

## はじめに

### 1. クローン & セットアップ

```bash
git clone https://github.com/Koshimizu-Takehito/WeatherKitSamples.git
cd WeatherKitSamples
make setup
```

### 2. WeatherKit の設定

1. [Apple Developer Portal](https://developer.apple.com/) で App ID に WeatherKit capability を追加
2. Xcode でプロジェクトを開き、Signing & Capabilities を設定

### 3. ビルド & 実行

```bash
make open  # Xcode でプロジェクトを開く
```

または `WeatherKitSamples.xcodeproj` を Xcode で直接開いてください。

### モックモード

WeatherKit の設定なしで動作確認する場合は、`AppDependencies(isMockDataEnabled: true)` でモックモードに切り替えられます。

## アーキテクチャ

クリーンアーキテクチャの 3 層構造を採用しています。

```
┌─────────────────────────────────────────────────────────┐
│                 プレゼンテーション層                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │    Views    │  │  ViewModels │  │     Charts      │  │
│  │  (SwiftUI)  │  │ (@Observable)│  │ (Swift Charts)  │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                      ドメイン層                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │  Entities   │  │  Interfaces │  │    Use Cases    │  │
│  │             │  │ (Protocols) │  │                 │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                       データ層                           │
│  ┌─────────────────────┐  ┌─────────────────────────┐   │
│  │     DataSources     │  │      Repositories       │   │
│  │ (WeatherKit / Mock) │  │                         │   │
│  └─────────────────────┘  └─────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### ディレクトリ構造

```
WeatherKitSamples/
├── App/                    # アプリケーションエントリポイント & DI
├── Core/
│   ├── Extensions/         # Environment キー、UI ヘルパー
│   └── WeatherFormatters.swift  # フォーマットユーティリティ
├── Domain/
│   ├── Entities/           # ドメインモデル
│   ├── Interfaces/         # リポジトリプロトコル
│   └── UseCases/           # ビジネスロジック
├── Data/
│   ├── DataSources/        # API クライアント (WeatherKit / Mock)
│   └── Repositories/       # リポジトリ実装
└── Presentation/
    ├── Home/               # ホーム画面
    ├── Weather/            # 天気詳細画面
    ├── Location/           # 位置検索画面
    └── Charts/             # 天気チャート (2D/3D)
```

## 開発

### 利用可能なコマンド

```bash
make setup        # 依存関係をインストール
make build        # iOS シミュレータ用にビルド
make build-macos  # macOS 用にビルド
make lint         # SwiftLint を実行
make format       # SwiftFormat でコード整形
make fix          # lint-fix + format を一括実行
make ci           # CI 用の全チェック
make clean        # ビルド成果物を削除
```

### コードスタイル

[SwiftLint](https://github.com/realm/SwiftLint) と [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) を使用しています。

## 主要な設計パターン

### View の実装

```swift
// 構造体定義と View 準拠の分離
struct HomeView {
    @Environment(HomeViewModel.self) private var viewModel
}

extension HomeView: View {
    var body: some View {
        Group(content: contentView)
            .toolbar(content: toolbarContent)
    }
}
```

### ViewModel の実装

```swift
@MainActor
@Observable
final class HomeViewModel {
    enum State {
        case initial, loading, loaded(WeatherEntity), error(String)
    }
    
    private(set) var state: State = .initial
    
    func fetchWeather() async { ... }
}
```

### 依存性注入

```swift
// Environment 経由で ViewModel を注入
ContentView()
    .dependencies(AppDependencies(isMockDataEnabled: false))
```

## ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。詳細は [LICENSE](LICENSE) ファイルをご覧ください。

## 作者

[takehito](https://github.com/Koshimizu-Takehito)
