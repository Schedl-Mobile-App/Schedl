//
//  SelectedLocationView.swift
//  Schedoolr
//
//  Created by David Medina on 5/26/25.
//

import SwiftUI
import MapKit

struct SelectedLocationView: View {
    
    @State private var cameraPosition: MapCameraPosition
    @State private var visibleRegion: MKCoordinateRegion
    @State private var searchText: String = ""
    @State private var selectedPlacemark: MTPlacemark?
    @State private var listPlacemarks: [MTPlacemark] = [] // Added missing property
    @State private var detailPlacemark: MTPlacemark? // Added missing property
    @State private var showLocationDetail = false // Add this for automatic sheet presentation
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
                if let placemark = selectedPlacemark {
                    Annotation(placemark.name, coordinate: placemark.coordinate) {
                        Button {
                            showLocationDetail.toggle()
                        } label: {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                                .background(Circle().fill(.white))
                        }
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
            .sheet(isPresented: $showLocationDetail) {
                if let placemark = selectedPlacemark {
                    LocationDetailView(
                        selectedPlacemark: placemark,
                    )
                    .presentationDetents([.medium])
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack(alignment: .center, spacing: 10) {
                    Button(action: {
                        Task {
                            listPlacemarks = await MapManager.searchPlaces(
                                searchText: searchText,
                                visibleRegion: visibleRegion
                            )
                            cameraPosition = .automatic
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                            .font(.system(size: 16))
                    }
                    
                    TextField("Search", text: $searchText)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .font(.system(size: 15, weight: .regular, design: .monospaced))
                        .onSubmit {
                            Task {
                                listPlacemarks = await MapManager.searchPlaces(
                                    searchText: searchText,
                                    visibleRegion: visibleRegion
                                )
                                cameraPosition = .automatic
                            }
                        }
                    
                    Spacer()
                    
                    Button(action: {
                        searchText = ""
                        listPlacemarks.removeAll()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(hex: 0x333333))
                    }
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(hex: 0x3C859E))
                }
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
            .scrollDismissesKeyboard(.interactively)
        } else {
            LocationDeniedView()
        }
    }
}
