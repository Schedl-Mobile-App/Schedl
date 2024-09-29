//
//  Auth.swift
//  calendarTest
//
//  Created by David Medina on 9/26/24.
//

import FirebaseAuth
import Foundation

class AuthService: ObservableObject {
    @Published var email: String
    @Published var password: String
    @Published var currentUser: User?
    @Published var errorMsg: String?
    @Published var isLoggedIn: Bool = false
    
    init(email: String = "", password: String = "") {
            self.email = email
            self.password = password
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
                self.currentUser = User(userId: userId, username: "Fetched Username")
                self.isLoggedIn = true
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
