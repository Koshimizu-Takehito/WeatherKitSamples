import CoreLocation
import MapKit
import SwiftUI

// MARK: - LocationSearchView

/// A search interface for finding locations by city name.
///
/// Presents a text field for free-form search, a results list powered by
/// ``LocationSearchViewModel``, and a predefined list of major cities.
/// Selecting a location triggers weather fetching via ``HomeViewModel``.
///
/// - SeeAlso: ``LocationSearchViewModel`` for the search logic.
struct LocationSearchView {
    @Environment(\.dismiss) private var dismiss
    @Environment(HomeViewModel.self) private var homeViewModel
    @Environment(LocationSearchViewModel.self) private var viewModel
}

// MARK: View

extension LocationSearchView: View {
    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            List {
                searchSection(searchText: $viewModel.searchText)
                searchResultsSection()
                predefinedCitiesSection()
            }
            .overlay(content: searchingOverlay)
            .navigationTitle(Text(.searchLocation))
            .navigationBarTitleDisplayMode(.inlineOnPhone)
            .toolbar(content: cancelToolbar)
        }
    }

    // MARK: - Sections

    private func searchSection(searchText: Binding<String>) -> some View {
        Section {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField(.enterCityName, text: searchText)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .onChange(of: viewModel.searchText) {
                        viewModel.onSearchTextChanged()
                    }

                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.clearSearch()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private func searchResultsSection() -> some View {
        if !viewModel.searchResults.isEmpty {
            Section(.searchResults) {
                ForEach(viewModel.searchResults) { result in
                    Button {
                        selectLocation(result.location, name: result.title)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.title)
                                .foregroundStyle(.primary)
                            if !result.subtitle.isEmpty {
                                Text(result.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func predefinedCitiesSection() -> some View {
        if viewModel.searchText.isEmpty {
            Section(.majorCities) {
                ForEach(viewModel.predefinedCities) { city in
                    Button {
                        selectLocation(city.location, name: city.name)
                    } label: {
                        HStack {
                            Text(city.name)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Overlay

    @ViewBuilder
    private func searchingOverlay() -> some View {
        if viewModel.isSearching {
            ProgressView()
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private func cancelToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .cancel) {
                dismiss()
            }
        }
    }

    // MARK: - Actions

    private func selectLocation(_ location: CLLocation, name: String) {
        Task { await homeViewModel.fetchWeather(for: location, name: name) }
        dismiss()
    }
}

#Preview(traits: .modifier(.mock)) {
    LocationSearchView()
}
