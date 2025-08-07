//
//  SearchInfo.swift
//  Schedoolr
//
//  Created by David Medina on 5/16/25.
//

struct SearchInfo: Identifiable {
    var id: String
    var user: User
    var numOfFriends: Int
    var numOfPosts: Int
    var isFriend: Bool
    
    init(id: String, user: User, numOfFriends: Int, numOfPosts: Int, isFriend: Bool) {
        self.id = id
        self.user = user
        self.numOfFriends = numOfFriends
        self.numOfPosts = numOfPosts
        self.isFriend = isFriend
    }
}
