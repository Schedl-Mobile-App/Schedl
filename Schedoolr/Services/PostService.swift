//
//  PostService.swift
//  Schedoolr
//
//  Created by David Medina on 9/23/24.
//

import FirebaseDatabase
import FirebaseStorage

class PostService: PostServiceProtocol, ObservableObject {
    
    static let shared = PostService()
    let ref: DatabaseReference
    let storage: Storage

    private init() {
        ref = Database.database().reference()
        storage = Storage.storage()
    }
    
    func createPost(postData: Post, userId: String, friendIds: [String]) async throws {
        var copyPostData = postData
        let id = ref.child("posts").childByAutoId().key ?? UUID().uuidString
        copyPostData.id = id
        
        // Update feeds for each friend
        var feedUpdates: [String: Any] = [:]
        for friendId in friendIds {
            feedUpdates["feeds/\(friendId)/\(id)"] = postData.creationDate
        }
        
        let encoder = JSONEncoder()
        do {
            // Encode the Post object into JSON data
            let jsonData = try encoder.encode(copyPostData)
            
            // Convert JSON data to a dictionary
            guard let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                throw PostServiceError.postDataSerializationFailed
            }
            
            feedUpdates["posts/\(id)"] = jsonDictionary
            feedUpdates["user-posts/\(userId)/\(id)"] = true
            
            try await ref.updateChildValues(feedUpdates)
        } catch {
            throw FirebaseError.failedToCreatePost
        }
    }
    
    func fetchPost(postId: String) async throws -> Post {
        let postsRef = ref.child("posts").child(postId)
        let snapshot = try await postsRef.getData()
        
        // Capture all the data first
        guard let postData = snapshot.value as? [String: Any] else {
            throw FirebaseError.failedToFetchPost
        }
        
        // Get all values before creating Post
        guard
            let id = postData["id"] as? String,
            let title = postData["title"] as? String,
            let description = postData["description"] as? String,
            let likes = postData["likes"] as? Int,
            let eventLocation = postData["eventLocation"] as? String,
            let creationDate = postData["creationDate"] as? Double
        else {
            throw PostServiceError.invalidPostData
        }
        
        let eventPhotos = postData["eventPhotos"] as? [String] ?? []
        let taggedUsers = postData["taggedUsers"] as? [String] ?? []
        let comments = postData["comments"] as? [String] ?? []

        // Create post on main thread since this is a @MainActor function
        return await MainActor.run {
            Post(
                id: id,
                title: title,
                description: description,
                eventPhotos: eventPhotos,
                comments: comments,
                likes: Double(likes),  // Convert Int to Double since your Post model uses Double
                taggedUsers: taggedUsers,
                eventLocation: eventLocation,
                creationDate: creationDate
            )
        }
    }
    
    func fetchPostsByUserId(userId: String) async throws -> [Post] {
        
        var posts: [Post] = []
        
        let postsRef = ref.child("userPosts").child(userId)
        let snapshot = try await postsRef.getData()
        
        guard let userPostsNode = snapshot.value as? [String: Any] else {
            throw PostServiceError.failedToFetchPosts
        }
        
        let postIds = Array(userPostsNode.keys)
        try await withThrowingTaskGroup(of: Post.self) { group in
            for id in postIds {
                group.addTask {
                    try await self.fetchPost(postId: id)
                }
            }
            
            for try await post in group {
                posts.append(post)
            }
        }
        
        return posts
    }
    
    func fetchFriendsPosts(userId: String) async throws -> [Post] {
        let postsRef = ref.child("feeds").child(userId)
        let snapshot = try await postsRef.getData()
        
        guard let result = snapshot.value as? [String: Double] else {
            throw FirebaseError.failedToFetchFriendsPostsIds
        }
        
        let postIds: [String] = Array(result.keys)
        var posts: [Post] = []
        
        if postIds.isEmpty {
            return posts
        }
        
        // Create posts in batches
        try await withThrowingTaskGroup(of: Post.self) { group in
            for id in postIds {
                group.addTask {
                    try await self.fetchPost(postId: id)
                }
            }
            
            // Collect results in batches
            for try await post in group {
                posts.append(post)
            }
        }
        
        return posts
    }
    
    func observeFeedChanges(userId: String, completion: @escaping ([Post]?) -> Void) -> DatabaseHandle {
        let feedRef = ref.child("feeds").child(userId)
        return feedRef.observe(.value) { snapshot, _ in
            guard let feedData = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            
            let postIds = feedData.keys
            var posts: [Post] = []
            
            Task {
                do {
                    try await withThrowingTaskGroup(of: Post.self) { group in
                        for id in postIds {
                            group.addTask {
                                try await self.fetchPost(postId: id)
                            }
                            
                            // Collect results in batches
                            for try await post in group {
                                posts.append(post)
                            }
                        }
                    }
                    
                    completion(posts)
                    
                } catch {
                    completion(nil)
                }
            }
        }
    }
    
    func fetchNumOfPosts(userId: String) async throws -> Int {
        
        let postsRef = ref.child("userPosts").child(userId)
        let snapshot = try await postsRef.getData()
        
        guard let postsDict = snapshot.value as? [String: Any] else {
            throw PostServiceError.failedToReturnNumberOfPosts
        }
        
        return postsDict.keys.count
    }
    
    func removeFeedObserver(handle: DatabaseHandle, userId: String) {
        let feedRef = ref.child("feeds").child(userId)
        feedRef.removeObserver(withHandle: handle)
    }
    
}
