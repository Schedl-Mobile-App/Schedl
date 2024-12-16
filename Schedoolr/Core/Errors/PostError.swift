//
//  PostError.swift
//  calendarTest
//
//  Created by David Medina on 12/10/24.
//

enum PostError: Error {
    case postDataSerializationFailed
    case failedToUpdatePost
    case invalidPostData
}
