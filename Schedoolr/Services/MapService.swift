//
//  Untitled.swift
//  Schedoolr
//
//  Created by David Medina on 5/24/25.
//

import MapKit

enum MapManager {
    
    @MainActor
    static func searchPlaces(searchText: String, visibleRegion: MKCoordinateRegion?) async -> [MTPlacemark] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        if let visibleRegion {
            request.region = visibleRegion
        }
        
        do {
            print("Searching for: '\(searchText)'")
            let searchItems = try await MKLocalSearch(request: request).start()
            print(searchItems)
            let results = searchItems.mapItems
            print(results)
            return results.map { mapItem in
                MTPlacemark(
                    name: mapItem.placemark.name ?? "Unknown",
                    address: mapItem.placemark.title ?? "",
                    latitude: mapItem.placemark.coordinate.latitude,
                    longitude: mapItem.placemark.coordinate.longitude
                )
            }
        } catch {
            print("Search error: \(error)")
            return []
        }
    }
}
