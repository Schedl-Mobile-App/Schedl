//
//  SearchService.swift
//  Schedoolr
//
//  Created by David Medina on 5/7/25.
//

import FirebaseCore
import FirebaseFirestore

class SearchService: SearchServiceProtocol {
    
    static let shared = SearchService()
    let db: Firestore
    
    private init() {
        db = Firestore.firestore()
    }
    
    func fetchUserSearchInfo(username: String) async throws -> [User] {
        let prefix = username.lowercased()
        guard prefix.isEmpty == false else { return [] }
        
        do {
            // Query by a field to support range queries.
            // Firestore cannot do range queries on document IDs directly.
            let query = db.collection("public_profiles")
                .order(by: "usernameLower")
                .start(at: [prefix])
                .end(at: [prefix + "\u{f8ff}"])
                .limit(to: 10)
            
            let snapshot = try await query.getDocuments()
            
            // Expect documents to contain a "userId" field
            let users = try snapshot.documents.compactMap { document in
                return try document.data(as: User.self)
            }
            return users
        } catch {
            throw UserServiceError.invalidData
        }
    }
    
    func fetchFriendsSearchInfo(friendIds: [String]) async throws -> [User] {
        guard friendIds.isEmpty == false else { return [] }
        
        do {
            let query = db.collection("public_profiles").whereField("id", in: friendIds)
            let snapshot = try await query.getDocuments()
            
            let searchInfo = try snapshot.documents.compactMap { document in
                return try document.data(as: User.self)
            }
            
            return searchInfo
            
        } catch {
            throw UserServiceError.invalidData
        }
    }
    
    func fetchUserInfo(userId: String) async throws -> User {
        do {
            let query = db.collection("public_profiles").document(userId)
            let snapshot = try await query.getDocument()
            
            return try snapshot.data(as: User.self)
        } catch {
            throw UserServiceError.invalidData
        }
    }
}

