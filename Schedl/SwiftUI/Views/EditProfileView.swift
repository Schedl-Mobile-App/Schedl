//
//  EditProfileView.swift
//  Schedl
//
//  Created by David Medina on 9/29/25.
//

import SwiftUI

struct EditProfileView: View {
    
    @Environment(\.router) var coordinator: Router
    @State private var showSaveChangesAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if #available(iOS 26.0, *) {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            coordinator.dismissSheet()
                        }, label: {
                            Image(systemName: "xmark")
                                .imageScale(.large)
                                .foregroundStyle(.primary)
                        })
                        .buttonStyle(.plain)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            showSaveChangesAlert = true
                        }, label: {
                            Image(systemName: "checkmark")
                                .imageScale(.large)
                                .foregroundStyle(.orange)
                        })
                        .buttonStyle(.plain)
                    }
                } else {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            coordinator.dismissSheet()
                        }, label: {
                            Text("Cancel")
                                .foregroundStyle(.blue)
                        })
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            showSaveChangesAlert = true
                        }, label: {
                            Text("Save")
                                .foregroundStyle(.green)
                        })
                    }
                }
            }
            .alert(isPresented: $showSaveChangesAlert) {
                Alert(title: Text("Save Changes"),
                      message: Text("Are you sure that you want to save the changes you've made?"),
                      primaryButton: .destructive(Text("Cancel"), action: {
                    showSaveChangesAlert = false
                }), secondaryButton: .default(Text("Save"), action: {
                    showSaveChangesAlert = false
                    coordinator.dismissSheet()
                }))
            }
        }
        .presentationDetents([.large])
    }
}
