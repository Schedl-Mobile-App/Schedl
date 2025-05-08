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
    func createEvent(scheduleId: String, userId: String, title: String, eventDate: Double, startTime: Double, endTime: Double) async throws -> Event
    func updateEvent(eventId: String, title: String?, eventDate: Double?, startTime: Double?, endTime: Double?) async throws -> Void
    func deleteEvent(eventId: String, scheduleId: String) async throws -> Void
    func deleteScheduleEvents(scheduleId: String) async throws -> Void
    func fetchCurrentEvents(currentDay: Double, userId: String) async throws -> [Event]
}
