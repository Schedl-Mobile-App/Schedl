//
//  SelectedLocationView.swift
//  Schedoolr
//
//  Created by David Medina on 5/26/25.
//

import SwiftUI
import MapKit

struct SelectedLocationView: View {
    
    @Environment(\.router) var coordinator: Router
    
    @State private var cameraPosition: MapCameraPosition
    @State private var visibleRegion: MKCoordinateRegion
    @State private var selectedPlacemark: MTPlacemark
    @State private var showLocationDetail: Bool // Add this for automatic sheet presentation
    let manager = LocationManager()
    
    init(desiredPlacemark: MTPlacemark) {
        let userCenter = CLLocationCoordinate2D(
            latitude: desiredPlacemark.latitude,
            longitude: desiredPlacemark.longitude
        )
        let userSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let userRegion = MKCoordinateRegion(center: userCenter, span: userSpan)
        
        // Initialize @State properties correctly
        self._selectedPlacemark = State(initialValue: desiredPlacemark)
        self._visibleRegion = State(initialValue: userRegion)
        self._cameraPosition = State(initialValue: .region(userRegion))
        self._showLocationDetail = State(initialValue: true) // Auto-show the sheet
    }
    
    var body: some View {
        if manager.isAuthorized {
            Map(position: $cameraPosition) {
                UserAnnotation()
                Annotation(selectedPlacemark.name, coordinate: selectedPlacemark.coordinate) {
                    Button {
                        coordinator.present(sheet: .locationDetail(detailPlacemark: selectedPlacemark, selectedPlacemark: .constant(nil)))
                    } label: {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                            .background(Circle().fill(.white))
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
            }
            .onMapCameraChange { context in
                visibleRegion = context.region
            }
            .onAppear {
                // This will automatically trigger the sheet since selectedPlacemark is set
                // and showLocationDetail is true
            }
        } else {
            LocationDeniedView()
        }
    }
}
