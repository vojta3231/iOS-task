import Foundation

struct PlayerSearchData: Identifiable, Equatable {
    let id: String
    let name: String
    let imageURL: String?
    let country: String
    let sport: String
    let subtitle: String?
    let showSport: Bool

    init(id: String, name: String, imageURL: String?, country: String, sport: String, subtitle: String? = nil, showSport: Bool = true) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.country = country
        self.sport = sport
        self.subtitle = subtitle
        self.showSport = showSport
    }

    init?(from team: TeamDTO) {
        guard let id = team.idTeam, let name = team.strTeam else { return nil }
        self.id = id
        self.name = name
        self.imageURL = team.strTeamBadge
        self.country = team.strCountry ?? "Unknown"
        self.sport = team.strSport ?? "Soccer"
        self.subtitle = team.strLeague
        self.showSport = true
    }

    init?(from player: PlayerDTO) {
        guard let id = player.idPlayer, let name = player.strPlayer else { return nil }
        self.id = id
        self.name = name
        self.imageURL = player.strThumb
        self.country = player.strNationality ?? "Unknown"
        self.sport = player.strSport ?? "Soccer"
        self.subtitle = player.strTeam
        self.showSport = true
    }
    
    init?(from venue: VenueDTO) {
        guard let id = venue.idVenue, let name = venue.strVenue else { return nil }
        self.id = id
        self.name = name
        self.imageURL = venue.strVenueThumb
        self.country = venue.strCountry ?? "Unknown"
        self.sport = ""
        self.subtitle = venue.strLocation
        self.showSport = false
    }
}
