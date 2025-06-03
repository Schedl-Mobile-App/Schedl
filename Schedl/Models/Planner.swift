//
//  Planner.swift
//  calendarTest
//
//  Created by David Medina on 11/25/24.
//

import Foundation

struct Planner: Codable, Identifiable {
    var id: String
    var title: String
    var tasks: [Tasks]
    var creationDate: TimeInterval
    
    init(id: String, title: String, tasks: [Tasks], creationDate: Double) {
        self.id = id
        self.title = title
        self.tasks = tasks
        self.creationDate = creationDate
    }
}
