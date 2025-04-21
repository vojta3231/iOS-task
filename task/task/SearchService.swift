import Foundation
import Dependencies

struct SearchService: DependencyKey {
    // Getting apiClient using dependecny injection
    @Dependency(\.apiClient) private var apiClient: APIClient
    
    static var liveValue: SearchService {
        SearchService()
    }
    
    // Main search function, delegates logic to the APIClient
    func searchEntities(query: String, entityType: EntityType) async throws -> [PlayerSearchData] {
        return try await apiClient.search(query: query, entityType: entityType)
    }
}

extension DependencyValues {
    var searchService: SearchService {
        get { self[SearchService.self] }
        set { self[SearchService.self] = newValue }
    }
}
