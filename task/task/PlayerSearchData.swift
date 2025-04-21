//import Foundation
//
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
//    
//    init?(from league: LeagueDTO) {
//        guard let id = league.idLeague, let name = league.strLeague else { return nil }
//        self.id = id
//        self.name = name
//        self.imageURL = league.strBadge
//        self.country = league.strCountry ?? "Unknown"
//        self.sport = league.strSport ?? "Soccer"
//        self.subtitle = league.strCountry
//    }
//}
struct PlayerSearchData: Identifiable, Equatable {
    let id: String
    let name: String
    let imageURL: String?
    let country: String
    let sport: String
    let subtitle: String?

    init(id: String, name: String, imageURL: String?, country: String, sport: String, subtitle: String? = nil) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.country = country
        self.sport = sport
        self.subtitle = subtitle
    }

    init?(from team: TeamDTO) {
        guard let id = team.idTeam, let name = team.strTeam else { return nil }
        self.id = id
        self.name = name
        self.imageURL = team.strTeamBadge
        self.country = team.strCountry ?? "Unknown"
        self.sport = team.strSport ?? "Soccer"
        self.subtitle = team.strLeague
    }

    init?(from player: PlayerDTO) {
        guard let id = player.idPlayer, let name = player.strPlayer else { return nil }
        self.id = id
        self.name = name
        self.imageURL = player.strThumb
        self.country = player.strNationality ?? "Unknown"
        self.sport = player.strSport ?? "Soccer"
        self.subtitle = player.strTeam
    }
}
