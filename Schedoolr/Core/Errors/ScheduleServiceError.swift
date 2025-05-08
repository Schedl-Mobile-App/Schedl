//
//  ScheduleError.swift
//  calendarTest
//
//  Created by David Medina on 11/25/24.
//

enum ScheduleServiceError: Error {
    case scheduleDataSerializationFailed
    case invalidScheduleData
    case failedToUpdateSchedule
    case failedToDeleteSchedule
    case failedToDeleteEventsOfDeletedSchedule
    case failedToDeleteEventFromScheduleDeletion
    case failedToDeleteScheduleFromUser
    case failedToFetchScheduleFromUser
    case failedToFindScheduleId
    case failedToFetchScheduleEvents
}
