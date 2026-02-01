import CoreLocation
import Foundation
import MapKit

// MARK: - LocationSearchViewModel

/// 位置検索画面のViewModel
@MainActor
@Observable
final class LocationSearchViewModel {
    // MARK: - State

    enum State {
        case initial
        case searching
        case loaded([LocationSearchResult])
        case error(String)
    }

    // MARK: - Properties

    var searchText: String = ""
    private(set) var state: State = .initial

    // MARK: - Dependencies

    private let locationSearcher: LocationSearchable
    private var searchTask: Task<Void, Never>?

    // MARK: - Predefined Cities

    /// 主要都市のリスト
    let predefinedCities: [PredefinedCity] = [
        PredefinedCity(name: "東京", coordinate: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503)),
        PredefinedCity(name: "大阪", coordinate: CLLocationCoordinate2D(latitude: 34.6937, longitude: 135.5023)),
        PredefinedCity(name: "名古屋", coordinate: CLLocationCoordinate2D(latitude: 35.1815, longitude: 136.9066)),
        PredefinedCity(name: "札幌", coordinate: CLLocationCoordinate2D(latitude: 43.0618, longitude: 141.3545)),
        PredefinedCity(name: "福岡", coordinate: CLLocationCoordinate2D(latitude: 33.5904, longitude: 130.4017)),
        PredefinedCity(name: "横浜", coordinate: CLLocationCoordinate2D(latitude: 35.4437, longitude: 139.6380)),
        PredefinedCity(name: "京都", coordinate: CLLocationCoordinate2D(latitude: 35.0116, longitude: 135.7681)),
        PredefinedCity(name: "神戸", coordinate: CLLocationCoordinate2D(latitude: 34.6901, longitude: 135.1956)),
    ]

    // MARK: - Initialization

    init(locationSearcher: LocationSearchable) {
        self.locationSearcher = locationSearcher
    }

    // MARK: - Computed Properties

    var searchResults: [LocationSearchResult] {
        if case let .loaded(results) = state {
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

    // MARK: - Public Methods

    /// 検索テキストが変更された時の処理
    func onSearchTextChanged() {
        searchTask?.cancel()

        guard !searchText.isEmpty else {
            state = .initial
            return
        }

        searchTask = Task {
            // デバウンス
            try? await Task.sleep(for: .milliseconds(300))

            guard !Task.isCancelled else { return }

            await search()
        }
    }

    /// 検索結果をクリアする
    func clearSearch() {
        searchText = ""
        state = .initial
        searchTask?.cancel()
    }

    // MARK: - Private Methods

    /// 検索を実行する
    private func search() async {
        guard !searchText.isEmpty else {
            state = .initial
            return
        }

        state = .searching

        do {
            let results = try await locationSearcher.searchLocations(query: searchText)
            state = .loaded(results)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

// MARK: - PredefinedCity

/// 主要都市の定義
struct PredefinedCity: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D

    var location: CLLocation {
        CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
