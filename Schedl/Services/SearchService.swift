//
//  SearchService.swift
//  Schedoolr
//
//  Created by David Medina on 5/7/25.
//

import FirebaseDatabase

class SearchService: SearchServiceProtocol {
    
    static let shared = SearchService()
    let ref: DatabaseReference
    
    private init() {
        ref = Database.database().reference()
    }
    
    func fetchMatchingUsers(username: String) async throws -> [String] {
        let userRef = ref.child("usernames").queryOrderedByKey()
            .queryStarting(atValue: username)
            .queryEnding(atValue: username + "\u{f8ff}")
            .queryLimited(toFirst: 10)
        
        // fetches entire usernames node so that we can filter cloest matched results
        let snapshot = try await userRef.getData()
        guard let matchedUsers = snapshot.value as? [String: String] else {
            return []
        }
        
        return Array(matchedUsers.values)
    }
    
    func fetchUserSearchInfo(username: String) async throws -> [SearchInfo] {
        
        let matchedUserIds = try await fetchMatchingUsers(username: username)
        
        var mappedSearchData: [SearchInfo] = []
        
        try await withThrowingTaskGroup(of: SearchInfo.self) { group in
            for id in matchedUserIds {
                group.addTask {
                    try await self.fetchUserInfo(userId: id)
                }
            }
            for try await result in group {
                mappedSearchData.append(result)
            }
        }
        
        return mappedSearchData
    }
    
    func fetchFriendsSearchInfo(friendIds: [String]) async throws -> [SearchInfo] {
        
        var mappedSearchData: [SearchInfo] = []
        
        try await withThrowingTaskGroup(of: SearchInfo.self) { group in
            for id in friendIds {
                group.addTask {
                    try await self.fetchUserInfo(userId: id)
                }
            }
            for try await result in group {
                mappedSearchData.append(result)
            }
        }
        
        return mappedSearchData
    }
    
    func fetchUserInfo(userId: String) async throws -> SearchInfo {
        let userRef = ref.child("users").child(userId)
        
        let snapshot = try await userRef.getData()
        guard let userData = snapshot.value as? [String: Any] else {
            throw FirebaseError.failedToFetchUserById
        }
        
        let friends = userData["friends"] as? [String: Bool] ?? [:]
        let posts = userData["posts"] as? [String: Bool] ?? [:]
        
        if
            let id = userData["id"] as? String,
            let username = userData["username"] as? String,
            let displayName = userData["displayName"] as? String,
            let email = userData["email"] as? String,
            let profileImage = userData["profileImage"] as? String,
            let createdAt = userData["creationDate"] as? Double {
            
            let user = User(id: id, username: username, email: email, displayName: displayName, profileImage: profileImage, creationDate: createdAt)
            return SearchInfo(id: user.id, user: user, numOfFriends: friends.keys.count, numOfPosts: posts.keys.count)
        } else {
            throw UserServiceError.invalidData
        }
    }
}
