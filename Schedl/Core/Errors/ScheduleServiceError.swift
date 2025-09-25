//
//  ScheduleError.swift
//  calendarTest
//
//  Created by David Medina on 11/25/24.
//

enum ScheduleServiceError: Error {
    case failedToFetchAllSchedules
    case failedToFetchSchedule
    case failedToFetchScheduleEvents
    case failedToDeleteSchedule
    case failedToUpdateSchedule
    case failedToFetchAllBlends
    case failedToFetchBlend
    
    case scheduleDataSerializationFailed
    case invalidScheduleData

}
