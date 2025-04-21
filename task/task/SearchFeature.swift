import ComposableArchitecture
import SwiftUI

@Reducer
struct SearchReducer: Reducer {
    struct State: Equatable {
        var searchText: String = ""
        var selectedType: EntityType = .all
        var isLoading: Bool = false
        var results: [PlayerSearchData] = []
        var errorMessage: String?
        var hasSearched: Bool = false
    }
    
    enum Action: Equatable {
        case searchTextChanged(String)
        case searchButtonTapped
        case searchResponse(Result<[PlayerSearchData], SearchError>)
        case selectType(EntityType)
        case dismissAlert
        case clearResults
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
                    state.errorMessage = "Please enter a search term"
                    return .none
                }
                
                state.isLoading = true
                state.errorMessage = nil
                state.results = []
                state.hasSearched = true
                
                return .run { [state] send in
                    do {
                        let entities = try await searchService.searchEntities(query: state.searchText, entityType: state.selectedType)
                        await send(.searchResponse(.success(entities)))
                    } catch let error as SearchError {
                        await send(.searchResponse(.failure(error)))
                    } catch {
                        await send(.searchResponse(.failure(.networkError)))
                    }
                }
                
            case let .searchResponse(.success(results)):
                state.isLoading = false
                state.results = results
                if results.isEmpty {
                    state.errorMessage = "No results found for '\(state.searchText)'"
                }
                return .none
                
            case let .searchResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case let .selectType(type):
                if type != state.selectedType {
                    state.selectedType = type
                    state.results = []
                    state.errorMessage = nil
                    state.hasSearched = false
                    
                    // If there's text in the search field, automatically search with new type
                    if !state.searchText.isEmpty {
                        return .send(.searchButtonTapped)
                    }
                }
                return .none
                
            case .dismissAlert:
                state.errorMessage = nil
                return .none
                
            case .clearResults:
                state.results = []
                state.errorMessage = nil
                state.hasSearched = false
                return .none
            }
        }
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
