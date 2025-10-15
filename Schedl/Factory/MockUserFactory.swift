//
//  MockUserFactory.swift
//  Schedl
//
//  Created by David Medina on 10/9/25.
//

import Foundation

enum MockUserFactory {
    static func createUser(
        name: String = "Alex Doe",
    ) -> User {
        User(id: UUID().uuidString, email: "\(name.lowercased().replacingOccurrences(of: " ", with: "."))@example.com", displayName: "Alex Doe", username: "alexdoee", profileImage:
                "https://firebasestorage.googleapis.com:443/v0/b/penny-b4f01.firebasestorage.app/o/users%2FUNbmCWPIRFM8c9tmNz2gBNlNHGz1%2FprofileImages%2Fprofile_81EDEAE0-5EA9-4195-ABE1-76D168C25222.jpg?alt=media&token=df052ad0-5a78-4c57-9120-fc05284914ea", numOfEvents: 2, numOfFriends: 5, numOfPosts: 10)
    }
    
    static func createUsers(count: Int) -> [User] {
        (0..<count).map { _ in createUser(name: "Random User") }
    }
}
