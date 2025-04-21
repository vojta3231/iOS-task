import Foundation
import Dependencies

struct SearchService: DependencyKey {
    // Získání apiClient ze závislostí
    // Použití dependency injection pro získání instance APIClient
    @Dependency(\.apiClient) private var apiClient: APIClient
    
    static var liveValue: SearchService {
        SearchService()
    }
    
    // Hlavní metoda pro vyhledávání, která volá search na apiClient
    func searchEntities(query: String, entityType: EntityType) async throws -> [PlayerSearchData] {
        return try await apiClient.search(query: query, entityType: entityType)
    }
}

// Rozšíření DependencyValues pro přístup k searchService
extension DependencyValues {
    var searchService: SearchService {
        get { self[SearchService.self] }
        set { self[SearchService.self] = newValue }
    }
}
