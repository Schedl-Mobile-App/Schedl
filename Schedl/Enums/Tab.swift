//
//  Tab.swift
//  Schedoolr
//
//  Created by David Medina on 1/19/25.
//

import SwiftUI

enum Tab: Int, Identifiable, CaseIterable, Comparable {
    static func < (lhs: Tab, rhs: Tab) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    case schedules, events, activity
    
    internal var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .schedules:
            return "My Schedule"
        case .events:
            return "Events"
        case .activity:
            return "Activity"
        }
    }
}
