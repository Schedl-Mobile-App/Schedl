//
//  EventError.swift
//  calendarTest
//
//  Created by David Medina on 11/25/24.
//

enum EventServiceError: Error {
    case eventDataSerializationFailed
    case invalidEventData
    case failedToUpdateEvent
    case failedToDeleteEvent
    case failedToGetScheduleId
    case failedToFetchEvents
    case failedToDeleteAllEvents
}
