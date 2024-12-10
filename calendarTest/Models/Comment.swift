//
//  Comment.swift
//  calendarTest
//
//  Created by David Medina on 12/9/24.
//

import Foundation

struct Comment: Codable, Identifiable {
    var id: String
    var authorId: String
    var text: String
    var createdAt: TimeInterval
    var updatedAt: TimeInterval
}
