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
}
