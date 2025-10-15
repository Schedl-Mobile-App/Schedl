//
//  EventService.swift
//  Schedoolr
//
//  Created by David Medina on 5/5/25.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseFunctions
import FirebaseFirestore

class EventService: EventServiceProtocol {

    static let shared = EventService()
    let fs: Firestore
    let functions: Functions
    
    private init() {
        fs = Firestore.firestore()
        functions = Functions.functions()
    }
        
    func fetchEvent(eventId: String) async throws -> Event {
        let eventsRef = fs.collection("events").document(eventId)
        let snapshot = try await eventsRef.getDocument()
        
        guard snapshot.exists else {
            throw FirebaseError.failedToFetchEvent
        }
        return try snapshot.data(as: Event.self)
    }
    
    func fetchEventsByUserId(userId: String) async throws -> [Event] {
        do {
            // Get user's first scheduleId (mirrors existing behavior)
            let query = fs.collection("events").whereField("participants", arrayContains: userId)
            let snapshot = try await query.getDocuments()
            
            let events = try snapshot.documents.compactMap { document in
                try document.data(as: Event.self)
            }
            
            return events
        } catch {
            throw EventServiceError.failedToFetchEvents
        }
    }
    
    func fetchEventsByScheduleId(scheduleId: String) async throws -> [Event] {
        do {
            // Read schedules/{scheduleId}.eventIds map, then fetch each event
            let query = fs.collection("events").whereField("scheduleIds", arrayContains: scheduleId)
            let snapshot = try await query.getDocuments()
            
            let events = try snapshot.documents.map { document in
                return try document.data(as: Event.self)
            }
            
            return events
        } catch {
            throw EventServiceError.failedToFetchEvents
        }
    }
    
    func fetchEventsByScheduleIds(scheduleIds: [String]) async throws -> [Event] {
        do {
            var events: [Event] = []
            try await withThrowingTaskGroup(of: [Event].self) { [weak self] group in
                guard let self = self else { return }
                for id in scheduleIds {
                    group.addTask {
                        try await self.fetchEventsByScheduleId(scheduleId: id)
                    }
                }
                
                for try await event in group {
                    events.append(contentsOf: event)
                }
            }
            
            return events
        } catch {
            throw EventServiceError.failedToFetchEvents
        }
    }
        
    func createEvent(userId: String, title: String, startDate: Date, startTime: Int, endTime: Int, location: MTPlacemark, color: String, recurrence: RecurrenceRule?, notes: String?, invitedUsers: [InvitedUser]?, scheduleId: String) async throws {
        
        do {
            let eventsRef = fs.collection("events").document()
            
            let eventObj = Event(id: eventsRef.documentID, ownerId: userId, title: title, startDate: startDate, startTime: startTime, endTime: endTime, location: location, color: color, invitedUsers: invitedUsers, recurrence: recurrence, notes: notes)
            
            try eventsRef.setData(from: eventObj)
            
            let scheduleIds = [scheduleId]
            let createdAt = FieldValue.serverTimestamp()
            let dict: [String: Any] = ["scheduleIds": scheduleIds, "createdAt": createdAt]
            try await eventsRef.setData(dict, merge: true)
            
        } catch {
            throw FirebaseError.failedToCreateEvent
        }
    }
        
    func checkIndividualAvailability(userId: String, eventDate: Double, startTime: Double, endTime: Double) async throws -> FriendAvailability {
        
        let payload: [String: Any] = [
            "userId": userId,
            "eventDate": eventDate,
            "startTime": startTime,
            "endTime": endTime,
        ]
        
        do {
            // 1. Await the result of the .call() method.
            let callableResult = try await functions.httpsCallable("checkAvailability")
                .call(payload)
            
            // 2. Decode the result using the .result(as:) method on the returned object.
            guard let dict = callableResult.data as? [String: Any] else { throw FirebaseError.failedToFetchUser }
            
            // Serialize to JSON Data
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
            
            // Decode into your Codable wrapper
            let decoded = try JSONDecoder().decode(FriendAvailability.self, from: jsonData)
            
            // Optionally, you can check decoded.status if you need to validate success
            // e.g., guard decoded.status == "success" else { throw FirebaseError.failedToCreateUser }
            
            return decoded
        } catch {
            throw FirebaseError.failedToCreateUser
        }
    }
    
    func checkAvailability(userIds: [String], eventDate: Double, startTime: Double, endTime: Double) async throws -> [FriendAvailability] {
        var availabilityList: [FriendAvailability] = []
        
        try await withThrowingTaskGroup(of: FriendAvailability.self) { group in
            for id in userIds {
                group.addTask {
                    try await self.checkIndividualAvailability(userId: id, eventDate: eventDate, startTime: startTime, endTime: endTime)
                }
            }
            for try await availability in group {
                availabilityList.append(availability)
            }
        }
        return availabilityList
    }
        
    func updateAllRecurringEvent(eventId: String, recurringDate: Double, scheduleId: String, title: String? = nil, eventDate: Double? = nil, repeatedDays: Set<Int>? = nil, endDate: Double? = nil, startTime: Double? = nil, endTime: Double? = nil, location: MTPlacemark? = nil, taggedUsers: [InvitedUser]? = nil, color: String? = nil, notes: String? = nil) async throws {
        try await updateRecurring(eventId: eventId, recurringDate: recurringDate, scheduleId: scheduleId, applyToFuture: true, title: title, eventDate: eventDate, repeatedDays: repeatedDays, endDate: endDate, startTime: startTime, endTime: endTime, location: location, taggedUsers: taggedUsers, color: color, notes: notes)
    }
    
    func updateSingleRecurringEvent(eventId: String, recurringDate: Double, scheduleId: String, title: String? = nil, eventDate: Double? = nil, repeatedDays: Set<Int>? = nil, endDate: Double? = nil, startTime: Double? = nil, endTime: Double? = nil, location: MTPlacemark? = nil, taggedUsers: [InvitedUser]? = nil, color: String? = nil, notes: String? = nil) async throws {
        try await updateRecurring(eventId: eventId, recurringDate: recurringDate, scheduleId: scheduleId, applyToFuture: false, title: title, eventDate: eventDate, repeatedDays: repeatedDays, endDate: endDate, startTime: startTime, endTime: endTime, location: location, taggedUsers: taggedUsers, color: color, notes: notes)
    }
    
    private func updateRecurring(eventId: String, recurringDate: Double, scheduleId: String, applyToFuture: Bool, title: String?, eventDate: Double?, repeatedDays: Set<Int>?, endDate: Double?, startTime: Double?, endTime: Double?, location: MTPlacemark?, taggedUsers: [InvitedUser]?, color: String?, notes: String?) async throws {
        let recurringDateInt = Int(recurringDate)
        var updates: [String: Any] = [:]
        
        if let eventDate = eventDate {
            updates["startDate"] = eventDate
        }
        if let endDate = endDate {
            updates["endDate"] = endDate
        }
        if let repeatedDays = repeatedDays {
            let repeatedDaysDict = Dictionary(uniqueKeysWithValues: repeatedDays.map { ("day_\($0)", true)})
            updates["repeatingDays"] = repeatedDaysDict
        }
        // Exception fields
        var exceptionUpdates: [String: Any] = [
            "date": recurringDateInt,
            "futureEventsIncluded": applyToFuture
        ]
        if let title = title { exceptionUpdates["title"] = title }
        if let startTime = startTime { exceptionUpdates["startTime"] = startTime }
        if let endTime = endTime { exceptionUpdates["endTime"] = endTime }
        if let location = location {
            exceptionUpdates["locationName"] = location.name
            exceptionUpdates["locationAddress"] = location.address
            exceptionUpdates["latitude"] = location.latitude
            exceptionUpdates["longitude"] = location.longitude
        }
        if let color = color { exceptionUpdates["color"] = color }
        if let notes = notes { exceptionUpdates["notes"] = notes }
        if let taggedUsers = taggedUsers {
            let taggedUsersDict = Dictionary(uniqueKeysWithValues: taggedUsers.map { ($0.userId, $0.status) })
            updates["taggedUsers"] = taggedUsersDict
        }
        
        let eventDoc = fs.collection("events").document(eventId)
        let scheduleEventDoc = fs.collection("scheduleEvents").document(scheduleId).collection("events").document(eventId)
        
        let batch = fs.batch()
        if updates.isEmpty == false {
            batch.updateData(updates, forDocument: eventDoc)
        }
        batch.setData(["exceptions.\(recurringDateInt)": exceptionUpdates], forDocument: eventDoc, merge: true)
        batch.setData(["last_modified": FieldValue.serverTimestamp()], forDocument: scheduleEventDoc, merge: true)
        
        do {
            try await batch.commit()
        } catch {
            throw EventServiceError.failedToUpdateEvent
        }
    }
    
    func updateEvent(eventId: String, scheduleId: String, title: String? = nil, eventDate: Double? = nil, startTime: Double? = nil, endTime: Double? = nil, location: MTPlacemark? = nil, repeatedDays: Set<Int>? = nil, taggedUsers: [InvitedUser]? = nil, color: String? = nil, notes: String? = nil, endDate: Double? = nil) async throws {
        var updates: [String: Any] = [:]
        
        if let eventDate = eventDate { updates["startDate"] = eventDate }
        if let endDate = endDate { updates["endDate"] = endDate }
        if let repeatedDays = repeatedDays {
            let repeatedDaysDict = Dictionary(uniqueKeysWithValues: repeatedDays.map { ("day_\($0)", true)})
            updates["repeatingDays"] = repeatedDaysDict
        }
        if let title = title { updates["title"] = title }
        if let startTime = startTime { updates["startTime"] = startTime }
        if let endTime = endTime { updates["endTime"] = endTime }
        if let location = location {
            updates["locationName"] = location.name
            updates["locationAddress"] = location.address
            updates["latitude"] = location.latitude
            updates["longitude"] = location.longitude
        }
        if let color = color { updates["color"] = color }
        if let notes = notes { updates["notes"] = notes }
        if let taggedUsers = taggedUsers {
            let taggedUsersDict = Dictionary(uniqueKeysWithValues: taggedUsers.map { ($0.userId, $0.status) })
            updates["taggedUsers"] = taggedUsersDict
        }
        
        guard updates.isEmpty == false else { return }
        
        let batch = fs.batch()
        let eventDoc = fs.collection("events").document(eventId)
        batch.updateData(updates, forDocument: eventDoc)
        let scheduleEventDoc = fs.collection("scheduleEvents").document(scheduleId).collection("events").document(eventId)
        batch.setData(["last_modified": FieldValue.serverTimestamp()], forDocument: scheduleEventDoc, merge: true)
        
        do {
            try await batch.commit()
        } catch {
            throw EventServiceError.failedToUpdateEvent
        }
    }
        
    func deleteEvent(eventId: String) async throws {
        do {
            let eventRef = fs.collection("events").document(eventId)
            try await eventRef.delete()
        } catch {
            throw EventServiceError.failedToDeleteEvent
        }
    }
}

