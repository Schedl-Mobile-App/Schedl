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
    func persistentLogin(retryInterval: TimeInterval = 0.3, timeout: TimeInterval = 5) async {
        self.isLoadingLaunchScreen = true
        let startTime = Date()
        while Date().timeIntervalSince(startTime) < timeout {
            if let cachedUserId = authService.auth.currentUser?.uid {
                do {
                    currentUser = try await userService.fetchUser(userId: cachedUserId)
                    isLoggedIn = true
                } catch {
                    print("Error in persistent login")
                    // handle fetch error
                }
                self.isLoadingLaunchScreen = false
                return
            }
            // Wait before retrying
            try? await Task.sleep(nanoseconds: UInt64(retryInterval * 1_000_000_000))
        }
        self.isLoadingLaunchScreen = false // Give up after timeout
    }
    
    @MainActor
    func login(email: String, password: String) async {
        if isLoadingLogin { return }
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
        }
    }
    
    @MainActor
    func signUp(username: String, displayName: String, email: String, password: String) async {
        if isLoadingLogin { return }
        isLoadingLogin = true
        errorMessage = nil
        do {
            let userId = try await authService.signUp(email: email, password: password)
            currentUser = try await userService.setProfileInfo(userId: userId, email: email, username: username, displayName: displayName)
            isLoggedIn = true
            isLoadingLogin = false
        } catch {
            errorMessage = "Failed to register account. Please try again later."
            isLoadingLogin = false
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
    
    func isValidPassword(_ pw: String) -> String? {
        let passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/
        
        if pw.wholeMatch(of: passwordRegex) != nil {
            return nil
        } else {
            return "Password must be 8+ characters with uppercase, lowercase, and number"
        }
    }
}
