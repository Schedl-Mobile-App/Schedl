//
//  Tab.swift
//  Schedoolr
//
//  Created by David Medina on 1/19/25.
//

import SwiftUI

enum ProfileTab: Int, Identifiable, CaseIterable, Comparable {
    static func < (lhs: ProfileTab, rhs: ProfileTab) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    case schedules, events, activity
    
    internal var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .schedules:
            return "Schedules"
        case .events:
            return "Events"
        case .activity:
            return "Activity"
        }
    }
}
