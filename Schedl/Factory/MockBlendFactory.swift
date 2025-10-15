//
//  MockBlendFactory.swift
//  Schedl
//
//  Created by David Medina on 10/9/25.
//

import Foundation

enum MockBlendFactory {
    static func createBlend(userId: String, name: String) -> Blend {
        let title = "\(name)'s Blend"
        
        return Blend(id: UUID().uuidString, ownerId: userId, title: title, invitedUsers: [], scheduleIds: [], colors: [])
    }
    
    static func createBlends(_ count: Int, for userId: String, with name: String) -> [Blend] {
        (0..<count).map { _ in createBlend(userId: userId, name: name) }
    }
}
