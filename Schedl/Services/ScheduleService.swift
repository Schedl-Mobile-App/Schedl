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
    
    func fetchAllSchedules(userId: String) async throws -> [Schedule] {
        let userScheduleRef = ref.child("users").child(userId).child("scheduleIds")
        let userSnapshot = try await userScheduleRef.getData()
        
        guard let scheduleIdsDict = userSnapshot.value as? [String: Any] else {
            return []
        }
        
        let scheduleIds = Array(scheduleIdsDict.keys)
        
        var schedules: [Schedule] = []
        
        try await withThrowingTaskGroup(of: Schedule.self) { group in
            for id in scheduleIds {
                group.addTask {
                    try await self.fetchSchedule(scheduleId: id)
                }
            }
            
            for try await schedule in group {
                schedules.append(schedule)
            }
        }
        
        return schedules
    }
    
    func fetchSchedule(scheduleId: String) async throws -> Schedule {
        
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
        let userRef = ref.child("users").child(userId).child("scheduleIds")
        let snapshot = try await userRef.getData()
        
        guard let scheduleIds = snapshot.value as? [String: Any] else {
            throw ScheduleServiceError.failedToFetchScheduleFromUser
        }
        
        return scheduleIds.keys.first!
    }
    
    func fetchScheduleIds(userIds: [String]) async throws -> [String] {
        
        var scheduleIds: [String] = []
        
        try await withThrowingTaskGroup(of: String.self) { group in
            for id in userIds {
                group.addTask {
                    try await self.fetchScheduleId(userId: id)
                }
            }
            
            for try await scheduleId in group {
                scheduleIds.append(scheduleId)
            }
        }
        
        return scheduleIds
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
                "/users/\(userId)/scheduleIds/\(id)" : true
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
        let userRef = ref.child("users").child(userId).child("scheduleIds").child(scheduleId)
        
        do {
            try await scheduleRef.removeValue()
            try await userRef.removeValue()
        } catch {
            throw ScheduleServiceError.failedToDeleteSchedule
        }
    }
    
    func createBlendSchedule(ownerId: String, title: String, invitedUsers: [String], scheduleIds: [String], colors: [String: String]) async throws -> Void {
        let blendId = ref.child("blends").childByAutoId().key ?? UUID().uuidString
        
        var invitedUsersDict: [String: Bool] = [:]
        for id in invitedUsers {
            invitedUsersDict[id] = true
        }
        
        var scheduleDict: [String: Bool] = [:]
        for id in scheduleIds {
            scheduleDict[id] = true
        }
        
        let blendDict: [String: Any] = [
            "id": blendId,
            "ownerId": ownerId,
            "title": title,
            "scheduleIds": scheduleDict,
            "invitedUsers": invitedUsersDict,
            "blendColors": colors,
        ]
        
        do {
            
            var updates: [String: Any] = [
                "/blends/\(blendId)" : blendDict,
                "/users/\(ownerId)/blendIds/\(blendId)": true,
            ]
            
            for id in invitedUsers {
                updates["/users/\(id)/blendIds/\(blendId)"] = true
            }
            
            try await ref.updateChildValues(updates)
        } catch {
            throw FirebaseError.failedToCreateSchedule
        }
    }
    
    func fetchAllBlendSchedules(userId: String) async throws -> [Blend] {
        
        var blends: [Blend] = []
        
        let userRef = ref.child("users").child(userId).child("blendIds")
        let snapshot = try await userRef.getData()
        
        guard let blendDict = snapshot.value as? [String: Any] else {
            return blends
        }
        
        let blendIds = Array(blendDict.keys)
        
        try await withThrowingTaskGroup(of: Blend.self) { group in
            for id in blendIds {
                group.addTask { [self] in
                    try await fetchBlendSchedule(blendId: id)
                }
            }
            for try await blend in group {
                blends.append(blend)
            }
        }
        return blends
    }
    
    func fetchBlendSchedule(blendId: String) async throws -> Blend {
        let blendRef = ref.child("blends").child(blendId)
        let snapshot = try await blendRef.getData()
        
        guard let blendDict = snapshot.value as? [String: Any] else {
            throw ScheduleServiceError.failedToFetchScheduleEvents
        }
        
        if let blendId = blendDict["id"] as? String,
           let title = blendDict["title"] as? String,
           let invitedUsers = blendDict["invitedUsers"] as? [String: Bool],
           let scheduleIds = blendDict["scheduleIds"] as? [String: Bool],
           let colors = blendDict["blendColors"] as? [String: String] {
            
            return Blend(id: blendId, title: title, invitedUsers: Array(invitedUsers.keys), scheduleIds: Array(scheduleIds.keys), colors: colors)
        } else {
            throw ScheduleServiceError.failedToFetchScheduleEvents
        }
    }
    
    func observeAddedEvents(scheduleId: String, completion: @escaping (String) -> Void) -> DatabaseHandle {
        let eventsRef = ref.child("scheduleEvents").child(scheduleId)
        
        return eventsRef.observe(.childAdded) { snapshot in
            let eventId = snapshot.key
            completion(eventId)
        }
    }
    
    func observeRemovedEvents(scheduleId: String, completion: @escaping (String) -> Void) -> DatabaseHandle {
        let eventsRef = ref.child("scheduleEvents").child(scheduleId)
        
        return eventsRef.observe(.childRemoved) { snapshot in
            let eventId = snapshot.key
            completion(eventId)
        }
    }
    
    func observeUpdatedEvents(scheduleId: String, completion: @escaping (String) -> Void) -> DatabaseHandle {
        let eventsRef = ref.child("scheduleEvents").child(scheduleId)
        
        return eventsRef.observe(.childChanged) { snapshot in
            let eventId = snapshot.key
            completion(eventId)
        }
    }
    
    func removeScheduleObserver(handle: DatabaseHandle, scheduleId: String) {
        let eventsRef = ref.child("scheduleEvents").child(scheduleId)
        eventsRef.removeObserver(withHandle: handle)
    }
}
