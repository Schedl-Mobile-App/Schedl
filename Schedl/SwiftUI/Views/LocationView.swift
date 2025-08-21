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
    @FocusState var isFocused: Bool
    
    @Binding var showMapSheet: Bool
    
    @State private var searchTask: Task<Void, Never>?
    
    let manager = LocationManager()
    
    var body: some View {
        if manager.isAuthorized {
            ZStack(alignment: .topLeading) {
                Map(position: $cameraPosition, selection: $selectedPlacemark) {
                    UserAnnotation()
                    ForEach(listPlacemarks, id: \.self) { placemark in
                        Annotation(placemark.name, coordinate: placemark.coordinate) {
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
                .ignoresSafeArea(.keyboard)
                .onMapCameraChange { context in
                    visibleRegion = context.region
                }
                .onChange(of: selectedPlacemark) { oldValue, newValue in
                    if let newValue = newValue {
                        detailPlacemark = newValue
                    }
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
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            isFocused = false
                            selectedPlacemark = nil
                            showMapSheet = false
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            isFocused = false
                            showMapSheet = false
                        }
                        .disabled(selectedPlacemark == nil)
                    }
                }
                
                // Search bar container with smooth animation
                VStack {
                    if isFocused {
                        Spacer()
                            .frame(height: 0)
                    } else {
                        Spacer()
                    }
                    HStack {
                        VStack(spacing: 0) {
                            // Search bar
                            HStack(alignment: .center, spacing: 10) {
                                Button(action: {
                                    Task {
                                        listPlacemarks = await MapManager.searchPlaces(searchText: searchText, visibleRegion: visibleRegion)
                                        cameraPosition = .automatic
                                    }
                                }) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundStyle(.gray)
                                        .imageScale(.medium)
                                }
                                
                                TextField("Search", text: $searchText)
                                    .textFieldStyle(.plain)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                    .font(.headline)
                                    .fontWeight(.regular)
                                    .fontDesign(.monospaced)
                                    .foregroundStyle(Color(hex: 0x333333))
                                    .focused($isFocused)
                                    .onSubmit {
                                        isFocused = false
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            Task {
                                                listPlacemarks = await MapManager.searchPlaces(searchText: searchText, visibleRegion: visibleRegion)
                                                cameraPosition = .automatic
                                            }
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
                            
                            // Search results list - only show when focused and has results
                            if isFocused && !listPlacemarks.isEmpty {
                                Rectangle()
                                    .fill(Color.secondary.opacity(0.5))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 0.50)
                                                                
                                List(listPlacemarks) { place in
                                    VStack(alignment: .leading) {
                                        Text(place.name)
                                            .font(.title2)
                                        Text(place.address)
                                            .font(.callout)
                                            .foregroundStyle(.secondary)
                                    }
                                    .listRowBackground(Color.clear)
                                    .background(.clear)
                                    .onTapGesture {
                                        isFocused = false
                                        detailPlacemark = place
                                    }
                                }
                                .listStyle(.plain)
                                .listRowBackground(Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(.regularMaterial)
                        )
                    }
                }
                .padding(.vertical, 5)
                .padding(.leading, isFocused ? 5 : 15)
                .padding(.trailing, isFocused ? 55 : 15)
                .animation(.easeInOut(duration: 0.3), value: isFocused)
                .onChange(of: searchText) { oldValue, newValue in
                    searchTask?.cancel()
                    guard !newValue.isEmpty else {
                        listPlacemarks.removeAll()
                        return
                    }
                    
                    searchTask = Task {
                        do {
                            try await Task.sleep(for: .milliseconds(300))
                            if Task.isCancelled { return }
                            
                            if searchText == newValue {
                                listPlacemarks = await MapManager.searchPlaces(searchText: searchText, visibleRegion: visibleRegion)
                            }
                        } catch {
                            
                        }
                    }
                }
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
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        isFocused = false
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        } else {
            LocationDeniedView()
        }
    }
}

