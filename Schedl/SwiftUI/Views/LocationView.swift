//
//  LocationView.swift
//  Schedoolr
//
//  Created by David Medina on 5/24/25.
//

import SwiftUI
import MapKit

struct LocationView: View {
    
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var searchText: String = ""
    @State var listPlacemarks: [MTPlacemark] = []
    @Binding var selectedPlacemark: MTPlacemark?
    @State private var detailPlacemark: MTPlacemark?
    let manager = LocationManager()
    
    var body: some View {
        if manager.isAuthorized {
            Map(position: $cameraPosition, selection: $selectedPlacemark) {
                UserAnnotation()
                ForEach(listPlacemarks, id: \.self) { placemark in
                    Annotation(placemark.name, coordinate: placemark.coordinate) {
                        Button(action: {
                            detailPlacemark = placemark
                        }) {
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
                // define user location -> center
                let userCenter = CLLocationCoordinate2D(latitude: 26.162073, longitude: -98.007771)
                // define the span using delta of 0.15 -> span
                let locationSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                // define a region using our center and region
                let userRegion = MKCoordinateRegion(center: userCenter, span: locationSpan)
                visibleRegion = userRegion
            }
            .sheet(item: $detailPlacemark) { placemark in
                LocationDetailView(
                    selectedPlacemark: placemark,
                    onConfirm: {
                        selectedPlacemark = placemark
                        detailPlacemark = nil
                    },
                    onCancel: {
                        detailPlacemark = nil
                    }
                )
                .presentationDetents([.medium])
            }
            .safeAreaInset(edge: .bottom) {
                HStack(alignment: .center, spacing: 10) {
                    Button(action: {
                        Task {
                            listPlacemarks = await MapManager.searchPlaces(searchText: searchText, visibleRegion: visibleRegion)
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
//                            Task {
//                                listPlacemarks = await MapManager.searchPlaces(searchText: searchText, visibleRegion: visibleRegion)
//                                cameraPosition = .automatic
//                            }
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

