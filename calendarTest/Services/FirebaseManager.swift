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
    
    func fetchUser(userId: String, completion: @escaping (User?, Error?) -> Void) {
        ref.child("users").child(userId).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in

            guard let userData = snapshot.value as? [String: Any] else {
                completion(nil, NSError(domain: "UserErrorDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "Invalid Data"]))
                return
            }
            
            let scheduleIds = userData["schedules"] as? [String] ?? []
            var schedules: [Schedule] = []
            let dispatchGroup = DispatchGroup()

            for scheduleId in scheduleIds {
                dispatchGroup.enter()  // Enter the group for each event fetch
                self.fetchSchedule(scheduleId: scheduleId) { schedule, error in
                    if let schedule = schedule {
                        schedules.append(schedule)  // Append fetched event to the array
                    }
                    dispatchGroup.leave()  // Leave the group when done
                }
            }
            
            let user = User(
                userId: userData["userid"] as? String ?? "",
                username: userData["username"] as? String ?? "",
                email: userData["email"] as? String ?? "",
                schedules: schedules
            )
            
            completion(user, nil)
        } 
    }
    
    func saveUser(userData: User, completion: @escaping (Error?) -> Void) {
        
        let userDict: [String: Any] = [
            "email": userData.email,
            "username": userData.username
        ]
        
        print("User data to be saved: \(userDict)")
        
        ref.child("users").child(userData.userId).setValue(userDict) { error, _ in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func fetchSchedule(scheduleId: String, completion: @escaping (Schedule?, Error?) -> Void) {
        ref.child("schedules").child(scheduleId).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in

            guard let scheduleData = snapshot.value as? [String: Any] else {
                completion(nil, NSError(domain: "ScheduleErrorDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "Schedule Not Found"]))
                return
            }
            
            let eventIds = scheduleData["scheduleEvents"] as? [String] ?? []
            var events: [Event] = []
            let dispatchGroup = DispatchGroup()

            for eventId in eventIds {
                dispatchGroup.enter()  // Enter the group for each event fetch
                self.fetchEvent(scheduleId: scheduleId, eventId: eventId) { event, error in
                    if let event = event {
                        events.append(event)  // Append fetched event to the array
                    }
                    dispatchGroup.leave()  // Leave the group when done
                }
            }

            let schedule = Schedule(
                scheduleId: scheduleId,
                belongToUserId: scheduleData["belongToScheduleId"] as? String ?? "",
                scheduleEvents: events,
                title: scheduleData["title"] as? String ?? ""
            )
            
            completion(schedule, nil)
        }
    }
    
    func fetchEvent(scheduleId: String, eventId:  String, completion: @escaping (Event?, Error?) -> Void) {
        ref.child("events").child(eventId).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in

            guard let eventData = snapshot.value as? [String: Any] else {
                completion(nil, NSError(domain: "EventErrorDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "Event Not Found"]))
                return
            }

            let event = Event(
                eventId: eventId,
                belongToScheduleId: scheduleId,
                title: eventData["title"] as? String ?? "",
                description: eventData["description"] as? String ?? ""
            )
            
            completion(event, nil)
        }
    }
    
}
