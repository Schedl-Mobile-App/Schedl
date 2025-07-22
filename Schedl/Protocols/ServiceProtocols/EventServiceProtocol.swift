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
    func fetchEvents(eventIds: [String]) async throws -> [Event]
    func createEvent(userId: String, title: String, startDate: Double, startTime: Double, endTime: Double, location: MTPlacemark, color: String, notes: String, endDate: Double?, repeatedDays: [String]?) async throws -> String
    func updateEvent(eventId: String, scheduleIds: [String], title: String?, eventDate: Double?, startTime: Double?, endTime: Double?, location: MTPlacemark?, repeatedDays: [String]?, color: String?, notes: String?) async throws -> Void
    func deleteEvent(eventId: String, userId: String) async throws -> Void
    func checkIndividualAvailability(userId: String, startQuery: String, endQuery: String) async throws -> FriendAvailability
    func checkAvailability(userIds: [String], eventDate: Int, startTime: Int, endTime: Int) async throws -> [FriendAvailability]
}
