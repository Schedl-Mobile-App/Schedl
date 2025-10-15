//
//  MockEventFactory.swift
//  Schedl
//
//  Created by David Medina on 10/9/25.
//

import Foundation

enum MockEventFactory {
    
    static func createEvent(for date: Date, with userId: String) -> Event {
        let randomStartTime = Int.random(in: 0..<12)
        let randomEndTime = Int.random(in: 0..<12) + randomStartTime
        
        let mockStartTime: Int = randomStartTime * 60
        let mockEndTime: Int = randomEndTime * 60
        
        let randomColor = [ColorPalette.pastel.colors, ColorPalette.foresty.colors, ColorPalette.rustic.colors].randomElement()?.randomElement()
        
        let colorString = randomColor?.toHex() ?? "3C859E"
        
        let location = MTPlacemark(name: "Cafe Luna", address: "123 Main St, Austin, TX", latitude: 30.2672, longitude: -97.7431)
        
//        let invitedUsers = [InvitedUser(userId: "user_preview_2", status: "pending"), InvitedUser(userId: "user_preview_1", status: "accepted")]

        // Mock event (empty invitedUsers to avoid any data fetch during previews)
        return Event(
            id: UUID().uuidString,
            ownerId: userId,
            title: "Weekly Meeting with Michael",
            startDate: date,
            startTime: mockStartTime,
            endTime: mockEndTime,
            location: location,
            color: colorString,
            invitedUsers: []
        )
    }
    
    static func createEvent(userId: String) -> Event {
        
        let randomDayOffset = Int.random(in: 0..<7)
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let eventDate = Calendar.current.date(byAdding: .day, value: randomDayOffset, to: startOfDay)!
        
        let randomStartTime = Int.random(in: 0..<12)
        let randomEndTime = Int.random(in: 0..<12) + randomStartTime
        
        let mockStartTime: Int = randomStartTime * 60
        let mockEndTime: Int = randomEndTime * 60
        
        let randomColor = [ColorPalette.pastel.colors, ColorPalette.foresty.colors, ColorPalette.rustic.colors].randomElement()?.randomElement()
        
        let colorString = randomColor?.toHex() ?? "3C859E"
        
        let location = MTPlacemark(name: "Cafe Luna", address: "123 Main St, Austin, TX", latitude: 30.2672, longitude: -97.7431)
        
//        let invitedUsers = [InvitedUser(userId: "user_preview_2", status: "pending"), InvitedUser(userId: "user_preview_1", status: "accepted")]

        // Mock event (empty invitedUsers to avoid any data fetch during previews)
        return Event(
            id: UUID().uuidString,
            ownerId: userId,
            title: "Weekly Meeting with Michael",
            startDate: eventDate,
            startTime: mockStartTime,
            endTime: mockEndTime,
            location: location,
            color: colorString,
            invitedUsers: []
        )
    }
    
    static func createEvents(_ count: Int, for userId: String) -> [Event] {
        (0..<count).map { _ in createEvent(userId: userId) }
    }
    
    static func createEvents(_ count: Int, for date: Date, with userId: String) -> [Event] {
        (0..<count).map { _ in createEvent(for: date, with: userId) }
    }
}
