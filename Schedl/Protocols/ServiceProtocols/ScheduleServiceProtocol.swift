//
//  ScheduleServiceProtocol.swift
//  Schedoolr
//
//  Created by David Medina on 5/5/25.
//

import FirebaseDatabase

protocol ScheduleServiceProtocol {
    func fetchSchedule(userId: String) async throws -> Schedule
    func fetchScheduleId(userId: String) async throws -> String
    func fetchScheduleIds(userIds: [String]) async throws -> [String]
    func createSchedule(userId: String, title: String) async throws -> Schedule
    func updateSchedule(scheduleId: String, title: String) async throws -> Void
    func deleteSchedule(scheduleId: String, userId: String) async throws -> Void
    func observeAddedEvents(scheduleId: String, completion: @escaping (String) -> Void) -> DatabaseHandle
    func observeRemovedEvents(scheduleId: String, completion: @escaping (
        String) -> Void) -> DatabaseHandle
    func observeUpdatedEvents(scheduleId: String, completion: @escaping (
        String) -> Void) -> DatabaseHandle
    func removeScheduleObserver(handle: DatabaseHandle, scheduleId: String)
}
