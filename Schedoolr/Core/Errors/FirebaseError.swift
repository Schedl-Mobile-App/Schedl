//
//  FirebaseError.swift
//  calendarTest
//
//  Created by David Medina on 11/25/24.
//

enum FirebaseError: Error {
    case failedToFetchUser
    case failedToFetchUserByName
    case failedToFetchUserById
    case failedToCreateUser
    case failedToFetchSchedule
    case failedToCreateSchedule
    case failedToFetchEvent
    case failedToCreateEvent
    case failedToCreatePost
    case failedToFetchPost
    case failedToUpdateFeed
    case failedToFetchFriendsPostsIds
    case failedToFetchFriendsPosts
    case failedToHandleFriendRequest
    case failedToUpdateFriendRequest
    case incorrectFriendRequestId
    case failedToFetchFriendRequests
}
