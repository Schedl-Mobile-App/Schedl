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
            let searchItems = try await MKLocalSearch(request: request).start()
            let results = searchItems.mapItems
            
            return results.map { mapItem in
                MTPlacemark(
                    name: mapItem.placemark.name ?? "Unknown",
                    address: mapItem.placemark.title ?? "",
                    latitude: mapItem.placemark.coordinate.latitude,
                    longitude: mapItem.placemark.coordinate.longitude
                )
            }
        } catch {
            return []
        }
    }
}
