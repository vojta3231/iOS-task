import SwiftUI
import ComposableArchitecture

// Hlavní pohled pro zobrazení výsledků vyhledávání
struct SearchResultsView: View {
    let store: StoreOf<SearchReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack(spacing: 16) {
                    // Search field with search button
                    HStack {
                        TextField("Search...", text: viewStore.binding(
                            get: \.searchText,
                            send: SearchReducer.Action.searchTextChanged
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        
                        Button(action: {
                            viewStore.send(.searchButtonTapped)
                        }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Entity type picker
                    Picker("Filter", selection: viewStore.binding(
                        get: \.selectedType,
                        send: SearchReducer.Action.selectType
                    )) {
                        ForEach(EntityType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Results or loading state
                    if viewStore.isLoading {
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Searching...")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        }
                        .frame(maxHeight: .infinity)
                    } else if viewStore.results.isEmpty {
                        VStack {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            Text("No results found")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(groupedResults(results: viewStore.results).sorted(by: { $0.key < $1.key }), id: \.key) { sport, entities in
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
                }
                .navigationTitle("Sports Search")
                .alert(
                    "Error",
                    isPresented: .constant(viewStore.errorMessage != nil),
                    actions: {
                        Button("OK") {
                            viewStore.send(.dismissAlert)
                        }
                    },
                    message: {
                        Text(viewStore.errorMessage ?? "")
                    }
                )
            }
        }
    }
    
    private func groupedResults(results: [PlayerSearchData]) -> [String: [PlayerSearchData]] {
        Dictionary(grouping: results, by: { $0.sport })
    }
}
