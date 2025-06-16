//
//  RecurringEvents.swift
//  Schedl
//
//  Created by David Medina on 6/11/25.
//

import Foundation

struct RecurringEvents: Identifiable {
    let id = UUID().uuidString
    var date: TimeInterval
    var event: Event
}
