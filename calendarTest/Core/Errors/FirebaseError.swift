//
//  FirebaseError.swift
//  calendarTest
//
//  Created by David Medina on 11/25/24.
//

enum FirebaseError: Error {
    case failedToFetchUser
    case failedToCreateUser
    case failedToFetchSchedule
    case failedToCreateSchedule
    case failedToFetchEvent
}
