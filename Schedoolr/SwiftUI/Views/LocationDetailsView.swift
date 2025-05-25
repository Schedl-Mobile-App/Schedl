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
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    TextField("Name", text: $name)
                        .font(.title)
                        .fontDesign(.rounded)
                    TextField("Address", text: $address, axis: .vertical)
                }
            }
            
            if let scene = lookaroundScene {
                LookAroundPreview(initialScene: scene)
                    .frame(maxWidth: .infinity)
                    .frame(height: 275)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            } else {
                ContentUnavailableView("No preview available", systemImage: "eye.slash")
            }
            
            HStack(alignment: .center, spacing: 20) {
                Button(action: {
                    onCancel?()
                    dismiss()
                }) {
                    Text("Cancel")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(Color.black.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                Button(action: {
                    onConfirm?()
                    dismiss()
                }) {
                    Text("Select")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(hex: 0xf7f4f2))
                }
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(Color(hex: 0x47a2be))
                .clipShape(RoundedRectangle(cornerRadius: 15))
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
