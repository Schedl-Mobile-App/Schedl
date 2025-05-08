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
    
    func fetchUserSearchInfo(username: String) async throws -> [String] {
        
        let userRef = ref.child("usernames").queryOrderedByKey()
            .queryStarting(atValue: username)
            .queryEnding(atValue: username + "\u{f8ff}")
            .queryLimited(toFirst: 6)
        
        // fetches entire usernames node so that we can filter cloest matched results
        let snapshot = try await userRef.getData()
        guard let DBUserNames = snapshot.value as? [String: String] else {
            throw FirebaseError.failedToFetchUserById
        }
        
        return Array(DBUserNames.values)
    }
}
