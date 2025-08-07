//
//  EventService.swift
//  Schedoolr
//
//  Created by David Medina on 5/5/25.
//

import FirebaseDatabase

struct Availability {
    let timeSlot: String
    let isAvailable: Bool
}

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
        
        let userRef = ref.child("users").child(userId).child("scheduleIds")
        let userSnapshot = try await userRef.getData()
        
        guard let scheduleIds = userSnapshot.value as? [String: Any] else {
            // must mean that the user has no schedules
            return []
        }
        
        guard let scheduleId = scheduleIds.keys.first else {
            return []
        }
                
        let scheduleEventsRef = ref.child("scheduleEvents").child(scheduleId)
        let snapshot = try await scheduleEventsRef.getData()
        
        guard let data = snapshot.value as? [String: Any] else {
            return []
        }
        
        let eventIds = Array(data.keys)
        
        return try await fetchEvents(eventIds: eventIds)
    }
    
    func fetchEventsByScheduleId(scheduleId: String) async throws -> [Event] {
        
        let scheduleEventsRef = ref.child("scheduleEvents").child(scheduleId)
        let snapshot = try await scheduleEventsRef.getData()
        
        guard let data = snapshot.value as? [String: Any] else {
            return []
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
    
    func createEvent(userId: String, title: String, startDate: Double, startTime: Double, endTime: Double, location: MTPlacemark, color: String, notes: String, endDate: Double? = nil, repeatedDays: [String]? = nil) async throws -> String {
        
        guard let id = ref.child("events").childByAutoId().key else { throw EventServiceError.failedToCreateEvent }
        let createdAt = Date().timeIntervalSince1970
        
        let scheduleRef = ref.child("users").child(userId).child("scheduleIds")
        let snapshot = try await scheduleRef.getData()
        
        guard let scheduleIds = snapshot.value as? [String: Any] else { throw EventServiceError.failedToCreateEvent }
        
        let scheduleId = scheduleIds.keys.first!
        
        let eventObj = Event(id: id, userId: userId, scheduleId: scheduleId, title: title, startDate: startDate, startTime: startTime, endTime: endTime, creationDate: createdAt, locationName: location.name, locationAddress: location.address, latitude: location.latitude, longitude: location.longitude, taggedUsers: [], color: color, notes: notes, endDate: endDate, repeatingDays: repeatedDays)
                
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(eventObj)
            print(jsonData)
            
            guard let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                throw EventServiceError.eventDataSerializationFailed
            }
            
            let dict = [
                "last_modified": ServerValue.timestamp()
            ]
            
            var updates: [String: Any] = [
                "/events/\(id)": jsonDictionary,
                "/schedules/\(scheduleId)/eventIds/\(id)" : true,
                "/scheduleEvents/\(scheduleId)/\(id)" : dict,
            ]
            
            let normalizedStartTime = floor(startTime / 900.0) * 900.0
            
            for i in stride(from: normalizedStartTime, to: endTime, by: 900) {
                // always want to round the the startTime down to the nearest multiple of 15 or 0
                let timeStamp: Double = floor(i / 900.0) * 900.0
                updates["/userAvailability/\(userId)/\(Int(startDate))_\(Int(timeStamp))"] = true
            }
            
            print(updates)
            try await ref.updateChildValues(updates)
            
            return id
            
        } catch {
            throw FirebaseError.failedToCreateEvent
        }
    }
    
    func checkIndividualAvailability(userId: String, startQuery: String, endQuery: String) async throws -> FriendAvailability {
        
        // since our database writes user availability in ascending order, we can check if this query
        // returns the start and anything in between the end time (inclusive)
        let availabilityRef = ref.child("userAvailability").child(userId).queryOrderedByKey()
            .queryStarting(atValue: startQuery)
            .queryEnding(atValue: endQuery)
        
        let snapshot = try await availabilityRef.getData()
        
        if snapshot.exists() {
            return FriendAvailability(available: false, userId: userId)
        }
        
        return FriendAvailability(available: true, userId: userId)
    }
    
    func checkAvailability(userIds: [String], eventDate: Int, startTime: Int, endTime: Int) async throws -> [FriendAvailability] {
        
        let startQuery = "\(eventDate)_\(startTime)"
        let endQuery = "\(eventDate)_\(endTime)"
        var availabilityList: [FriendAvailability] = []
        
        try await withThrowingTaskGroup(of: FriendAvailability.self) { group in
            for id in userIds {
                group.addTask {
                    try await self.checkIndividualAvailability(userId: id, startQuery: startQuery, endQuery: endQuery)
                }
                
                for try await availability in group {
                    availabilityList.append(availability)
                }
            }
        }
        
        return availabilityList
    }
    
    func updateEvent(eventId: String, scheduleIds: [String], title: String?, eventDate: Double?, startTime: Double?, endTime: Double?, location: MTPlacemark?, repeatedDays: [String]?, color: String?, notes: String?) async throws {
        
        var updates: [String : Any] = [:]
        
        if let title = title {
            updates["/events/\(eventId)/title"] = title
        }
        if let eventDate = eventDate {
            updates["/events/\(eventId)/eventDate"] = eventDate
        }
        if let startTime = startTime {
            updates["/events/\(eventId)/startTime"] = startTime
        }
        if let endTime = endTime {
            updates["/events/\(eventId)/endTime"] = endTime
        }
        if let location = location {
            updates["/events/\(eventId)/locationName"] = location.name
            updates["/events/\(eventId)/locationAddress"] = location.address
            updates["/events/\(eventId)/latitude"] = location.latitude
            updates["/events/\(eventId)/longitude"] = location.longitude
        }
        if let repeatedDays = repeatedDays {
            updates["/events/\(eventId)/repeatingDays"] = repeatedDays
        }
        if let color = color {
            updates["/events/\(eventId)/color"] = color
        }
        if let notes = notes {
            updates["/events/\(eventId)/notes"] = notes
        }
        
        if updates.isEmpty {
            return
        }
        
        for id in scheduleIds {
            updates["scheduleEvents/\(id)/\(eventId)/last_modified"] = ServerValue.timestamp()
        }
        
        do {
            try await ref.updateChildValues(updates)
        } catch {
            throw EventServiceError.failedToUpdateEvent
        }
    }
    
    func deleteEvent(eventId: String, userId: String) async throws -> Void {
        
        let userRef = ref.child("users").child(userId).child("schedules")
        let userSnapshot = try await userRef.getData()
        
        guard let scheduleIds = userSnapshot.value as? [String: Any] else {
            throw EventServiceError.failedToGetScheduleId
        }
        
        let scheduleId = scheduleIds.keys.first!
        
        // we need to remove any event invites that the owner of the event has sent that might still be pending
        let eventInviteRef = ref.child("eventInvites").child(userId)
        let snapshot = try await eventInviteRef.getData()
        
        var updates: [String: Any] = [
            "/events/\(eventId)": NSNull(),
            "/scheduleEvents/\(scheduleId)/\(eventId)": NSNull(),
            "/schedules/\(scheduleId)!/eventIds/\(eventId)": NSNull()
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

