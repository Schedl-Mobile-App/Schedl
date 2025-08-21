//
//  SearchServiceProtocol.swift
//  Schedoolr
//
//  Created by David Medina on 5/7/25.
//

protocol SearchServiceProtocol {
    func fetchMatchingUsers(username: String) async throws -> [String]
    func fetchUserSearchInfo(username: String) async throws -> [SearchInfo]
    func fetchFriendsSearchInfo(friendIds: [String]) async throws -> [SearchInfo]
    func fetchUserInfo(userId: String) async throws -> SearchInfo
    
}
