//
//  AuthViewModelProtocol.swift
//  Schedoolr
//
//  Created by David Medina on 5/2/25.
//

protocol AuthViewModelProtocol {
    var currentUser: User? { get set }
    
    func login() async throws -> Void
    func signUp() async throws -> Void
    func signOut() async throws -> Void
}
