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
        
        let locationName = eventData["locationName"] as? String ?? ""
        let locationAddress = eventData["locationAddress"] as? String ?? ""
        let latitude = eventData["latitude"] as? Double ?? 0.0
        let longitude = eventData["longitude"] as? Double ?? 0.0
        let taggedUsers = eventData["taggedUsers"] as? [String: Any] ?? [:]
        let endDate = eventData["endDate"] as? Double
        let repeatedDays = eventData["repeatingDays"] as? [String]
        let notes = eventData["notes"] as? String ?? ""
        
        let taggedUsersArray = Array(taggedUsers.keys)
        
        // only create a user object if we receive all parameters from the DB
        if
            let id = eventData["id"] as? String,
            let userId = eventData["userId"] as? String,
            let scheduleId = eventData["scheduleId"] as? String,
            let title = eventData["title"] as? String,
            let startDate = eventData["startDate"] as? Double,
            let startTime = eventData["startTime"] as? Double,
            let endTime = eventData["endTime"] as? Double,
            let createdAt = eventData["creationDate"] as? Double,
            let eventColor = eventData["color"] as? String {
            
            let event = Event(id: id, userId: userId, scheduleId: scheduleId, title: title, startDate: startDate, startTime: startTime, endTime: endTime, creationDate: createdAt, locationName: locationName, locationAddress: locationAddress, latitude: latitude, longitude: longitude, taggedUsers: taggedUsersArray, color: eventColor, notes: notes, endDate: endDate, repeatingDays: repeatedDays)
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
    
    func createEvent(scheduleId: String, userId: String, title: String, startDate: Double, startTime: Double, endTime: Double, location: MTPlacemark, color: String, notes: String, endDate: Double? = nil, repeatedDays: [String]? = nil) async throws -> String {
        
        let id = ref.child("events").childByAutoId().key ?? UUID().uuidString
        let createdAt = Date().timeIntervalSince1970
        
        let eventObj = Event(id: id, userId: userId, scheduleId: scheduleId, title: title, startDate: startDate, startTime: startTime, endTime: endTime, creationDate: createdAt, locationName: location.name, locationAddress: location.address, latitude: location.latitude, longitude: location.longitude, taggedUsers: [], color: color, notes: notes, endDate: endDate, repeatingDays: repeatedDays)
                
        let encoder = JSONEncoder()
        do {
            print("i'm making it here at least")
            // Encode the Schedule object into JSON data
            let jsonData = try encoder.encode(eventObj)
            
            // Convert JSON data to a dictionary
            guard let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                print("Error serialzing event object")
                throw EventServiceError.eventDataSerializationFailed
            }
            
            // this is the update for the user who created the event
            let updates: [String: Any] = [
                "/events/\(id)": jsonDictionary,
                "/schedules/\(scheduleId)/eventIds/\(id)" : true,
                "/scheduleEvents/\(scheduleId)/\(id)" : true,
            ]
            
            // Perform atomic update
            try await ref.updateChildValues(updates)
            
            return id
            
        } catch {
            print("Error creating event")
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
    
    func deleteEvent(eventId: String, scheduleId: String, userId: String) async throws -> Void {
        
        // we need to remove any event invites that the owner of the event has sent that might still be pending
        let eventInviteRef = ref.child("eventInvites").child(userId)
        let snapshot = try await eventInviteRef.getData()
        
        var updates: [String: Any] = [
            "/events/\(eventId)": NSNull(),
            "/scheduleEvents/\(scheduleId)/\(eventId)": NSNull(),
            "/schedules/\(scheduleId)/eventIds/\(eventId)": NSNull()
        ]
        
        // this might return an array of all the invites the current user has sent out
        // we will need to iterate over each one and check what notifications this particular user has received
        let invitesDict = snapshot.value as? [String: Any] ?? [:]
        
        for (id, _) in invitesDict {
            let notificationsRef = ref.child("notifications").child(id).child(eventId)
            
            // fetch data and check whether we received a non-null value
            let notificationSnapshot = try await notificationsRef.getData()
            if notificationSnapshot.exists() {
                updates["/notifications/\(id)/\(eventId)"] = NSNull()
                updates["/eventInvites/\(userId)/\(id)"] = NSNull()
            }
        }
        
        do {
            try await ref.updateChildValues(updates)
        } catch {
            throw EventServiceError.failedToDeleteEvent
        }
    }
}
