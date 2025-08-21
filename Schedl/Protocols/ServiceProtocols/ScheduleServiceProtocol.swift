//
//  ScheduleServiceProtocol.swift
//  Schedoolr
//
//  Created by David Medina on 5/5/25.
//

import FirebaseDatabase

protocol ScheduleServiceProtocol {
    func fetchAllSchedules(userId: String) async throws -> [Schedule]
    func fetchSchedule(scheduleId: String) async throws -> Schedule
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
    func createBlendSchedule(ownerId: String, scheduleId: String, title: String, invitedUsers: [String], colors: [String: String]) async throws -> String
    
    func fetchAllBlendSchedules(userId: String) async throws -> [Blend]
    
    func fetchBlendSchedule(blendId: String) async throws -> Blend
    
    func observeAddedBlendSchedules(blendId: String, completion: @escaping (String) -> Void) -> DatabaseHandle
    
    func observeRemovedBlendSchedules(blendId: String, completion: @escaping (String) -> Void) -> DatabaseHandle
        
    func removeBlendObserver(handle: DatabaseHandle, blendId: String)
}
