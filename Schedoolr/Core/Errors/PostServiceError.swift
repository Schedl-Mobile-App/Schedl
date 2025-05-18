//
//  PostError.swift
//  calendarTest
//
//  Created by David Medina on 12/10/24.
//

enum PostServiceError: Error {
    case postDataSerializationFailed
    case failedToUpdatePost
    case failedToFetchPosts
    case failedToDeletePost
    case failedToCreatePost
    case invalidPostData
    case failedToReturnNumberOfPosts
}
