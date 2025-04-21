import SwiftUI
import ComposableArchitecture

// Search bar component
struct SearchBar: View {
    let searchText: String
    let onSearchTextChanged: (String) -> Void
    let onSearchButtonTapped: () -> Void
    
    var body: some View {
        HStack {
            TextField("Search...", text: Binding(
                get: { searchText },
                set: { onSearchTextChanged($0) }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .autocapitalization(.none)
            
            Button(action: onSearchButtonTapped) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
}

// Entity type picker component
struct EntityTypePicker: View {
    let selectedType: EntityType
    let onTypeSelected: (EntityType) -> Void
    
    var body: some View {
        Picker("Filter", selection: Binding(
            get: { selectedType },
            set: { onTypeSelected($0) }
        )) {
            ForEach(EntityType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
}

// Loading view component
struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
            Text("Searching...")
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .frame(maxHeight: .infinity)
    }
}

// Empty results view component
struct EmptyResultsView: View {
    var body: some View {
        VStack {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No results found")
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .frame(maxHeight: .infinity)
    }
}

// Results list component
struct ResultsListView: View {
    let results: [PlayerSearchData]
    
    var body: some View {
        List {
            ForEach(groupedResults(results: results).sorted(by: { $0.key < $1.key }), id: \.key) { sport, entities in
                Section(header: Text(sport).font(.headline)) {
                    ForEach(entities, id: \.id) { entity in
                        NavigationLink(destination: EntityDetailView(entity: entity)) {
                            SearchResultRow(entity: entity)
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private func groupedResults(results: [PlayerSearchData]) -> [String: [PlayerSearchData]] {
        Dictionary(grouping: results, by: { $0.sport })
    }
}

// Main view to display the search page and results
struct SearchResultsView: View {
    let store: StoreOf<SearchReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack(spacing: 16) {
                    SearchBar(
                        searchText: viewStore.searchText,
                        onSearchTextChanged: { viewStore.send(.searchTextChanged($0)) },
                        onSearchButtonTapped: { viewStore.send(.searchButtonTapped) }
                    )
                    
                    EntityTypePicker(
                        selectedType: viewStore.selectedType,
                        onTypeSelected: { viewStore.send(.selectType($0)) }
                    )
                    
                    if viewStore.isLoading {
                        LoadingView()
                    } else if viewStore.results.isEmpty {
                        EmptyResultsView()
                    } else {
                        ResultsListView(results: viewStore.results)
                    }
                }
                .navigationTitle("Sports Search")
                .alert(
                    "Error",
                    isPresented: .constant(viewStore.error != nil),
                    actions: {
                        Button("OK") {
                            viewStore.send(.dismissError)
                        }
                    },
                    message: {
                        if let error = viewStore.error {
                            Text(error.localizedDescription)
                        }
                    }
                )
            }
        }
    }
}
