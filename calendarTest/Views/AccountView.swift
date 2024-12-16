//
//  MyAccountView.swift
//  calendarTest
//
//  Created by David Medina on 9/19/24.
//

import SwiftUI

struct AccountView: View {
    @State private var errorMsg: String? = nil
    @State private var isLoading = true
    @State private var showingEditProfile = false
    @State private var showingLogoutAlert = false
<<<<<<< Updated upstream
    @EnvironmentObject var userObj: AuthService
=======
    @StateObject var userObj: AuthService
    
    init(userObj: AuthService = AuthService()) {
        _userObj = StateObject(wrappedValue: userObj)
    }
>>>>>>> Stashed changes
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 16) {
                    // Profile Image
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        .background(Circle().fill(.white))
                        .shadow(radius: 5)
                    
                    // Username
                    if let user = userObj.currentUser {
                        Text(user.username)
                            .font(.title2)
                            .bold()
                    }
                }
                .padding(.top, 20)
                
                // Account Options
                VStack(spacing: 0) {
                    // Edit Profile Button
                    Button(action: { showingEditProfile = true }) {
                        HStack {
                            Label("Edit Profile", systemImage: "person.fill")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color(.systemBackground))
                    }
                    .foregroundColor(.primary)
                    
                    Divider()
                    
                    // Settings
                    NavigationLink(destination: Text("Settings View")) {
                        HStack {
                            Label("Settings", systemImage: "gear")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color(.systemBackground))
                    }
                    
                    Divider()
                    
                    // Help & Support
                    NavigationLink(destination: Text("Help & Support View")) {
                        HStack {
                            Label("Help & Support", systemImage: "questionmark.circle")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color(.systemBackground))
                    }
                }
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Logout Button
                Button(action: {
<<<<<<< Updated upstream
                    Task {
                        try await userObj.logout()
                    }
=======
                    userObj.logout()
>>>>>>> Stashed changes
                }) {
                    Text("Log Out")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.large)
        .alert("Log Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                // Handle logout
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        .sheet(isPresented: $showingEditProfile) {
            NavigationView {
                Text("Edit Profile View")
                    .navigationTitle("Edit Profile")
                    .navigationBarItems(
                        trailing: Button("Done") {
                            showingEditProfile = false
                        }
                    )
            }
        }
        .overlay {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
        .task {
            // Simulate loading
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            isLoading = false
        }
    }
}

<<<<<<< Updated upstream
=======
#Preview {
    NavigationView {
        AccountView(userObj: AuthService())
    }
}
>>>>>>> Stashed changes
