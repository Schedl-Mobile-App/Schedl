//
//  RecurringEvents.swift
//  Schedl
//
//  Created by David Medina on 6/11/25.
//

import Foundation

struct RecurringEvents: Identifiable, Equatable {
    static func == (lhs: RecurringEvents, rhs: RecurringEvents) -> Bool {
        lhs.id == rhs.id && lhs.date == rhs.date
    }
    
    let id = UUID().uuidString
    var date: TimeInterval
    var event: Event
}
