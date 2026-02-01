---
name: clean-architecture-checklist
description: SwiftUIプロジェクトでクリーンアーキテクチャ違反を検出・修正するためのチェックリスト。「アーキテクチャをレビュー」「違反をチェック」「コードレビュー」などのリクエストで使用。
---

# クリーンアーキテクチャ違反チェックリスト

SwiftUIプロジェクトでリファクタリング時に確認すべき項目。

## チェックリスト

### ViewModel層

- [ ] **UI固有のロジックが含まれていないか**
  - Color, Font, Image等のSwiftUI型を返していないか
  - グラデーション計算、スタイル決定ロジックがないか
  - 解決策: 専用enum（例: `WeatherGradient`）をComponents/に分離

- [ ] **UI状態が含まれていないか**
  - sheet/alert表示フラグ（`showingSheet`, `isAlertPresented`等）
  - 解決策: View側の`@State`に移動

- [ ] **State enumが導入されているか**
  - 複数プロパティで暗黙的に状態管理していないか
  - 解決策: ネストされた`State` enumで明示的に表現

- [ ] **アクセス制御が統一されているか**
  - Viewから参照される状態: `private(set) var`
  - 内部のみ: `private var`
  - 依存オブジェクト: `private let`

- [ ] **重複コードが3箇所以上存在しないか**
  - 同じloading→loaded/errorのstate遷移パターン
  - 解決策: クロージャを受け取る共通ヘルパーメソッドに集約

### View層

- [ ] **struct+extension分離が適用されているか**
  - struct定義とView準拠が同一ブロックに書かれていないか
  - 解決策: `struct Foo { ... }` + `extension Foo: View { ... }`

- [ ] **メソッド参照パターンが適用されているか**
  - `.background { ... }`, `.toolbar { ... }` 等のトレーリングクロージャ
  - 解決策: `.background(content: methodRef)`, `.toolbar(content: methodRef)` に変更

- [ ] **ViewModelをEnvironmentから直接取得しているか**
  - 親Viewからプロパティで渡していないか
  - 解決策: `@Environment(SomeViewModel.self)` で各Viewが直接取得

- [ ] **インライン定義の子Viewが分離されているか**
  - private structとして同一ファイル内に定義されていないか
  - 解決策: Components/ディレクトリに独立ファイルとして分離

### データ変換

- [ ] **データ変換ロジックが適切な層に配置されているか**
  - Entity → ChartData等の変換がViewModelに直接書かれていないか
  - 解決策: extensionとして型定義ファイルに移動

## 違反パターンと解決策

### パターン1: ViewModelにColor計算

**違反コード:**
```swift
// SomeViewModel.swift
var gradientColors: [Color] {
    switch weather.condition {
    case .clear: return [.blue, .cyan]
    // ...
    }
}
```

**解決策:**
```swift
// Components/WeatherGradient.swift
enum WeatherGradient {
    static func colors(for condition: WeatherCondition) -> [Color] {
        // ...
    }
}

// View側
LinearGradient(colors: WeatherGradient.colors(for: viewModel.state))
```

### パターン2: ViewModelにUI状態

**違反コード:**
```swift
// SomeViewModel.swift
var showingSheet: Bool = false
var showingAlert: Bool = false
```

**解決策:**
```swift
// SomeView.swift
struct SomeView {
    @State private var isShowingSheet = false
    @State private var isShowingAlert = false
}
```

### パターン3: 古いモディファイアパターン

**違反コード:**
```swift
.background(someView.ignoresSafeArea())
.toolbar {
    ToolbarItem(placement: .cancellationAction) { ... }
}
```

**解決策:**
```swift
.background(content: backgroundGradient)
.toolbar(content: cancelToolbar)

private func backgroundGradient() -> some View {
    LinearGradient(...)
        .ignoresSafeArea()
}

@ToolbarContentBuilder
private func cancelToolbar() -> some ToolbarContent {
    ToolbarItem(placement: .cancellationAction) { ... }
}
```

## 修正フロー

1. **検出**: チェックリストに従って違反箇所を特定
2. **計画**: 影響範囲を確認し、修正計画を立てる
3. **struct+extension分離**: View定義の分離を適用
4. **メソッド参照化**: モディファイアのトレーリングクロージャを変換
5. **UIロジック分離**: Color計算等を専用enumに移動
6. **UI状態移動**: View層の`@State`に移動
7. **子View分離**: インライン定義をComponents/に分離
8. **検証**: ビルド成功を確認

## 理想的なファイル構成

```
Feature/
├── FeatureView.swift          # struct+extension分離、メソッド参照パターン
├── FeatureViewModel.swift     # State enum、private(set) var
└── Components/
    ├── FeatureInitialView.swift    # struct+extension分離
    ├── FeatureLoadingView.swift
    ├── FeatureErrorView.swift
    ├── FeatureContentView.swift
    ├── FeatureToolbarContent.swift # ToolbarContent準拠
    └── FeatureGradient.swift       # UI表現ロジック
```
