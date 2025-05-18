//
//  SearchInfo.swift
//  Schedoolr
//
//  Created by David Medina on 5/16/25.
//

struct SearchInfo {
    var numOfFriends: Int
    var numOfPosts: Int
    var isFriend: Bool
    
    init(numOfFriends: Int, numOfPosts: Int, isFriend: Bool) {
        self.numOfFriends = numOfFriends
        self.numOfPosts = numOfPosts
        self.isFriend = isFriend
    }
}
