//
//  Auth.swift
//  calendarTest
//
//  Created by David Medina on 9/26/24.
//

import FirebaseAuth
import Foundation

class AuthService: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var currentUser: User?
    @Published var errorMsg: String?
    @Published var isLoggedIn: Bool = false
    
    init() {
    }

    @MainActor
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMsg = error.localizedDescription
                return
            }

            // Successful login
            if let userId = authResult?.user.uid {
                Task {
                    do {
                        let fetchedUser = try await FirebaseManager.shared.fetchUserAsync(id: userId)
                        self.currentUser = fetchedUser
                    } catch {
                        self.errorMsg = "Failed to login: \(error.localizedDescription)"
                    }
                    self.username = ""
                    self.email = ""
                    self.password = ""
                    self.isLoggedIn = true
                }
            }
        }
    }
    
    @MainActor
    func signUp(username: String, email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMsg = error.localizedDescription
                return
            }
            
            let userObj: User
            let createdAt = Date().timeIntervalSince1970
            
            if let userId = authResult?.user.uid {
                userObj = User(
                    id: userId,
                    username: username,
                    email: email,
                    schedules: [],
                    creationDate: createdAt
                )
                
                Task {
                    do {
                        try await FirebaseManager.shared.saveNewUserAsync(userData: userObj)
                        self.login(email: email, password: password)
                    } catch {
                        self.errorMsg = "Failed to sign up: \(error.localizedDescription)"
                        self.username = ""
                        self.email = ""
                        self.password = ""
                    }
                }
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            isLoggedIn = false
        } catch {
            print("Error signing out: \(error)")
        }
    }
}
