//
//  ScheduleServiceProtocol.swift
//  Schedoolr
//
//  Created by David Medina on 5/5/25.
//

import FirebaseFirestore

protocol ScheduleServiceProtocol {
    func fetchAllSchedules(userId: String) async throws -> [Schedule]
    func fetchScheduleId(userId: String) async throws -> String
    func fetchSchedule(scheduleId: String) async throws -> Schedule
    func createSchedule(userId: String, title: String) async throws -> Schedule
    func updateSchedule(scheduleId: String, title: String) async throws -> Void
    func deleteSchedule(scheduleId: String, userId: String) async throws -> Void

    // Firestore listeners
    func observeAddedEvents(scheduleId: String, completion: @escaping (String) -> Void) -> ListenerRegistration
    func observeRemovedEvents(scheduleId: String, completion: @escaping (String) -> Void) -> ListenerRegistration
    func observeUpdatedEvents(scheduleId: String, completion: @escaping (String) -> Void) -> ListenerRegistration
    func removeScheduleObserver(listener: ListenerRegistration)

    func createBlendSchedule(ownerId: String, scheduleId: String, title: String, invitedUsers: [InvitedUser], colors: [UserMappedBlendColor]) async throws -> Void
    
    func fetchAllBlendSchedules(userId: String) async throws -> [Blend]
    func fetchBlendSchedule(blendId: String) async throws -> Blend?

    func observeCreatedBlend(userId: String, completion: @escaping (String) -> Void) -> ListenerRegistration
    func observeAddedBlendSchedules(blendId: String, completion: @escaping (String) -> Void) -> ListenerRegistration
    func observeRemovedBlendSchedules(blendId: String, completion: @escaping (String) -> Void) -> ListenerRegistration

    func removeNewBlendObserver(listener: ListenerRegistration)
    func removeBlendObserver(listener: ListenerRegistration)
}
