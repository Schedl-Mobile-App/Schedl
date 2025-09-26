//
//  LocationDetailsView.swift
//  Schedoolr
//
//  Created by David Medina on 5/24/25.
//

import SwiftUI
import MapKit

struct LocationDetailView: View {
    
    @Environment(\.router) var coordinator: Router
    @Binding var selectedPlacemark: MTPlacemark?
    var detailPlacemark: MTPlacemark
    @State var name: String = ""
    @State var address: String = ""
    @State var lookaroundScene: MKLookAroundScene?
    @Environment(\.dismiss) var dismiss
    
    var isChanged: Bool {
        guard let selectedPlacemark else { return false }
        return name != selectedPlacemark.name || address != selectedPlacemark.address
    }
    
    var body: some View {
        VStack(spacing: 15) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(selectedPlacemark?.name ?? "")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color("PrimaryText"))
                    Text(selectedPlacemark?.address ?? "")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                }
                
                Spacer()
                
                Button(action: {
                    coordinator.dismissSheet()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(Color("IconColors"))
                }
            }
            .padding(.top)
            
            if let scene = lookaroundScene {
                LookAroundPreview(initialScene: scene)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            } else {
                ContentUnavailableView("No preview available", systemImage: "eye.slash")
            }
            
            Button(action: {
                if selectedPlacemark == nil {
                    if let selectedPlacemark {
                        let placemark = MKPlacemark(coordinate: selectedPlacemark.coordinate)
                        let mapItem = MKMapItem(placemark: placemark)
                        mapItem.name = selectedPlacemark.name
                        mapItem.openInMaps()
                    }
                } else {
                    selectedPlacemark = detailPlacemark
                    coordinator.dismissSheet()
                }
            }) {
                if selectedPlacemark == nil {
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .imageScale(.medium)
                        Text("Select Location")
                    }
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .tracking(-0.25)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color("ButtonColors"))
                    )
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "map")
                            .imageScale(.medium)
                        Text("Open in Maps")
                    }
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .tracking(-0.25)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(hex: 0xf7f4f2))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color("ButtonColors"))
                    )
                }
            }
        }
        .padding()
        .task(id: selectedPlacemark) {
            await fetchLookAroundPreview()
        }
        .onAppear {
            if let selectedPlacemark = self.selectedPlacemark {
                name = selectedPlacemark.name
                address = selectedPlacemark.address
            }
        }
        .presentationDetents([.medium])
    }
    
    func fetchLookAroundPreview() async {
        if let selectedPlacemark {
            lookaroundScene = nil
            let lookaroundRequest = MKLookAroundSceneRequest(coordinate: selectedPlacemark.coordinate)
            lookaroundScene = try? await lookaroundRequest.scene
        }
    }
}

