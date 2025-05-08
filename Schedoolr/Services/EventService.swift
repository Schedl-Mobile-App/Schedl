//
//  EventService.swift
//  Schedoolr
//
//  Created by David Medina on 5/5/25.
//

import FirebaseDatabase

class EventService: EventServiceProtocol {
    
    static let shared = EventService()
    let ref: DatabaseReference
    
    private init() {
        ref = Database.database().reference()
    }
    
    func fetchEvent(eventId: String) async throws -> Event {
        
        // Store a reference to the child node of the events node in the Firebase DB
        let eventRef = ref.child("events").child(eventId)
            
        // getData is a Firebase function that returns a DataSnapshot object
        let snapshot = try await eventRef.getData()
        
        // The DataSnapshot object is returned as an object with key value pairs as Strings
        guard let eventData = snapshot.value as? [String: Any] else {
            throw FirebaseError.failedToFetchEvent
        }
        
        // only create a user object if we receive all parameters from the DB
        if
            let id = eventData["id"] as? String,
            let scheduleId = eventData["scheduleId"] as? String,
            let title = eventData["title"] as? String,
            let eventDate = eventData["eventDate"] as? Double,
            let startTime = eventData["startTime"] as? Double,
            let endTime = eventData["endTime"] as? Double,
            let createdAt = eventData["creationDate"] as? Double {
            
            let event = Event(id: id, scheduleId: scheduleId, title: title, eventDate: eventDate, startTime: startTime, endTime: endTime, creationDate: createdAt)
            return event
            
        } else {
            throw EventServiceError.invalidEventData
        }

    }
    
    func fetchEventsByUserId(userId: String) async throws -> [Event] {
        
        let userRef = ref.child("users").child(userId).child("schedule")
        let userSnapshot = try await userRef.getData()
        
        guard let scheduleId = userSnapshot.value as? String else {
            throw EventServiceError.failedToGetScheduleId
        }
                
        let scheduleEventsRef = ref.child("scheduleEvents").child(scheduleId)
        let snapshot = try await scheduleEventsRef.getData()
        
        guard let data = snapshot.value as? [String: Any] else {
            throw EventServiceError.invalidEventData
        }
        
        let eventIds = Array(data.keys)
        
        return try await fetchEvents(eventIds: eventIds)
    }
    
    func fetchEventsByScheduleId(scheduleId: String) async throws -> [Event] {
        
        let scheduleEventsRef = ref.child("scheduleEvents").child(scheduleId)
        let snapshot = try await scheduleEventsRef.getData()
        
        guard let data = snapshot.value as? [String: Any] else {
            throw EventServiceError.invalidEventData
        }
        
        let eventIds = Array(data.keys)
        
        return try await fetchEvents(eventIds: eventIds)
    }
    
    func fetchEvents(eventIds: [String]) async throws -> [Event] {
        
        var events: [Event] = []
        
        if eventIds.isEmpty {
            return events
        } else {
            do {
                try await withThrowingTaskGroup(of: Event.self) { group in
                    for id in eventIds {
                        group.addTask {
                            try await self.fetchEvent(eventId: id)
                        }
                    }
                    
                    for try await event in group {
                        events.append(event)
                    }
                }
                
                return events
            } catch {
                throw EventServiceError.failedToFetchEvents
            }
        }
    }
    
    func createEvent(scheduleId: String, userId: String, title: String, eventDate: Double, startTime: Double, endTime: Double) async throws -> Event {
        
        let id = ref.child("events").childByAutoId().key ?? UUID().uuidString
        let createdAt = Date().timeIntervalSince1970

        let eventObj = Event(id: id, scheduleId: scheduleId, title: title, eventDate: eventDate, startTime: startTime, endTime: endTime, creationDate: createdAt)
        
        let encoder = JSONEncoder()
        do {
            // Encode the Schedule object into JSON data
            let jsonData = try encoder.encode(eventObj)
            
            // Convert JSON data to a dictionary
            guard let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                throw EventServiceError.eventDataSerializationFailed
            }
            let updates: [String: Any] = [
                "/events/\(id)": jsonDictionary,
                "/scheduleEvents/\(scheduleId)/\(id)" : true
            ]
            
            // Perform atomic update
            try await ref.updateChildValues(updates)
            return eventObj
            
        } catch {
            throw FirebaseError.failedToCreateEvent
        }
    }
    
    func updateEvent(eventId: String, title: String?, eventDate: Double?, startTime: Double?, endTime: Double?) async throws -> Void {
        
        var updates: [String : Any] = [:]
        
        if let title = title {
            updates["/events/\(eventId)/\("title")"] = title
        }
        if let eventDate = eventDate {
            updates["/events/\(eventId)/\("eventDate")"] = eventDate
        }
        if let startTime = startTime {
            updates["/events/\(eventId)/\("startTime")"] = startTime
        }
        if let endTime = endTime {
            updates["/events/\(eventId)/\("endTime")"] = endTime
        }
        
        if updates.isEmpty {
            return
        }
        
        do {
            try await ref.updateChildValues(updates)
        } catch {
            throw EventServiceError.failedToUpdateEvent
        }
    }
    
    func deleteEvent(eventId: String, scheduleId: String) async throws -> Void {
        
        let eventRef = ref.child("events").child(eventId)
        let scheduleEventsRef = ref.child("scheduleEvents").child(scheduleId).child(eventId)
        
        do {
            try await eventRef.removeValue()
            try await scheduleEventsRef.removeValue()
        } catch {
            throw EventServiceError.failedToDeleteEvent
        }
    }
    
    func deleteScheduleEvents(scheduleId: String) async throws -> Void {
        let eventRef = ref.child("schedules").child(scheduleId).child("eventIds")
        let snapshot = try await eventRef.getData()
        
        guard let eventIdsNode = snapshot.value as? [String: Any] else {
            throw EventServiceError.failedToDeleteAllEvents
        }
        
        let eventIds = Array(eventIdsNode.keys)
        
        await withThrowingTaskGroup(of: Void.self) { group in
            for id in eventIds {
                group.addTask {
                    try await self.deleteEvent(eventId: id, scheduleId: scheduleId)
                }
            }
        }
    }
    
    func fetchCurrentEvents(currentDay: TimeInterval, userId: String) async throws -> [Event] {
        
        let events = try await fetchEventsByUserId(userId: userId)
        
        return events.filter { $0.eventDate >= currentDay }
    }
}
