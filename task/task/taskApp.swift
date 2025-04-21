import SwiftUI
import ComposableArchitecture

@main
struct taskApp: App {
    var body: some Scene {
        WindowGroup {
            SearchResultsView(
                store: Store(
                    initialState: SearchReducer.State(),
                    reducer: { SearchReducer() }
                )
            )
        }
    }
}


