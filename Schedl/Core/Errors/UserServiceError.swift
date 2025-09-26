//
//  UserError.swift
//  calendarTest
//
//  Created by David Medina on 11/25/24.
//

enum UserServiceError: Error {
    case serializationFailed
    case invalidData
    case failedToFetchFriends
    case failedToUpdateProfileImage
}
