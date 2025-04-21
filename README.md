# iOS-task

This SwiftUI app lets you search for sports information using the public TheSportsDB API.

## Features

- **Find football clubs:** e.g. search "Arsenal" to see teams named Arsenal with their logos and country.
- **Look up famous players:** e.g. search "Messi" to view Lionel Messi’s profile and nationality.
- **Search for stadiums and venues:** e.g. search "Maracanã" to show the well-known Maracanã Stadium with location details.

Type your query, choose a filter (Teams & Players, Venues, or All), and results will be grouped by sport. Tapping a result displays detailed information with an image, country and so on.

## API

The app uses the public endpoints of TheSportsDB API. The original version was built on a private API and included some features/endpoints that are not available for free in TheSportsDB. For this version, I adapted the functionality to the public API—adjusting categories and details (such as Venues) as per endpoint availability. Please note that many images for venues, clubs, and players are paywalled on TheSportsDB, so image availability may be limited. All features shown in this app use only freely accessible data from TheSportsDB.

## Architecture

- SwiftUI
- Composable Architecture (TCA)
- Dependency Injection
- DTOs
