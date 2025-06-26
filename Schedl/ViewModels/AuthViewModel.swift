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
    @Published var isLoadingLaunchScreen: Bool = false
    @Published var isLoadingLogin: Bool = false
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
        self.isLoadingLaunchScreen = true
        guard let cachedUserId = authService.auth.currentUser?.uid else {
            self.isLoadingLaunchScreen = false
            return
        }
        do {
            currentUser = try await userService.fetchUser(userId: cachedUserId)
            isLoggedIn = true
            self.isLoadingLaunchScreen = false
        } catch {
            self.isLoadingLaunchScreen = false
        }
    }
    
    @MainActor
    func login() async {
        self.isLoadingLogin = true
        self.errorMessage = nil
        do {
            let userId = try await authService.login(email: email, password: password)
            currentUser = try await userService.fetchUser(userId: userId)
            isLoggedIn = true
            isLoadingLogin = false
        } catch {
            errorMessage = "Failed to login. Please try again later."
            isLoadingLogin = false
            email = ""
            password = ""
        }
    }
    
    @MainActor
    func signUp() async {
        isLoadingLogin = true
        errorMessage = nil
        do {
            let userId = try await authService.signUp(email: email, password: password)
            currentUser = try await userService.saveNewUser(userId: userId, username: username, email: email, displayName: displayName)
            isLoggedIn = true
            isLoadingLogin = false
        } catch {
            errorMessage = "Failed to register account. Please try again later."
            isLoadingLogin = false
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
