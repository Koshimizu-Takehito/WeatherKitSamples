import CoreLocation
import Foundation
import MapKit

// MARK: - LocationSearchViewModel

/// The view model for the location search screen.
///
/// Manages location search functionality including text input handling,
/// search execution with debouncing, and predefined city suggestions.
///
/// ## Overview
///
/// This view model handles:
/// - Text-based location search with debouncing
/// - Search state management (initial, searching, loaded, error)
/// - Predefined major cities for quick selection
/// - Search task cancellation for efficient resource usage
///
/// ## Thread Safety
///
/// This class is isolated to the main actor (`@MainActor`), ensuring all
/// property access and method calls occur on the main thread.
///
/// ## Learning Points
///
/// - **Debouncing**: Uses `Task.sleep` to delay search execution,
///   preventing excessive API calls during rapid typing.
/// - **Task Cancellation**: Cancels pending searches when new input
///   arrives, avoiding stale results.
/// - **Two-way Binding**: `searchText` is writable for direct binding
///   to SwiftUI TextField.
///
/// - SeeAlso: ``LocationSearchView`` for the corresponding view.
/// - SeeAlso: ``LocationSearchable`` for the search dependency.
@MainActor
@Observable
final class LocationSearchViewModel {
    // MARK: - State

    /// Represents the current state of the search screen.
    enum State {
        /// Initial state, no search performed.
        case initial

        /// Currently executing a search.
        case searching

        /// Search completed with results.
        case loaded([LocationSearchResult])

        /// Search failed with an error.
        case error(String)
    }

    // MARK: - Properties

    /// The current search text entered by the user.
    ///
    /// - Note: This property is writable to support two-way binding
    ///   with SwiftUI TextField.
    var searchText: String = ""

    /// The current state of the search.
    private(set) var state: State = .initial

    // MARK: - Dependencies

    private let locationSearcher: LocationSearchable
    private var searchTask: Task<Void, Never>?

    // MARK: - Predefined Cities

    /// A list of major cities for quick selection.
    ///
    /// Provides common city options without requiring a search,
    /// useful for demo purposes and quick access.
    let predefinedCities: [PredefinedCity] = [
        PredefinedCity(name: "Tokyo", coordinate: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503)),
        PredefinedCity(name: "Osaka", coordinate: CLLocationCoordinate2D(latitude: 34.6937, longitude: 135.5023)),
        PredefinedCity(name: "Nagoya", coordinate: CLLocationCoordinate2D(latitude: 35.1815, longitude: 136.9066)),
        PredefinedCity(name: "Sapporo", coordinate: CLLocationCoordinate2D(latitude: 43.0618, longitude: 141.3545)),
        PredefinedCity(name: "Fukuoka", coordinate: CLLocationCoordinate2D(latitude: 33.5904, longitude: 130.4017)),
        PredefinedCity(name: "Yokohama", coordinate: CLLocationCoordinate2D(latitude: 35.4437, longitude: 139.6380)),
        PredefinedCity(name: "Kyoto", coordinate: CLLocationCoordinate2D(latitude: 35.0116, longitude: 135.7681)),
        PredefinedCity(name: "Kobe", coordinate: CLLocationCoordinate2D(latitude: 34.6901, longitude: 135.1956)),
    ]

    // MARK: - Initialization

    /// Creates a new location search view model.
    ///
    /// - Parameter locationSearcher: The use case for searching locations.
    init(locationSearcher: LocationSearchable) {
        self.locationSearcher = locationSearcher
    }

    // MARK: - Computed Properties

    /// The current search results, empty if not in loaded state.
    var searchResults: [LocationSearchResult] {
        if case let .loaded(results) = state {
            return results
        }
        return []
    }

    /// Indicates whether a search is currently in progress.
    var isSearching: Bool {
        if case .searching = state {
            return true
        }
        return false
    }

    // MARK: - Public Methods

    /// Called when the search text changes.
    ///
    /// Implements debouncing by cancelling any pending search task
    /// and scheduling a new one after a 300ms delay.
    ///
    /// ## Implementation Notes
    ///
    /// - Cancels previous search task to avoid stale results
    /// - Returns to initial state if search text is empty
    /// - Uses 300ms debounce delay before executing search
    func onSearchTextChanged() {
        searchTask?.cancel()

        guard !searchText.isEmpty else {
            state = .initial
            return
        }

        searchTask = Task {
            // Debounce delay
            try? await Task.sleep(for: .milliseconds(300))

            guard !Task.isCancelled else { return }

            await search()
        }
    }

    /// Clears the search text and results.
    func clearSearch() {
        searchText = ""
        state = .initial
        searchTask?.cancel()
    }

    // MARK: - Private Methods

    /// Executes the location search.
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

/// A predefined city for quick location selection.
///
/// Provides major city options without requiring a search,
/// including coordinates for immediate weather fetching.
struct PredefinedCity: Identifiable {
    /// Unique identifier for list rendering.
    let id = UUID()

    /// The display name of the city.
    let name: String

    /// The geographic coordinates of the city center.
    let coordinate: CLLocationCoordinate2D

    /// A `CLLocation` instance created from the coordinate.
    var location: CLLocation {
        CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
