//
//  SearchServiceProtocol.swift
//  Schedoolr
//
//  Created by David Medina on 5/7/25.
//

protocol SearchServiceProtocol {
    func fetchMatchingUsers(username: String) async throws -> [String]
    func fetchUserSearchInfo(currentUserId: String, username: String) async throws -> [SearchInfo]
    func fetchUserInfo(currentUserId: String, userId: String) async throws -> SearchInfo
    
}
