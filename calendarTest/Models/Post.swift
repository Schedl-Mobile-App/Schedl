//
//  Post.swift
//  calendarTest
//
//  Created by David Medina on 12/9/24.
//

//@State private var eventTitle: String = "Halloween"
//    @State private var eventSubtitle: String = "October 31st, 9:00 PM"
//    @State private var eventDescription: String = "BOOOOOOM, this event is gonna go CRAZY"
//    @State private var invitedUsers: [String] = ["User 1", "User 2", "User 3"]
//    @State private var eventPhotos: [String] = ["pic1", "pic2", "pic3"] // Local image names
//    @State private var comments: [Comment] = [
//        Comment(user: "User 1", commentText: "Great event!"),
//        Comment(user: "User 2", commentText: "Can't wait!"),
//        Comment(user: "User 3", commentText: "Looking forward to it!")
//    ]
//    @State private var permission: Bool = true // change to swap edit permissions
//    @State private var showInvitedUsers: Bool = false
//    @State private var showComments: Bool = false

import Foundation

struct Post: Codable, Identifiable {
    var id: String
    var title: String
    var description: String
    var eventPhotos: [String]
    var comments: [Comment]
    var permission: Bool // whether a user has edit permission
    var taggedUsers: [String] // store the IDs of tagged users
    var eventLocation: String
}
