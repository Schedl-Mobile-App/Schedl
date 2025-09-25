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
    @State var listPlacemarks: [MTPlacemark] = []
    @Binding var selectedPlacemark: MTPlacemark?
    @State private var detailPlacemark: MTPlacemark?
    @State var sheetDetents: PresentationDetent = .height(80)
    @State var showSearchBar: Bool = true
    @State var searchText: String = ""
    @Binding var showMapSheet: Bool
    
    let manager = LocationManager()
    
    var body: some View {
        if manager.isAuthorized {
                Map(position: $cameraPosition, selection: $detailPlacemark) {
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
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    Rectangle()
                      .foregroundStyle(.clear)
                      .frame(height: 80)
                }
                .mapControls {
                    MapUserLocationButton()
                }
                .navigationBarBackButtonHidden(true)
                .onMapCameraChange { context in
                    visibleRegion = context.region
                }
                .onChange(of: detailPlacemark) { oldValue, newValue in
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
//                            isFocused = false
                            selectedPlacemark = nil
                            showMapSheet = false
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
//                            isFocused = false
                            showMapSheet = false
                        }
                        .disabled(selectedPlacemark == nil)
                    }
                }
                .sheet(isPresented: Binding<Bool>(
                    get: { detailPlacemark != nil },
                    set: { newValue in if !newValue { detailPlacemark = nil } }
                )) {
                    if let placemark = detailPlacemark {
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
                }
                .sheet(isPresented: $showSearchBar) {
                    MapSearchView(sheetDetents: $sheetDetents, searchText: $searchText, listPlacemarks: $listPlacemarks, visibleRegion: $visibleRegion, detailPlacemark: $detailPlacemark)
                        .presentationDetents([.height(80), .height(350), .large], selection: $sheetDetents)
                        .interactiveDismissDisabled(true)
                        .presentationBackgroundInteraction(.enabled)
                }
        } else {
            LocationDeniedView()
        }
    }
}

struct MapSearchView: View {
    
    @Binding var sheetDetents: PresentationDetent
    @FocusState var isFocused: Bool
    @Binding var searchText: String
    @State private var searchTask: Task<Void, Never>?
    @Binding var listPlacemarks: [MTPlacemark]
    @Binding var visibleRegion: MKCoordinateRegion?
    @Binding var detailPlacemark: MTPlacemark?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                if listPlacemarks.isEmpty {
                    
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(listPlacemarks, id: \.self) { placemark in
                            let isLast = listPlacemarks.last == placemark
                            Button(action: {
                                isFocused = false
                                detailPlacemark = placemark
                            }) {
                                HStack(alignment: .center, spacing: 18) {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title)
                                        .background(Circle().fill(.white))
                                    
                                    VStack(alignment: .leading) {
                                        Text(placemark.name)
                                            .font(.headline)
                                            .foregroundStyle(Color("PrimaryText"))
                                            .multilineTextAlignment(.leading)
                                        Text(placemark.address)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(2)
                                            .truncationMode(.tail)
                                        if !isLast {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.secondary)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 1.25)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.clear)
                            }
                        }
                    }
                    .padding(12)
                    .background(.ultraThickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal)
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if #available(iOS 26.0, *) {
                CapsuleSearchView(searchText: $searchText, listPlacemarks: $listPlacemarks, isFocused: $isFocused)
            } else {
                RoundedRectangleSearchView(searchText: $searchText, listPlacemarks: $listPlacemarks, isFocused: $isFocused)
            }
        }
        .animation(.interpolatingSpring(duration: 0.3), value: isFocused)
        .onChange(of: isFocused) { _, newValue in
            sheetDetents = newValue ? .large : .height(350)
        }
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
}

#Preview {
    LocationView(selectedPlacemark: .constant(nil), showMapSheet: .constant(true))
}

@available(iOS 26.0, *)
struct CapsuleSearchView: View {
    
    @Binding var searchText: String
    @Binding var listPlacemarks: [MTPlacemark]
    var isFocused: FocusState<Bool>.Binding
    
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            HStack(alignment: .center) {
                Button(action: {
                    isFocused.wrappedValue = false
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.gray)
                        .imageScale(.medium)
                }
                
                TextField("Search Maps", text: $searchText)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .font(.headline)
                    .foregroundStyle(Color("PrimaryText"))
                    .focused(isFocused)
                    .onSubmit {
                        isFocused.wrappedValue = false
                    }
                
                Spacer()
                
                Button(action: {
                    searchText = ""
                    listPlacemarks.removeAll()
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 16))
                }
                .symbolVariant(.circle.fill)
                .foregroundStyle(Color("BackgroundColor"), .gray)
                .opacity(searchText.isEmpty ? 0 : 1)
                .animation(.interpolatingSpring(duration: 0.3), value: searchText.isEmpty)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background{
                Capsule()
                    .fill(Color("SearchBarBackground"))
                    .glassEffect(.regular, in: .capsule)
            }
            
            if isFocused.wrappedValue {
                Button(action: {
                    isFocused.wrappedValue = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 24))
                        .padding(12)
                        .foregroundStyle(Color("SecondaryText"))
                        .background {
                            Circle()
                                .fill(Color("SearchBarBackground"))
                                .glassEffect(.clear, in: .circle)
                        }
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(height: 80)
        .padding(.horizontal)
        .padding(.top, 5)
    }
}

struct RoundedRectangleSearchView: View {
    
    @Binding var searchText: String
    @Binding var listPlacemarks: [MTPlacemark]
    var isFocused: FocusState<Bool>.Binding
    
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            HStack(alignment: .center) {
                Button(action: {
                    isFocused.wrappedValue = false
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.gray)
                        .imageScale(.medium)
                }
                
                TextField("Search Maps", text: $searchText)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .font(.headline)
                    .foregroundStyle(Color("PrimaryText"))
                    .focused(isFocused)
                    .onSubmit {
                        isFocused.wrappedValue = false
                    }
                
                Spacer()
                
                Button(action: {
                    searchText = ""
                    listPlacemarks.removeAll()
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 16))
                }
                .symbolVariant(.circle.fill)
                .foregroundStyle(Color("BackgroundColor"), .gray)
                .opacity(searchText.isEmpty ? 0 : 1)
                .animation(.interpolatingSpring(duration: 0.3), value: searchText.isEmpty)
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .background{
                RoundedRectangle(cornerRadius: 10, style: .circular)
                    .fill(Color("SearchBarBackground"))
            }
            
            if isFocused.wrappedValue {
                Button(action: {
                    withAnimation {
                        isFocused.wrappedValue = false
                        searchText = ""
                    }
                }) {
                    Text("Cancel")
                        .font(.callout)
                        .foregroundStyle(.primary)
                }
                .transition(.scale.combined(with: .opacity))
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .frame(height: 80)
        .padding(.horizontal)
    }
}

