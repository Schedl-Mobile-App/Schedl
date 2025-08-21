//
//  Blend.swift
//  Schedl
//
//  Created by David Medina on 8/5/25.
//

struct Blend: Codable, Identifiable {
    let id: String
    let userId: String
    var title: String
    var invitedUsers: [String]
    var scheduleIds: [String]
    var colors: [String: String]
}
