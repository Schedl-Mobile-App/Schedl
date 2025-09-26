//
//  SearchServiceProtocol.swift
//  Schedoolr
//
//  Created by David Medina on 5/7/25.
//

protocol SearchServiceProtocol {
    func fetchUserSearchInfo(username: String) async throws -> [User]
    func fetchFriendsSearchInfo(friendIds: [String]) async throws -> [User]
    func fetchUserInfo(userId: String) async throws -> User
    
}
