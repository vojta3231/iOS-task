import ComposableArchitecture
import SwiftUI

// Reducer managing the search and results state
@Reducer
struct SearchReducer: Reducer {
    struct State: Equatable {
        var searchText: String = ""
        var selectedType: EntityType = .all
        var isLoading: Bool = false
        var results: [PlayerSearchData] = []
        var error: SearchError?
        var hasSearched: Bool = false
    }
    
    enum Action: Equatable {
        case searchTextChanged(String)
        case searchButtonTapped
        case searchResponse(Result<[PlayerSearchData], SearchError>)
        case selectType(EntityType)
        case dismissError
    }
    
    @Dependency(SearchService.self)
    var searchService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .searchTextChanged(text):
                state.searchText = text
                return .none
            
            case .searchButtonTapped:
                guard !state.searchText.isEmpty else {
                    state.error = .emptyQuery
                    return .none
                }
                
                state.isLoading = true
                state.error = nil
                state.results = []
                state.hasSearched = true
                
                return .run { [state] send in
                    do {
                        let entities = try await searchService.searchEntities(query: state.searchText, entityType: state.selectedType)
                        if entities.isEmpty {
                            await send(.searchResponse(.failure(.noResults)))
                        } else {
                            await send(.searchResponse(.success(entities)))
                        }
                    } catch let error as SearchError {
                        await send(.searchResponse(.failure(error)))
                    } catch {
                        await send(.searchResponse(.failure(.networkError)))
                    }
                }
                
            case let .searchResponse(.success(results)):
                state.isLoading = false
                state.results = results
                return .none
                
            case let .searchResponse(.failure(error)):
                state.isLoading = false
                state.error = error
                return .none
                
            case let .selectType(type):
                if type != state.selectedType {
                    state.selectedType = type
                    state.resetSearchState()
                    
                    // If there's text in the search field, automatically search with new type
                    if !state.searchText.isEmpty {
                        return .send(.searchButtonTapped)
                    }
                }
                return .none
                
            case .dismissError:
                state.error = nil
                return .none
            }
        }
    }
}

extension SearchReducer.State {
    mutating func resetSearchState() {
        results = []
        error = nil
        hasSearched = false
    }
}

enum SearchError: Error, Equatable, LocalizedError {
    case networkError
    case parsingError
    case unknownError
    case invalidURL
    case serverError(statusCode: Int)
    case emptyQuery
    case noResults

    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network error occurred. Please check your internet connection and try again."
        case .parsingError:
            return "Error processing the response from the server. Please try again."
        case .unknownError:
            return "An unexpected error occurred. Please try again."
        case .invalidURL:
            return "Invalid search query. Please try a different search term."
        case .serverError(let statusCode):
            return "Server error occurred (Status: \(statusCode)). Please try again later."
        case .emptyQuery:
            return "Please enter a search term."
        case .noResults:
            return "No results found. Try a different search term or category."
        }
    }
}
