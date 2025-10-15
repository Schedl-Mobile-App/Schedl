//
//  LocationDetailsView.swift
//  Schedoolr
//
//  Created by David Medina on 5/24/25.
//

import SwiftUI
import MapKit

struct LocationDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedPlacemark: MTPlacemark?
    var detailPlacemark: MTPlacemark
    @State var lookaroundScene: MKLookAroundScene?
    
    var body: some View {
        VStack(spacing: 15) {
            VStack(alignment: .leading) {
                Text(detailPlacemark.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color("PrimaryText"))
                Text(detailPlacemark.address)
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
                    selectedPlacemark = detailPlacemark
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
                    .lineLimit(1)
                    .padding()
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                }
                .glassEffect(.regular.tint(Color("ButtonColors")).interactive(), in: .capsule)
                
            } else {
                Button(action: {
                    selectedPlacemark = detailPlacemark
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
    
    func fetchLookAroundPreview() async {
        lookaroundScene = nil
        let lookaroundRequest = MKLookAroundSceneRequest(coordinate: detailPlacemark.coordinate)
        lookaroundScene = try? await lookaroundRequest.scene
    }
}

