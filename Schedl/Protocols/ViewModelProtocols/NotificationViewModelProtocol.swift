//
//  NotificationViewModelProtocol.swift
//  Schedoolr
//
//  Created by David Medina on 5/7/25.
//

protocol NotificationViewModelProtocol {
    var currentUser: User { get set }
    var friendRequests: [FriendRequest] { get set }
}
