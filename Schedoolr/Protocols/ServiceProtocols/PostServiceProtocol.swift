//
//  PostService.swift
//  Schedoolr
//
//  Created by David Medina on 5/9/25.
//

import FirebaseDatabase

protocol PostServiceProtocol {
    
    func createPost(postData: Post, userId: String, friendIds: [String]) async throws
    func fetchPost(postId: String) async throws -> Post
    func fetchPostsByUserId(userId: String) async throws -> [Post]
    func fetchFriendsPosts(userId: String) async throws -> [Post]
    func observeFeedChanges(userId: String, completion: @escaping ([Post]?) -> Void) -> DatabaseHandle
    func removeFeedObserver(handle: DatabaseHandle, userId: String)
}
