import Foundation
import Dependencies

enum EntityType: String, CaseIterable {
    case all = "All"
    case participants = "Teams & Players"
}

protocol APIClientProtocol {
    func search(query: String, entityType: EntityType) async throws -> [PlayerSearchData]
}

struct APIClient: APIClientProtocol, DependencyKey {
    static var liveValue: APIClient { APIClient() }
    
    private let baseURL = "https://www.thesportsdb.com/api/v1/json/3"
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
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
        case .all:
            var allResults: [PlayerSearchData] = []
            
            // First try teams
            if let teams = try? await searchTeams(query: query) {
                allResults.append(contentsOf: teams)
            }
            
            // Finally try players
            if let players = try? await searchPlayers(query: query) {
                allResults.append(contentsOf: players)
            }
            
            if allResults.isEmpty {
                throw SearchError.noResults
            }
            
            return allResults
            
        case .participants:
            var results: [PlayerSearchData] = []
            
            // Search for teams
            if let teams = try? await searchTeams(query: query) {
                results.append(contentsOf: teams)
            }
            
            // Search for players
            if let players = try? await searchPlayers(query: query) {
                results.append(contentsOf: players)
            }
            
            if results.isEmpty {
                throw SearchError.noResults
            }
            
            return results
        }
    }
    
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
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}

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

//struct PlayerSearchData: Identifiable, Equatable {
//    let id: String
//    let name: String
//    let imageURL: String?
//    let country: String
//    let sport: String
//    let subtitle: String?
//
//    init(id: String, name: String, imageURL: String?, country: String, sport: String, subtitle: String? = nil) {
//        self.id = id
//        self.name = name
//        self.imageURL = imageURL
//        self.country = country
//        self.sport = sport
//        self.subtitle = subtitle
//    }
//
//    init?(from team: TeamDTO) {
//        guard let id = team.idTeam, let name = team.strTeam else { return nil }
//        self.id = id
//        self.name = name
//        self.imageURL = team.strTeamBadge
//        self.country = team.strCountry ?? "Unknown"
//        self.sport = team.strSport ?? "Soccer"
//        self.subtitle = team.strLeague
//    }
//
//    init?(from player: PlayerDTO) {
//        guard let id = player.idPlayer, let name = player.strPlayer else { return nil }
//        self.id = id
//        self.name = name
//        self.imageURL = player.strThumb
//        self.country = player.strNationality ?? "Unknown"
//        self.sport = player.strSport ?? "Soccer"
//        self.subtitle = player.strTeam
//    }
//}
