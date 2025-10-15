//
//  ScheduleService.swift
//  Schedoolr
//
//  Created by David Medina on 5/5/25.
//

import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestore

class ScheduleService: ScheduleServiceProtocol {
    
    static let shared = ScheduleService()
    let fs: Firestore
    
    private init() {
        fs = Firestore.firestore()
    }
        
    func fetchAllSchedules(userId: String) async throws -> [Schedule] {
        do {
            let scheduleRef = fs.collection("schedules").whereField("ownerId", isEqualTo: userId)
            let snapshot = try await scheduleRef.getDocuments()
            
            
            // 3. Use a compactMap with the built-in Codable support.
            //    The `data(as:)` method attempts to decode each document into a Schedule object.
            //    `compactMap` will automatically discard any documents that fail to decode.
            let schedules = try snapshot.documents.compactMap { document in
                try document.data(as: Schedule.self)
            }
            
            return schedules
        } catch {
            throw ScheduleServiceError.failedToFetchAllSchedules
        }
    }
    
    func fetchSchedule(scheduleId: String) async throws -> Schedule {
        do {
            let schedule = try await fs.collection("schedules").document(scheduleId).getDocument(as: Schedule.self)
            return schedule
        } catch {
            throw ScheduleServiceError.failedToFetchSchedule
        }
    }
    
    func fetchScheduleId(userId: String) async throws -> String {
        do {
            let snapshot = try await fs.collection("schedules").whereField("ownerId", isEqualTo: userId).limit(to: 1).getDocuments()
            let scheduleIds = snapshot.documents.compactMap { document in
                let dict = document.data()
                let id = dict["id"] as! String
                return id
            }
            
            guard scheduleIds.isEmpty == false else {
                throw ScheduleServiceError.scheduleDataSerializationFailed
            }
            
            return scheduleIds.first!
        }
    }
    
    func createSchedule(userId: String, title: String) async throws -> Schedule {
        let scheduleRef = fs.collection("schedules").document()
        
        let scheduleObj = Schedule(id: scheduleRef.documentID, ownerId: userId, title: title, createdAt: Date.now)
        do {
            try scheduleRef.setData(from: scheduleObj)
            
            return scheduleObj
        } catch {
            throw FirebaseError.failedToCreateSchedule
        }
    }
    
    func updateSchedule(scheduleId: String, title: String) async throws -> Void {
        let scheduleDoc = fs.collection("schedules").document(scheduleId)
        do {
            try await scheduleDoc.updateData([
                "title": title
            ])
        } catch {
            throw ScheduleServiceError.failedToUpdateSchedule
        }
    }
    
    func deleteSchedule(scheduleId: String, userId: String) async throws -> Void {
        let scheduleDoc = fs.collection("schedules").document(scheduleId)
        
        do {
            try await scheduleDoc.delete()
        } catch {
            throw ScheduleServiceError.failedToDeleteSchedule
        }
    }
    
    // MARK: - Firestore: Blends
    
    func createBlendSchedule(ownerId: String, scheduleId: String, title: String, invitedUsers: [InvitedUser], colors: [UserMappedBlendColor]) async throws -> Void {
        
        do {
            let blendRef = fs.collection("blends").document()
            
            let blend = Blend(
                id: blendRef.documentID,
                ownerId: ownerId,
                title: title,
                invitedUsers: invitedUsers,
                scheduleIds: [scheduleId],
                colors: colors
            )
            
            try blendRef.setData(from: blend)
        } catch {
            throw FirebaseError.failedToCreateSchedule
        }
    }
    
    func fetchAllBlendSchedules(userId: String) async throws -> [Blend] {
        do {
            let query = fs.collection("blends").whereField("participants", arrayContains: userId)
            
            let snapshot = try await query.getDocuments()
            let blends = try snapshot.documents.compactMap { document in
                let blend = try document.data(as: Blend.self)
                return blend
            }
            
            return blends
            
        } catch {
            throw ScheduleServiceError.failedToFetchAllBlends
        }
    }
    
    func fetchBlendSchedule(blendId: String) async throws -> Blend? {
        do {
            let query = fs.collection("blends").document(blendId)
            let snapshot = try await query.getDocument()
            guard snapshot.exists else {
                throw ScheduleServiceError.failedToFetchBlend
            }
            
            return try snapshot.data(as: Blend.self)
            
        } catch {
            throw ScheduleServiceError.failedToFetchBlend
        }
    }
    
    // MARK: - Firestore Listeners
    
    // Events: listen to events where scheduleId == scheduleId
    func observeAddedEvents(scheduleId: String, completion: @escaping (String) -> Void) -> ListenerRegistration {
        let query = fs.collection("events").whereField("scheduleId", isEqualTo: scheduleId)
        let listener = query.addSnapshotListener { snapshot, _ in
            guard let snapshot else { return }
            for change in snapshot.documentChanges where change.type == .added {
                completion(change.document.documentID)
            }
        }
        return listener
    }
    
    func observeRemovedEvents(scheduleId: String, completion: @escaping (String) -> Void) -> ListenerRegistration {
        let query = fs.collection("events").whereField("scheduleId", isEqualTo: scheduleId)
        let listener = query.addSnapshotListener { snapshot, _ in
            guard let snapshot else { return }
            for change in snapshot.documentChanges where change.type == .removed {
                completion(change.document.documentID)
            }
        }
        return listener
    }
    
    func observeUpdatedEvents(scheduleId: String, completion: @escaping (String) -> Void) -> ListenerRegistration {
        let query = fs.collection("events").whereField("scheduleId", isEqualTo: scheduleId)
        let listener = query.addSnapshotListener { snapshot, _ in
            guard let snapshot else { return }
            for change in snapshot.documentChanges where change.type == .modified {
                completion(change.document.documentID)
            }
        }
        return listener
    }
    
    func removeScheduleObserver(listener: ListenerRegistration) {
        listener.remove()
    }
    
    // New blends for a user: diff users/{userId}.blendIds map
    func observeCreatedBlend(userId: String, completion: @escaping (String) -> Void) -> ListenerRegistration {
        var previousIds: Set<String> = []
        let listener = fs.collection("users").document(userId).addSnapshotListener { snapshot, _ in
            guard let data = snapshot?.data() else { return }
            let map = data["blendIds"] as? [String: Any] ?? [:]
            let current = Set(map.keys)
            let added = current.subtracting(previousIds)
            previousIds = current
            for id in added {
                completion(id)
            }
        }
        return listener
    }
    
    // Blend scheduleIds: diff blends/{blendId}.scheduleIds map
    func observeAddedBlendSchedules(blendId: String, completion: @escaping (String) -> Void) -> ListenerRegistration {
        var previousIds: Set<String> = []
        let listener = fs.collection("blends").document(blendId).addSnapshotListener { snapshot, _ in
            guard let data = snapshot?.data() else { return }
            let map = data["scheduleIds"] as? [String: Any] ?? [:]
            let current = Set(map.keys)
            let added = current.subtracting(previousIds)
            previousIds = current
            for id in added {
                completion(id)
            }
        }
        return listener
    }
    
    func observeRemovedBlendSchedules(blendId: String, completion: @escaping (String) -> Void) -> ListenerRegistration {
        var previousIds: Set<String> = []
        let listener = fs.collection("blends").document(blendId).addSnapshotListener { snapshot, _ in
            guard let data = snapshot?.data() else { return }
            let map = data["scheduleIds"] as? [String: Any] ?? [:]
            let current = Set(map.keys)
            let removed = previousIds.subtracting(current)
            previousIds = current
            for id in removed {
                completion(id)
            }
        }
        return listener
    }
    
    func removeNewBlendObserver(listener: ListenerRegistration) {
        listener.remove()
    }
    
    func removeBlendObserver(listener: ListenerRegistration) {
        listener.remove()
    }
}

