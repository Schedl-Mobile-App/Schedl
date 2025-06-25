//
//  Auth.swift
//  calendarTest
//
//  Created by David Medina on 9/26/24.
//

import FirebaseAuth
import FirebaseDatabase
import Foundation

class AuthService: AuthServiceProtocol {
    
    static let shared = AuthService()
    var ref: DatabaseReference
    var auth: Auth
    
    private init() {
        ref = Database.database().reference()
        auth = Auth.auth()
    }
    
    func login(email: String, password: String) async throws -> String {
        do {
            let authResult = try await auth.signIn(withEmail: email, password: password)
            let userId = authResult.user.uid
            return userId
        } catch {
            throw AuthServiceError.failedToLogin
        }
    }
    
    func signUp(email: String, password: String) async throws -> String {
        do {
            let authResult = try await auth.createUser(withEmail: email, password: password)
            let userId = authResult.user.uid
            return userId
            
        } catch {
            throw AuthServiceError.failedToSignUp
        }
    }
    
    func changeEmail() {
        guard let user = auth.currentUser else { return }
        
        user.sendEmailVerification { error in
            if let error = error {
                print("Error sending verification email: \(error.localizedDescription)")
            } else {
                return
            }
        }
    }

    func signOut() async throws -> Void {
        do {
            try auth.signOut()
        } catch {
            throw AuthServiceError.failedToSignOut
        }
    }
}
