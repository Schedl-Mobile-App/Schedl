//
//  EventServiceProtocol.swift
//  Schedoolr
//
//  Created by David Medina on 5/5/25.
//

protocol EventServiceProtocol {
    func fetchEvent(eventId: String) async throws -> Event
    func fetchEventsByUserId(userId: String) async throws -> [Event]
    func fetchEventsByScheduleId(scheduleId: String) async throws -> [Event]
    func fetchEventsByScheduleIds(scheduleIds: [String]) async throws -> [Event]
    func createEvent(userId: String, title: String, startDate: Double, startTime: Double, endTime: Double, location: MTPlacemark, color: String, notes: String, taggedUsers: [InvitedUser], endDate: Double?, repeatedDays: Set<Int>?, scheduleId: String) async throws -> Void
    func updateEvent(eventId: String, scheduleId: String, title: String?, eventDate: Double?, startTime: Double?, endTime: Double?, location: MTPlacemark?, repeatedDays: Set<Int>?, taggedUsers: [InvitedUser]?, color: String?, notes: String?, endDate: Double?) async throws -> Void
    func updateSingleRecurringEvent(eventId: String, recurringDate: Double, scheduleId: String, title: String?, eventDate: Double?, repeatedDays: Set<Int>?, endDate: Double?, startTime: Double?, endTime: Double?, location: MTPlacemark?, taggedUsers: [InvitedUser]?, color: String?, notes: String?) async throws
    func updateAllRecurringEvent(eventId: String, recurringDate: Double, scheduleId: String, title: String?, eventDate: Double?, repeatedDays: Set<Int>?, endDate: Double?, startTime: Double?, endTime: Double?, location: MTPlacemark?, taggedUsers: [InvitedUser]?, color: String?, notes: String?) async throws
    func deleteEvent(eventId: String) async throws -> Void
    func checkIndividualAvailability(userId: String, eventDate: Double, startTime: Double, endTime: Double) async throws -> FriendAvailability
    func checkAvailability(userIds: [String], eventDate: Double, startTime: Double, endTime: Double) async throws -> [FriendAvailability]
}
