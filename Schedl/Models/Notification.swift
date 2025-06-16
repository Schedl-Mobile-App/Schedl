//
//  Notification.swift
//  Schedl
//
//  Created by David Medina on 6/13/25.
//

import Foundation

struct Notification: Identifiable, Codable, Equatable {
    static func == (lhs: Notification, rhs: Notification) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: String
    var type: NotificationType
    var notificationPayload: NotificationPayload
    var creationDate: TimeInterval
}
