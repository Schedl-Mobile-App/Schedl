//
//  MockEventService.swift
//  Schedl
//
//  Created by David Medina on 10/9/25.
//

import Foundation

class MockEventService: EventServiceProtocol {
    
    private var events: [Event]
    
    init(userId: String) {
        self.events = MockEventFactory.createEvents(30, for: userId)
    }
    
    func fetchEvent(eventId: String) async throws -> Event {
        guard let event = events.first(where: { $0.id == eventId }) else { throw EventServiceError.failedToFetchEvents }
        
        return event
    }
    
    func fetchEventsByUserId(userId: String) async throws -> [Event] {
        return events.filter { $0.ownerId == userId }
    }
    
    func fetchEventsByScheduleId(scheduleId: String) async throws -> [Event] {
        return events
    }
    
    func fetchEventsByScheduleIds(scheduleIds: [String]) async throws -> [Event] {
        return events
    }
    
    func createEvent(userId: String, title: String, startDate: Date, startTime: Int, endTime: Int, location: MTPlacemark, color: String, recurrence: RecurrenceRule?, notes: String?, invitedUsers: [InvitedUser]?, scheduleId: String) async throws {
        
        let event = Event(id: UUID().uuidString, ownerId: userId, title: title, startDate: startDate, startTime: startTime, endTime: endTime, location: location, color: color, invitedUsers: invitedUsers ?? [], recurrence: recurrence, notes: notes)
    }
    
    func updateEvent(eventId: String, scheduleId: String, title: String?, eventDate: Double?, startTime: Double?, endTime: Double?, location: MTPlacemark?, repeatedDays: Set<Int>?, taggedUsers: [InvitedUser]?, color: String?, notes: String?, endDate: Double?) async throws {
        
        return
    }
    
    func updateSingleRecurringEvent(eventId: String, recurringDate: Double, scheduleId: String, title: String?, eventDate: Double?, repeatedDays: Set<Int>?, endDate: Double?, startTime: Double?, endTime: Double?, location: MTPlacemark?, taggedUsers: [InvitedUser]?, color: String?, notes: String?) async throws {
       
        return
    }
    
    func updateAllRecurringEvent(eventId: String, recurringDate: Double, scheduleId: String, title: String?, eventDate: Double?, repeatedDays: Set<Int>?, endDate: Double?, startTime: Double?, endTime: Double?, location: MTPlacemark?, taggedUsers: [InvitedUser]?, color: String?, notes: String?) async throws {
        
        return
    }
    
    func deleteEvent(eventId: String) async throws {
        guard let index = events.firstIndex(where: { $0.id == eventId }) else { throw EventServiceError.failedToDeleteEvent }
        
        events.remove(at: index)
    }
    
    func checkIndividualAvailability(userId: String, eventDate: Double, startTime: Double, endTime: Double) async throws -> FriendAvailability {
        
        return FriendAvailability(available: true, userId: userId)
    }
    
    func checkAvailability(userIds: [String], eventDate: Double, startTime: Double, endTime: Double) async throws -> [FriendAvailability] {
    
        return userIds.compactMap({ return FriendAvailability(available: true, userId: $0 )})
    }
    
}
