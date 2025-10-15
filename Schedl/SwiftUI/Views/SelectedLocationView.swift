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
    @Environment(\.dismiss) var dismiss
    
    @State private var cameraPosition: MapCameraPosition
    @State private var visibleRegion: MKCoordinateRegion
    
    @State private var showLocationSheet = true

    var placemark: MTPlacemark
    let manager = LocationManager()
    
    @State private var lookaroundScene: MKLookAroundScene? = nil
    
    init(desiredPlacemark: MTPlacemark) {
        
        self.placemark = desiredPlacemark
        let userCenter = CLLocationCoordinate2D(
            latitude: desiredPlacemark.latitude,
            longitude: desiredPlacemark.longitude
        )
        let userSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let userRegion = MKCoordinateRegion(center: userCenter, span: userSpan)
        
        self._visibleRegion = State(initialValue: userRegion)
        self._cameraPosition = State(initialValue: .region(userRegion))
    }
    
    var body: some View {
        if manager.isAuthorized {
            Map(position: $cameraPosition) {
                UserAnnotation()
                Annotation(placemark.name, coordinate: placemark.coordinate) {
                    Button {
                        showLocationSheet = true
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
            .sheet(isPresented: $showLocationSheet) {
                VStack(spacing: 15) {
                    VStack(alignment: .leading) {
                        Text(placemark.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(Color("PrimaryText"))
                        Text(placemark.address)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    
                    if let scene = lookaroundScene {
                        LookAroundPreview(initialScene: scene)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    } else {
                        ContentUnavailableView("No preview available", systemImage: "eye.slash")
                    }
                    
                    if #available(iOS 26.0, *) {
                        Button(action: {
                            let mapPlacemark = MKPlacemark(coordinate: placemark.coordinate)
                            let mapItem = MKMapItem(placemark: mapPlacemark)
                            mapItem.name = placemark.name
                            mapItem.openInMaps()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "map")
                                    .imageScale(.medium)
                                Text("Open in Maps")
                            }
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                            .tracking(-0.25)
                            .lineLimit(1)
                            .padding()
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                        }
                        .glassEffect(.regular.tint(Color("ButtonColors")).interactive(), in: .capsule)
                        
                    } else {
                        Button(action: {
                            let mapPlacemark = MKPlacemark(coordinate: placemark.coordinate)
                            let mapItem = MKMapItem(placemark: mapPlacemark)
                            mapItem.name = placemark.name
                            mapItem.openInMaps()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "map")
                                    .imageScale(.medium)
                                Text("Open in Maps")
                            }
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                            .tracking(-0.25)
                            .lineLimit(1)
                            .padding()
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderless)
                        .background(Color("ButtonColors"), in: .capsule)
                    }
                }
                .padding()
                .task {
                    await fetchLookAroundPreview()
                }
                .presentationDetents([.medium])
            }
        } else {
            LocationDeniedView()
        }
    }
    
    func fetchLookAroundPreview() async {
        lookaroundScene = nil
        let lookaroundRequest = MKLookAroundSceneRequest(coordinate: placemark.coordinate)
        lookaroundScene = try? await lookaroundRequest.scene
    }
}
    
