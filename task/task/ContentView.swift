
import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<SearchReducer>

    var body: some View {
        SearchResultsView(store: store)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: Store(
                initialState: .init(),
                reducer: {
                    SearchReducer()
                }
            )
        )
    }
}
