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

    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMsg = error.localizedDescription
                return
            }

            // Successful login
            if let userId = authResult?.user.uid {
                // Fetch additional user info from the database if needed
                FirebaseManager.shared.fetchUser(userId: userId)
                { user, error in
                    DispatchQueue.main.async {
                        if let user = user {
                            self.currentUser = user
                            self.isLoggedIn = true
                        } else if let error = error {
                            self.errorMsg = error.localizedDescription
                        }
                    }
                }
            }
        }
    }
    
    func signUp(username: String, email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMsg = error.localizedDescription
                return
            }
            
            let userObj: User
            
            if let userId = authResult?.user.uid {
                userObj = User(
                    userId: userId,
                    username: username,
                    email: email,
                    schedules: []
                )
                
                FirebaseManager.shared.saveUser(userData: userObj)
                { result in
                    DispatchQueue.main.async {
                        if let result = result {
                            self.errorMsg = result.localizedDescription
                        }
                    }
                }
                
                self.login(email: email, password: password)
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
