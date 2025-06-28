//
//  AuthViewModelProtocol.swift
//  Schedoolr
//
//  Created by David Medina on 5/2/25.
//

protocol AuthViewModelProtocol {
    var currentUser: User? { get set }
    
    func login(email: String, password: String) async -> Void
    func signUp(username: String, displayName: String, email: String, password: String) async -> Void
    func logout() async
}
