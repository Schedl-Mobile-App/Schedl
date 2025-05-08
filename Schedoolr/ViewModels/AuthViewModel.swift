//
//  AuthViewModel.swift
//  Schedoolr
//
//  Created by David Medina on 5/2/25.
//

import SwiftUI

class AuthViewModel: ObservableObject, AuthViewModelProtocol {
    
    @Published var currentUser: User?
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var displayName: String = ""
    @Published var username: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private var authService: AuthServiceProtocol
    private var userService: UserServiceProtocol
    
    @Published var isLoggedIn = false
    
    init(authService: AuthServiceProtocol = AuthService.shared, userService: UserServiceProtocol = UserService.shared) {
        self.authService = authService
        self.userService = userService
    }
    
    @MainActor
    func login() async throws {
        self.isLoading = true
        self.errorMessage = nil
        do {
            let userId = try await authService.login(email: email, password: password)
            print("User id is \(userId)")
            currentUser = try await userService.fetchUser(userId: userId)
            print("current user is \(String(describing: currentUser))")
            isLoggedIn = true
            isLoading = false
        } catch {
            errorMessage = "Failed to login. Please try again later."
            isLoading = false
        }
    }
    
    @MainActor
    func signUp() async throws {
        isLoading = true
        errorMessage = nil
        do {
            let userId = try await authService.signUp(email: email, password: password)
            currentUser = try await userService.saveNewUser(userId: userId, username: username, email: email, displayName: displayName)
        } catch {
            errorMessage = "Failed to register account. Please try again later."
        }
    }
    
    @MainActor
    func signOut() async throws {
        do {
            try await authService.signOut()
        } catch {
            errorMessage = "failed to sign out. Please try again later."
        }
    }
    
}
