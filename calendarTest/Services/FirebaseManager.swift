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
    
    func fetchData(completion: @escaping ([String: Any]?) -> Void) {
            ref.observeSingleEvent(of: .value) { snapshot in
                if let value = snapshot.value as? [String: Any] {
                    completion(value)
                } else {
                    completion(nil)
                }
            } withCancel: { error in
                print("Error fetching data: \(error.localizedDescription)")
                completion(nil)
            }
        }
    
    func fetchUser(completion: @escaping (User?, Error?) -> Void) {
        ref.child("users").observeSingleEvent(of: .value) { (snapshot) in

            guard let userData = snapshot.value as? [String: Any] else {
                completion(nil, NSError(domain: "UserErrorDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "Invalid Data"]))
                return
            }

            let user = User(
                userId: userData["userid"] as? String ?? "",
                username: userData["username"] as? String ?? "",
                password: userData["password"] as? String ?? ""
            )
            
            completion(user, nil)
        }
    }
    
}
