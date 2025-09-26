//
//  InvitedUser.swift
//  Schedl
//
//  Created by David Medina on 9/7/25.
//

import Foundation

struct InvitedUser: Codable, Equatable, Hashable {
    
    static func == (lhs: InvitedUser, rhs: InvitedUser) -> Bool {
        lhs.userId == rhs.userId
    }
    
    let userId: String
    let status: String
    
    init(userId: String, status: String = "pending") {
        self.userId = userId
        self.status = status
    }
}
