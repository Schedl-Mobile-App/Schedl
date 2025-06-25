//
//  SettingsView.swift
//  Schedl
//
//  Created by David Medina on 6/18/25.
//

import SwiftUI

struct ChangeAccountDataView: View {
    
    @ObservedObject var profileViewModel: ProfileViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State var showTabBar = false
    @Environment(\.dismiss) private var dismiss
    @State private var newEmail: String = ""
    @State private var newDisplayName: String = ""
    
    var body: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            
            VStack {
                ZStack(alignment: .leading) {
                    Button(action: {
                        showTabBar.toggle()
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.bold)
                            .imageScale(.large)
                            .labelStyle(.iconOnly)
                            .foregroundStyle(Color.primary)
                    }
                    Text("Account Data")
                        .foregroundStyle(Color(hex: 0x333333))
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
                
                Form {
                    Section(header:
                                Text("Change Email")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color(hex: 0x666666))
                    ) {
                        TextField("New Email", text: $newEmail)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .fontDesign(.monospaced)
                            .tracking(-0.25)
                            .foregroundStyle(Color(hex: 0x333333))
                            .autocorrectionDisabled(true)
                        Button(action: {
                            // Add logic to change email
                        }) {
                            Text("Save Email")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                                .tracking(1.05)
                                .foregroundStyle(Color(hex: 0x333333))
                        }
                    }
                    
                    Section(header:
                                Text("Change Display Name")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color(hex: 0x666666))
                    ) {
                        TextField("New Name", text: $newDisplayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .fontDesign(.monospaced)
                            .tracking(-0.25)
                            .foregroundStyle(Color(hex: 0x333333))
                            .autocorrectionDisabled(true)
                        Button(action: {
                            // Add logic to change email
                        }) {
                            Text("Save Display Name")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                                .tracking(1.05)
                                .foregroundStyle(Color(hex: 0x333333))
                        }
                    }
                }
                .background(Color(hex: 0xf7f4f2))
                .scrollContentBackground(.hidden)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .onAppear {
            profileViewModel.shouldReloadData = false
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

struct SettingsView: View {
    
    @ObservedObject var profileViewModel: ProfileViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showTabBar = false
    
    @State private var defaultEventVisibility: Bool = false
    @State private var allowInvitesFromAnyone: Bool = true
    @State private var isProfileDiscoverable: Bool = true
    @State private var showDeleteAccountAlert: Bool = false

    var body: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            
            VStack {
                ZStack(alignment: .leading) {
                    Button(action: {
                        showTabBar.toggle()
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.bold)
                            .imageScale(.large)
                            .labelStyle(.iconOnly)
                            .foregroundStyle(Color.primary)
                    }
                    Text("Settings")
                        .foregroundStyle(Color(hex: 0x333333))
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
                
                Form {
                    Section(header:
                                Text("Events & Invitations")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color(hex: 0x666666))
                    ) {
                        Toggle(isOn: $defaultEventVisibility) {
                            VStack(alignment: .leading) {
                                Text("Default Event Visibility")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .fontDesign(.rounded)
                                    .tracking(1.05)
                                    .foregroundStyle(Color(hex: 0x333333))
                                Text(defaultEventVisibility ? "Public (Anyone can see new events)" : "Private (Only invited can see)")
                                    .font(.caption)
                                    .fontDesign(.rounded)
                                    .tracking(0.5)
                                    .foregroundStyle(Color(hex: 0x333333))
                            }
                        }
                        Toggle("Allow Invitations from Anyone", isOn: $allowInvitesFromAnyone)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                            .tracking(1.05)
                            .foregroundStyle(Color(hex: 0x333333))
                    }
                    
                    Section(header:
                                Text("Privacy")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color(hex: 0x666666))
                    ) {
                        Toggle("Profile Discoverability", isOn: $isProfileDiscoverable)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                            .tracking(1.05)
                            .foregroundStyle(Color(hex: 0x333333))
                    }
                    
                    Section(header:
                                Text("Account")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color(hex: 0x666666))
                    ) {
                        NavigationLink(destination: ChangeAccountDataView(profileViewModel: profileViewModel).environmentObject(authViewModel)) {
                            Text("Edit Account Data")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                                .tracking(1.05)
                                .foregroundStyle(Color(hex: 0x333333))
                        }
                        Button(role: .destructive) {
                            profileViewModel.showLogoutModal.toggle()
                        } label: {
                            Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .fontDesign(.monospaced)
                        }
                    }
                }
                .background(Color(hex: 0xf7f4f2))
                .scrollContentBackground(.hidden)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            ZStack {
                Color(.black.opacity(0.7))
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {}
                
                LogOutModal(profileViewModel: profileViewModel)
                    .environmentObject(authViewModel)
            }
            .zIndex(1)
            .hidden(!profileViewModel.showLogoutModal)
            .allowsHitTesting(profileViewModel.showLogoutModal)
        }
        .onAppear {
            profileViewModel.shouldReloadData = false
        }
        .onDisappear {
            profileViewModel.shouldReloadData = true
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}
