//
//  ScheduleService.swift
//  Schedoolr
//
//  Created by David Medina on 5/5/25.
//

import FirebaseDatabase
import FirebaseCore

class ScheduleService: ScheduleServiceProtocol {

    static let shared = ScheduleService()
    let ref: DatabaseReference
    
    private init() {
        ref = Database.database().reference()
    }
    
    func fetchSchedule(userId: String) async throws -> Schedule {
        
        let userScheduleRef = ref.child("users").child(userId).child("schedule")
        let userSnapshot = try await userScheduleRef.getData()
        
        guard let scheduleId = userSnapshot.value as? String else {
            throw ScheduleServiceError.failedToFindScheduleId
        }
        
        // Store a reference to the child node of the schedules node in the Firebase DB
        let scheduleRef = ref.child("schedules").child(scheduleId)
            
        // getData is a Firebase function that returns a DataSnapshot object
        let scheduleSnapshot = try await scheduleRef.getData()
        
        // The DataSnapshot object is returned as an object with key value pairs as Strings
        guard let scheduleData = scheduleSnapshot.value as? [String: Any] else {
            throw FirebaseError.failedToFetchSchedule
        }
        
        if
            let id = scheduleData["id"] as? String,
            let userId = scheduleData["userId"] as? String,
            let title = scheduleData["title"] as? String,
            let createdAt = scheduleData["creationDate"] as? Double {
            
            let schedule = Schedule(id: id, userId: userId, title: title, creationDate: createdAt)
            return schedule
            
        } else {
            throw ScheduleServiceError.invalidScheduleData
        }
        
    }
    
    func fetchScheduleId(userId: String) async throws -> String {
        let userRef = ref.child("users").child(userId).child("schedule")
        let snapshot = try await userRef.getData()
        
        guard let scheduleId = snapshot.value as? String else {
            throw ScheduleServiceError.failedToFetchScheduleFromUser
        }
        
        return scheduleId
    }
    
    func createSchedule(userId: String, title: String) async throws -> Schedule {
        
        let id = ref.child("schedules").childByAutoId().key ?? UUID().uuidString
        let createdAt = Date().timeIntervalSince1970
        
        let scheduleObj = Schedule(id: id, userId: userId, title: title, creationDate: createdAt)
        
        let encoder = JSONEncoder()
        do {
            // Encode the Schedule object into JSON data
            let jsonData = try encoder.encode(scheduleObj)
            
            // Convert JSON data to a dictionary
            guard let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                throw ScheduleServiceError.scheduleDataSerializationFailed
            }
            
            let updates: [String: Any] = [
                "/schedules/\(id)" : jsonDictionary,
                "/users/\(userId)/schedule" : id
            ]
            
            try await ref.updateChildValues(updates)
            return scheduleObj
        } catch {
            throw FirebaseError.failedToCreateSchedule
        }
    }
    
    func updateSchedule(scheduleId: String, title: String) async throws -> Void {
        let scheduleRef = ref.child("schedules").child(scheduleId).child("title")
        
        do {
            try await scheduleRef.setValue(title)
        } catch {
            throw ScheduleServiceError.failedToUpdateSchedule
        }
    }
    
    func deleteSchedule(scheduleId: String, userId: String) async throws -> Void {
        let scheduleRef = ref.child("schedules").child(scheduleId)
        let userRef = ref.child("users").child(userId).child("schedule")
        
        do {
            try await scheduleRef.removeValue()
            try await userRef.removeValue()
        } catch {
            throw ScheduleServiceError.failedToDeleteSchedule
        }
    }
    
    func observeScheduleChanges(scheduleId: String, completion: @escaping ([String]) -> Void) -> DatabaseHandle {
        let eventsRef = ref.child("scheduleEvents").child(scheduleId)
        return eventsRef.observe(.value, with: { snapshot in
            Task {
                do {
                    let snapshot = try await eventsRef.getData()
                    
                    print(snapshot.value ?? "snapshot value is nil")
                    
                    guard let scheduleEventsNode = snapshot.value as? [String : Any] else {
                        throw ScheduleServiceError.failedToFetchScheduleEvents
                    }
                    
                    let eventIds = Array(scheduleEventsNode.keys)
                    
                    completion(eventIds)
                } catch {
                    return
                }
            }
        })
    }
    
    func removeScheduleObserver(handle: DatabaseHandle, scheduleId: String) {
        let eventsRef = ref.child("scheduleEvents").child(scheduleId)
        eventsRef.removeObserver(withHandle: handle)
    }
}
