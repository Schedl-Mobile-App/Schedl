//
//  AuthViewModelProtocol.swift
//  Schedoolr
//
//  Created by David Medina on 5/2/25.
//

protocol AuthViewModelProtocol {
    var currentUser: User? { get set }
    
    func login() async -> Void
    func signUp() async -> Void
    func logout() async
}
