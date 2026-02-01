---
name: swiftui-viewmodel-refactoring
description: SwiftUI ViewModelの可読性と保守性を向上させるリファクタリング。State enum導入、アクセス制御統一、共通処理の抽出パターンを適用する場合に使用。「ViewModelをリファクタリング」「状態管理を改善」「重複コードを削減」などのリクエストで使用。
---

# SwiftUI ViewModel リファクタリング

ViewModelの可読性と保守性を向上させるリファクタリングパターン集。

## State enum パターン

複数のプロパティで暗黙的に管理されている状態を、明示的なネストenumで表現する。

### Before

```swift
var data: SomeEntity?
var isLoading: Bool = false
var errorMessage: String?
```

### After

```swift
@MainActor
@Observable
final class SomeViewModel {
    enum State {
        case initial
        case loading
        case loaded(SomeEntity)
        case error(String)
    }

    private(set) var state: State = .initial
}
```

Viewから便利にアクセスするためのcomputed propertyはViewModel側に配置する:

```swift
// ViewModel内
var searchResults: [LocationSearchResult] {
    if case .loaded(let results) = state {
        return results
    }
    return []
}

var isSearching: Bool {
    if case .searching = state {
        return true
    }
    return false
}
```

### メリット

- 状態遷移が明示的で追跡しやすい
- 不正な状態の組み合わせを防止
- View側でswitch文による網羅性チェックが可能

## アクセス制御

```swift
@MainActor
@Observable
final class SomeViewModel {
    // UI入力状態（Viewから双方向バインディング）
    var searchText: String = ""

    // ビジネス状態（読み取り専用）
    private(set) var state: State = .initial

    // 依存オブジェクト
    private let fetcher: SomeFetchable

    // 内部状態
    private var searchTask: Task<Void, Never>?
}
```

- Viewから双方向バインディングが必要な状態: `var`（`@Bindable`経由で使用）
- Viewから参照される状態: `private(set) var`
- 内部のみで使用する状態: `private var`
- 依存オブジェクト: `private let`

## 共通処理の抽出パターン

重複するloading→loaded/errorのstate遷移を単一のヘルパーメソッドに集約する。

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

func fetchWeather(for location: CLLocation, name: String) async {
    await loadWeather {
        try await self.weatherFetcher.fetchWeather(for: location)
    }
}
```

## 原則

- `@Observable` + `@MainActor` で状態管理とスレッド安全性を確保
- 画面状態は`State` enumで表現し、Viewのswitch分岐と1対1対応させる
- **Action enum/handleパターンは使わず**、asyncメソッドを直接公開する
- 共通のstate遷移パターンはクロージャで抽象化する
- Computed Propertyで都度計算し、キャッシュしない（`@Observable`の変更追跡に乗せる）
- 依存はコンストラクタインジェクションでプロトコル型を受け取る

## 適用手順

1. **状態分析**: 現在のViewModel内の状態プロパティを特定
2. **State enum定義**: 状態をネストenumのcaseとして定義
3. **アクセス制御統一**: `private(set) var` / `private var` / `private let` を適用
4. **共通処理抽出**: 重複するfetch処理をヘルパーメソッドに集約
5. **便利computed property**: Viewから使いやすいアクセサをViewModel側に追加
6. **View更新**: switch文による状態分岐に変更

実装例は [references/HomeViewModel.swift](references/HomeViewModel.swift) を参照。
