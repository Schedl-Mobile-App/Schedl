//
//  FirebaseManager.swift
//  calendarTest
//
//  Created by David Medina on 9/23/24.
//

import Foundation
import Firebase
import FirebaseDatabase

class FirebaseManager {
    static let shared = FirebaseManager()
    let ref: DatabaseReference

    private init() {
        ref = Database.database().reference()
    }
    
    func fetchUserAsync(id: String) async throws -> User {
        
        // Store a reference to the child node of the users node in the Firebase DB
        let userRef = ref.child("users").child(id)
        
        // getData is a Firebase function that returns a DataSnapshot object
        let snapshot = try await userRef.getData()
        
        // The DataSnapshot object is returned as an object with key value pairs as Strings
        guard let userData = snapshot.value as? [String: Any] else {
            throw FirebaseError.failedToFetchUser
        }
        
        // only create a user object if we receive all parameters from the DB
        if
            let id = userData["id"] as? String,
            let username = userData["username"] as? String,
            let email = userData["email"] as? String,
            let schedules = userData["scheduleIds"] as? [String],
            let createdAt = userData["creationDate"] as? Double {
            
            let user = User(id: id, username: username, email: email, schedules: schedules, creationDate: createdAt)
            return user
            
        } else {
            throw UserError.invalidData
        }
    }
    
    func saveNewUserAsync(userData: User) async throws -> Void {
        
        let id = userData.id
        let userRef = ref.child("users").child(id)
        
        let encoder = JSONEncoder()
        do {
            // Encode the User object into JSON data
            let jsonData = try encoder.encode(userData)
            
            // Convert JSON data to a dictionary
            guard let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                throw UserError.serializationFailed
            }
            
            // Given that we have valid JSON dictionary, let's write to the DB
            try await userRef.setValue(jsonDictionary)
            return
            
        } catch {
            throw FirebaseError.failedToCreateUser
        }
        
    }
    
    func fetchScheduleAsync(id: String) async throws -> Schedule {
        
        // Store a reference to the child node of the schedules node in the Firebase DB
        let scheduleRef = ref.child("schedules").child(id)
            
        // getData is a Firebase function that returns a DataSnapshot object
        let snapshot = try await scheduleRef.getData()
        
        // The DataSnapshot object is returned as an object with key value pairs as Strings
        guard let scheduleData = snapshot.value as? [String: Any] else {
            throw FirebaseError.failedToFetchSchedule
        }
        
        // only create a user object if we receive all parameters from the DB
        if
            let id = scheduleData["id"] as? String,
            let userId = scheduleData["userId"] as? String,
            let events = scheduleData["eventIds"] as? [String],
            let title = scheduleData["title"] as? String,
            let createdAt = scheduleData["creationDate"] as? Double {
            
            let schedule = Schedule(id: id, userId: userId, events: events, title: title, creationDate: createdAt)
            return schedule
            
        } else {
            throw ScheduleError.invalidScheduleData
        }
        
    }
    
    func createNewScheduleAsync(scheduleData: Schedule) async throws -> Schedule {
        
        var copyScheduleData = scheduleData
        let id = ref.child("schedules").childByAutoId().key ?? UUID().uuidString
        let createdAt = Date().timeIntervalSince1970
        copyScheduleData.id = id
        copyScheduleData.creationDate = createdAt
        
        let scheduleRef = ref.child("schedules").child(id)
        
        let encoder = JSONEncoder()
        do {
            // Encode the Schedule object into JSON data
            let jsonData = try encoder.encode(copyScheduleData)
            
            // Convert JSON data to a dictionary
            guard let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                throw ScheduleError.scheduleDataSerializationFailed
            }
            
            // Given that we have valid JSON dictionary, let's write to the DB
            try await scheduleRef.setValue(jsonDictionary)
            return copyScheduleData
            
        } catch {
            throw FirebaseError.failedToCreateSchedule
        }
        
    }
    
    func fetchEventAsync(id: String) async throws -> Event {
        
        // Store a reference to the child node of the events node in the Firebase DB
        let eventRef = ref.child("events").child(id)
            
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
            let description = eventData["description"] as? String,
            let startTime = eventData["startDate"] as? Double,
            let endTime = eventData["endDate"] as? Double,
            let createdAt = eventData["creationDate"] as? Double {
            
            let event = Event(id: id, scheduleId: scheduleId, title: title, description: description, startTime: startTime, endTime: endTime, creationDate: createdAt)
            return event
            
        } else {
            throw EventError.invalidEventData
        }

    }
    
    func fetchEventsForScheduleAsync(eventIDs: [String]) async throws -> [Event] {
        var events: [Event] = []
        
        // Use TaskGroup for concurrency
        try await withThrowingTaskGroup(of: Event.self) { group in
            for id in eventIDs {
                group.addTask {
                    try await self.fetchEventAsync(id: id)
                }
            }
            
            // Collect all results
            for try await event in group {
                events.append(event)
            }
        }
        
        return events
    }
    
}
