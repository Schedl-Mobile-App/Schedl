//
//  Task.swift
//  calendarTest
//
//  Created by David Medina on 11/25/24.
//

import Foundation

struct Tasks: Codable, Identifiable {
    var id: String
    var title: String
    var description: String
    var status: String
    var creationDate: TimeInterval
    
    init(id: String, title: String, description: String, status: String, creationDate: Double) {
        self.id = id
        self.title = title
        self.description = description
        self.status = status
        self.creationDate = creationDate
    }
}
