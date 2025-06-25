//
//  AuthViewModel.swift
//  Schedoolr
//
//  Created by David Medina on 5/2/25.
//

import SwiftUI
import FirebaseAuth

class AuthViewModel: ObservableObject, AuthViewModelProtocol {
    
    @Published var currentUser: User?
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var displayName: String = ""
    @Published var username: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var hasOnboarded: Bool
    private var authService: AuthServiceProtocol
    private var userService: UserServiceProtocol
    
    @Published var isLoggedIn = false
    
    init(authService: AuthServiceProtocol = AuthService.shared, userService: UserServiceProtocol = UserService.shared, hasOnboarded: Bool) {
        self.authService = authService
        self.userService = userService
        self.hasOnboarded = hasOnboarded
    }
    
    @MainActor
    func persistentLogin() async {
        self.isLoading = true
        guard let cachedUserId = authService.auth.currentUser?.uid else {
            self.isLoading = false
            return
        }
        do {
            currentUser = try await userService.fetchUser(userId: cachedUserId)
            isLoggedIn = true
            self.isLoading = false
        } catch {
            print("The following error occured int he persistent login: \(error.localizedDescription)")
            self.isLoading = false
        }
    }
    
    @MainActor
    func login() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            let userId = try await authService.login(email: email, password: password)
            currentUser = try await userService.fetchUser(userId: userId)
            isLoggedIn = true
            isLoading = false
        } catch {
            errorMessage = "Failed to login. Please try again later."
            isLoading = false
            email = ""
            password = ""
        }
    }
    
    @MainActor
    func signUp() async {
        isLoading = true
        errorMessage = nil
        do {
            let userId = try await authService.signUp(email: email, password: password)
            currentUser = try await userService.saveNewUser(userId: userId, username: username, email: email, displayName: displayName)
            isLoggedIn = true
            isLoading = false
        } catch {
            errorMessage = "Failed to register account. Please try again later."
            isLoading = false
            username = ""
            displayName = ""
            email = ""
            password = ""
        }
    }
    
//    @MainActor
//    func changeEmail() async throws {
//        isLoading = true
//        errorMessage = nil
//        do {
//            try await authService.changeEmail(currentEmail: currentUser.email)
//            isLoading = false
//        } catch {
//            errorMessage = "Failed to register account. Please try again later."
//        }
//    }
    
    @MainActor
    func logout() async {
        self.errorMessage = nil
        do {
            try await authService.signOut()
            isLoggedIn = false
            currentUser = nil
        } catch {
            self.errorMessage = "Failed to sign out. Please try again later."
        }
    }
    
}
