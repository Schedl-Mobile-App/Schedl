//
//  Schedule.swift
//  calendarTest
//
//  Created by David Medina on 9/29/24.
//

import Foundation

struct Schedule: Codable, Identifiable {
    var id: String
    var ownerId: String
    var title: String
    var createdAt: Date
    
    init(id: String, ownerId: String, title: String, createdAt: Date) {
        self.id = id
        self.ownerId = ownerId
        self.title = title
        self.createdAt = createdAt
    }
}
