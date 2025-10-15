//
//  SettingsView.swift
//  Schedl
//
//  Created by David Medina on 6/18/25.
//

import SwiftUI

struct ChangeAccountDataView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    @State private var newEmail: String = ""
    @State private var newDisplayName: String = ""
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            if colorScheme == .dark {
                Form {
                    Section(header:
                                Text("Change Email")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color("SecondaryText"))
                    ) {
                        Group {
                            TextField("New Email", text: $newEmail)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .fontDesign(.monospaced)
                                .tracking(-0.25)
                                .foregroundStyle(Color("PrimaryText"))
                                .autocorrectionDisabled(true)
                            Button(action: {
                                // Add logic to change email
                            }) {
                                Text("Save Email")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .fontDesign(.rounded)
                                    .tracking(1.05)
                                    .foregroundStyle(Color("PrimaryText"))
                            }
                        }
                    }
                    
                    Section(header:
                                Text("Change Display Name")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color("SecondaryText"))
                    ) {
                        Group {
                            TextField("New Name", text: $newDisplayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .fontDesign(.monospaced)
                                .tracking(-0.25)
                                .foregroundStyle(Color("PrimaryText"))
                                .autocorrectionDisabled(true)
                            Button(action: {
                                // Add logic to change email
                            }) {
                                Text("Save Display Name")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .fontDesign(.rounded)
                                    .tracking(1.05)
                                    .foregroundStyle(Color("PrimaryText"))
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            } else {
                Form {
                    Section(header:
                                Text("Change Email")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color("SecondaryText"))
                    ) {
                        Group {
                            TextField("New Email", text: $newEmail)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .fontDesign(.monospaced)
                                .tracking(-0.25)
                                .foregroundStyle(Color("PrimaryText"))
                                .autocorrectionDisabled(true)
                            Button(action: {
                                // Add logic to change email
                            }) {
                                Text("Save Email")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .fontDesign(.rounded)
                                    .tracking(1.05)
                                    .foregroundStyle(Color("PrimaryText"))
                            }
                        }
                    }
                    
                    Section(header:
                                Text("Change Display Name")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color("SecondaryText"))
                    ) {
                        Group {
                            TextField("New Name", text: $newDisplayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .fontDesign(.monospaced)
                                .tracking(-0.25)
                                .foregroundStyle(Color("PrimaryText"))
                                .autocorrectionDisabled(true)
                            Button(action: {
                                // Add logic to change email
                            }) {
                                Text("Save Display Name")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .fontDesign(.rounded)
                                    .tracking(1.05)
                                    .foregroundStyle(Color("PrimaryText"))
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Account Info")
                    .foregroundStyle(Color("PrimaryText"))
                    .font(.title3)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
            }
        }
    }
}

struct SettingsView: View {
        
    @EnvironmentObject private var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var defaultEventVisibility: Bool = false
    @State private var allowInvitesFromAnyone: Bool = true
    @State private var isProfileDiscoverable: Bool = true
    @State private var showDeleteAccountAlert: Bool = false
    @State var showLogoutModal = false
    
    let currentUser: User

    var body: some View {
        ZStack {
            Form {
                Section(header:
                            Text("Events & Invitations")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.monospaced)
                    .tracking(-0.25)
                    .foregroundStyle(Color("SecondaryText"))
                ) {
                    Group {
                        Toggle(isOn: $defaultEventVisibility) {
                            VStack(alignment: .leading) {
                                Text("Default Event Visibility")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .fontDesign(.rounded)
                                    .tracking(1.05)
                                    .foregroundStyle(Color("PrimaryText"))
                                Text(defaultEventVisibility ? "Public (Anyone can see new events)" : "Private (Only invited can see)")
                                    .font(.caption)
                                    .fontDesign(.rounded)
                                    .tracking(0.5)
                                    .foregroundStyle(Color("PrimaryText"))
                            }
                        }
                        
                        Toggle("Allow Invitations from Anyone", isOn: $allowInvitesFromAnyone)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                            .tracking(1.05)
                            .foregroundStyle(Color("PrimaryText"))
                    }
                }
                
                
                Section(header:
                            Text("Privacy")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.monospaced)
                    .tracking(-0.25)
                    .foregroundStyle(Color("SecondaryText"))
                ) {
                    Toggle("Profile Discoverability", isOn: $isProfileDiscoverable)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .tracking(1.05)
                        .foregroundStyle(Color("PrimaryText"))
                }
                
                Section(header:
                            Text("Account")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.monospaced)
                    .tracking(-0.25)
                    .foregroundStyle(Color("SecondaryText"))
                ) {
                    Group {
                        NavigationLink(destination: ChangeAccountDataView()) {
                            Text("Edit Account Data")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                                .tracking(1.05)
                                .foregroundStyle(Color("PrimaryText"))
                        }
                        Button(role: .cancel) {
                            showLogoutModal.toggle()
                        } label: {
                            Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .fontDesign(.monospaced)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .alert(isPresented: $showLogoutModal) {
            Alert(title: Text("Log Out"),
                  message: Text("Would you like to sign out of your account?"),
                  primaryButton: .cancel(Text("Cancel"), action: {
                showLogoutModal = false
            }), secondaryButton: .destructive(Text("Log Out"), action: {
                Task {
                    await authVM.logout()
                }
            }))
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsViewModifier: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        if colorScheme == .dark {
            content
        } else {
            content
        }
    }
}
