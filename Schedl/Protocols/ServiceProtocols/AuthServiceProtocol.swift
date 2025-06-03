//
//  AuthServiceProtocol.swift
//  Schedoolr
//
//  Created by David Medina on 5/4/25.
//

protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> String
    func signUp(email: String, password: String) async throws -> String
    func signOut() async throws -> Void
}
