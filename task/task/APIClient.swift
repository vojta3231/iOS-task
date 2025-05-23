import Foundation
import Dependencies

enum EntityType: String, CaseIterable {
    case all = "All"
    case participants = "Teams & Players"
    case venues = "Venues"
}

// Useful for mocking
protocol APIClientProtocol {
    func search(query: String, entityType: EntityType) async throws -> [PlayerSearchData]
}

// API client for interacting with TheSportsDB API
struct APIClient: APIClientProtocol, DependencyKey {
    static var liveValue: APIClient { APIClient() }
    
    private let baseURL = "https://www.thesportsdb.com/api/v1/json/3"
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // Fetch utility for all API calls
    private func fetch<T: Decodable>(url: URL) async throws -> T {
        print("Fetching URL: \(url.absoluteString)")
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: Response is not HTTPURLResponse")
                throw SearchError.networkError
            }
            
            print("Response status code: \(httpResponse.statusCode)")
            print("Response headers: \(httpResponse.allHeaderFields)")
            
            guard httpResponse.statusCode == 200 else {
                print("Error: Server returned status code \(httpResponse.statusCode)")
                throw SearchError.serverError(statusCode: httpResponse.statusCode)
            }
            
            // Print response data for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response data: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                print("Decoding error: \(error)")
                print("Failed to decode type: \(T.self)")
                throw error
            }
        } catch {
            print("Network error: \(error)")
            throw error
        }
    }

    func search(query: String, entityType: EntityType) async throws -> [PlayerSearchData] {
        guard !query.isEmpty else {
            throw SearchError.emptyQuery
        }
        
        print("Searching for '\(query)' in category: \(entityType.rawValue)")
        
        switch entityType {
        case .all, .participants:
            var results: [PlayerSearchData] = []
            
            // Search for teams and players
            async let teamsSearch = searchTeams(query: query)
            async let playersSearch = searchPlayers(query: query)
            
            // Wait for both searches to complete
            if let teams = try? await teamsSearch {
                results.append(contentsOf: teams)
            }
            if let players = try? await playersSearch {
                results.append(contentsOf: players)
            }
            
            // For .all, also search venues
            if case .all = entityType {
                if let venues = try? await searchVenues(query: query) {
                    results.append(contentsOf: venues)
                }
            }
            
            if results.isEmpty {
                throw SearchError.noResults
            }
            
            return results
            
        case .venues:
            let venues = try await searchVenues(query: query)
            if venues.isEmpty {
                throw SearchError.noResults
            }
            return venues
        }
    }
    
    // Individual search functions for API
    private func searchPlayers(query: String) async throws -> [PlayerSearchData] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        guard let url = URL(string: "\(baseURL)/searchplayers.php?p=\(encodedQuery)") else {
            throw SearchError.invalidURL
        }
        
        let response: PlayersResponse = try await fetch(url: url)
        let results = response.player?.compactMap { PlayerSearchData(from: $0) } ?? []
        print("Found \(results.count) players")
        return results
    }
    
    private func searchTeams(query: String) async throws -> [PlayerSearchData] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        guard let url = URL(string: "\(baseURL)/searchteams.php?t=\(encodedQuery)") else {
            throw SearchError.invalidURL
        }
        
        let response: TeamsResponse = try await fetch(url: url)
        let results = response.teams?.compactMap { PlayerSearchData(from: $0) } ?? []
        print("Found \(results.count) teams")
        return results
    }
    
    private func searchVenues(query: String) async throws -> [PlayerSearchData] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        guard let url = URL(string: "\(baseURL)/searchvenues.php?t=\(encodedQuery)") else {
            throw SearchError.invalidURL
        }
        
        let response: VenuesResponse = try await fetch(url: url)
        let results = response.venues?.compactMap { PlayerSearchData(from: $0) } ?? []
        print("Found \(results.count) venues")
        return results
    }
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}

// Data transfer objects for responses
struct TeamsResponse: Decodable {
    let teams: [TeamDTO]?
}

struct TeamDTO: Decodable {
    let idTeam: String?
    let strTeam: String?
    let strTeamBadge: String?
    let strCountry: String?
    let strSport: String?
    let strLeague: String?
}

struct PlayersResponse: Decodable {
    let player: [PlayerDTO]?
}

struct PlayerDTO: Decodable {
    let idPlayer: String?
    let strPlayer: String?
    let strThumb: String?
    let strNationality: String?
    let strSport: String?
    let strTeam: String?
}

struct VenuesResponse: Decodable {
    let venues: [VenueDTO]?
}

struct VenueDTO: Decodable {
    let idVenue: String?
    let strVenue: String?
    let strVenueThumb: String?
    let strCountry: String?
    let strLocation: String?
}
