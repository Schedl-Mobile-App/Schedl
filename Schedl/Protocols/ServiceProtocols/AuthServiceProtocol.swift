//
//  AuthServiceProtocol.swift
//  Schedoolr
//
//  Created by David Medina on 5/4/25.
//

import FirebaseFirestore
import FirebaseAuth

protocol AuthServiceProtocol {
    
    var db: Firestore { get set }
    var auth: Auth             { get set }
    
    func login(email: String, password: String) async throws -> String
    func signUp(email: String, password: String) async throws -> String
    func changeEmail() -> Void
    func signOut() async throws -> Void
}
