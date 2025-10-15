//
//  Auth.swift
//  calendarTest
//
//  Created by David Medina on 9/26/24.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class AuthService: AuthServiceProtocol {
    
    static let shared = AuthService()
    var db: Firestore
    var auth: Auth
    
    private init() {
        db = Firestore.firestore()
        auth = Auth.auth()
    }
    
    func login(email: String, password: String) async throws -> String {
        do {
            let authResult = try await auth.signIn(withEmail: email, password: password)
            let userId = authResult.user.uid
            return userId
        } catch {
            print("failing here")
            print("The folowing error occured: \(error.localizedDescription)")
            throw AuthServiceError.failedToLogin
        }
    }
    
    func signUp(email: String, password: String) async throws -> String {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            return result.user.uid
        } catch {
            print("Error in sign up: \(error.localizedDescription)")
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
