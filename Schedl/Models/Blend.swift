//
//  Blend.swift
//  Schedl
//
//  Created by David Medina on 8/5/25.
//

struct Blend: Codable, Identifiable {
    let id: String
    let title: String
    let invitedUsers: [String]
    let scheduleIds: [String]
    let colors: [String: String]
}
