//
//  LocationDetailsView.swift
//  Schedoolr
//
//  Created by David Medina on 5/24/25.
//

import SwiftUI
import MapKit

struct LocationDetailView: View {
    
    @State var selectedPlacemark: MTPlacemark?
    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?
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
                    Text(selectedPlacemark?.address ?? "")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                }
                
                Spacer()
                
                Button(action: {
                    if let onCancel {
                        onCancel()
                        dismiss()
                    } else {
                        dismiss()

                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(.gray)
                }
                .padding(.top, 5)
            }
            .padding(.top)
            
            if let scene = lookaroundScene {
                LookAroundPreview(initialScene: scene)
                    .frame(maxWidth: .infinity)
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            } else {
                ContentUnavailableView("No preview available", systemImage: "eye.slash")
            }
            
            if let onConfirm {
                Button(action: {
                    onConfirm()
                    dismiss()
                }) {
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
                    .foregroundStyle(Color(hex: 0xf7f4f2))
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(
                         RoundedRectangle(cornerRadius: 15)
                            .fill(Color(hex: 0x3C859E))
                    )
                }
            } else {
                Button(action: {
                    if let selectedPlacemark {
                        let placemark = MKPlacemark(coordinate: selectedPlacemark.coordinate)
                        let mapItem = MKMapItem(placemark: placemark)
                        mapItem.name = selectedPlacemark.name
                        mapItem.openInMaps()
                    }
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
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(hex: 0xf7f4f2))
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(
                         RoundedRectangle(cornerRadius: 15)
                            .fill(Color(hex: 0x3C859E))
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
    }
    
    func fetchLookAroundPreview() async {
        if let selectedPlacemark {
            lookaroundScene = nil
            let lookaroundRequest = MKLookAroundSceneRequest(coordinate: selectedPlacemark.coordinate)
            lookaroundScene = try? await lookaroundRequest.scene
        }
    }
}

