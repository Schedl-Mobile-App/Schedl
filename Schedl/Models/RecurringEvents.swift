//
//  RecurringEvents.swift
//  Schedl
//
//  Created by David Medina on 6/11/25.
//

import Foundation

struct EventOccurrence: Identifiable, Equatable, Hashable {
    static func == (lhs: EventOccurrence, rhs: EventOccurrence) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: String {
        "\(event.id)-\(recurringDate.timeIntervalSince1970)"
    }
    
    var recurringDate: Date
    var event: Event
}
