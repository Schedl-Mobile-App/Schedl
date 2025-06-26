//
//  EventSearchView.swift
//  Schedl
//
//  Created by David Medina on 6/26/25.
//

import SwiftUI

struct EventSearchView: View {
    
    @State var searchText = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                HStack(alignment: .center, spacing: 10) {
                    Button {}
                    label : {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                            .imageScale(.medium)
                    }
                    
                    TextField("Search", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color(hex: 0x333333))
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                    
                    Spacer()
                    
                    Button("Clear", action: {
                        searchText = ""
                    })
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .tracking(-0.25)
                    .foregroundStyle(Color(hex: 0x3C859E))
                    .opacity(!searchText.isEmpty ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: searchText)
                }
                .padding()
                .background(Color.gray.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .frame(maxWidth: .infinity, alignment: .top)
                
                HStack {
                    Button(action: {
                        
                    }) {
                        Text("Title")
                            .frame(maxWidth: .infinity)
                    }
                    
                    Divider()
                        .foregroundStyle(Color(hex: 0xc0b8b2))
                        .frame(maxWidth: 1.75, maxHeight: 35)
                        .background(Color(hex: 0xc0b8b2))
                    
                    Button(action: {
                        
                    }) {
                        Text("Location")
                            .frame(maxWidth: .infinity)
                    }
                    
                    Divider()
                        .foregroundStyle(Color(hex: 0xc0b8b2))
                        .frame(maxWidth: 1.75, maxHeight: 35)
                        .background(Color(hex: 0xc0b8b2))
                    
                    Button(action: {
                        
                    }) {
                        Text("Invited")
                            .frame(maxWidth: .infinity)
                    }
                    
                    Divider()
                        .foregroundStyle(Color(hex: 0xc0b8b2))
                        .frame(maxWidth: 1.75, maxHeight: 35)
                        .background(Color(hex: 0xc0b8b2))
                    
                    Button(action: {
                        
                    }) {
                        Text("All")
                            .frame(maxWidth: .infinity)
                    }
                }
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.12))
                        .stroke(Color.black, lineWidth: 1)
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal)
            .navigationTitle("Search for Events")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}

enum EventSearchOptions {
    case title, location, invited, all
}
