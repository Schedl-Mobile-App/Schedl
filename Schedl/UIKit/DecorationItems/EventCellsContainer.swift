//
//  EventCellsContainer.swift
//  Schedoolr
//
//  Created by David Medina on 3/1/25.
//

import UIKit

class TapOnlyGestureRecognizer: UITapGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        // Allow simultaneous recognition with other gestures
        self.delaysTouchesBegan = false
        self.delaysTouchesEnded = false
    }
    
    override func canPrevent(_ preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Don't prevent other gesture recognizers
        return false
    }
    
    override func canBePrevented(by preventingGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow pan gestures to prevent this tap recognizer
        if preventingGestureRecognizer is UIPanGestureRecognizer {
            return true
        }
        return false
    }
}

class SecondPassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let tapped = super.hitTest(point, with: event)
        return tapped == self ? nil : tapped
    }
}

class EventCellsContainer: SecondPassthroughView {
    
    var onTap: ((RecurringEvents) -> Void)?
    var events: [RecurringEvents] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func populateEventCells(events: [RecurringEvents], centerDate: Date, calendarInterval: Int) {
        
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        
        self.events = events
        
        for event in events {
            let xPosition = Double((getDayIndex(eventDate: Date(timeIntervalSince1970: event.date), centerDate: centerDate, calendarInterval: calendarInterval) ?? 0) * 60) + 1
            let yStartPosition = event.event.startTime / 3600 * 100
            let yOffset = (event.event.endTime - event.event.startTime) / 3600 * 100
            
            let eventCell = EventCell(frame: CGRect(x: xPosition, y: yStartPosition, width: 58, height: yOffset))
            eventCell.configureUI(event: event)
            eventCell.onSelectEvent = { [weak self] event in
                self?.onTap?(event)
            }
            eventCell.isUserInteractionEnabled = true
            addSubview(eventCell)
        }
    }
    
    func addSingleEvent(event: RecurringEvents, centerDate: Date, calendarInterval: Int) {
                
        let eventDate = Date(timeIntervalSince1970: event.event.startDate)
        
        let calendar = Calendar.current
        let eventDay = calendar.startOfDay(for: eventDate)
        let centerDay = calendar.startOfDay(for: centerDate)

        let comps = calendar.dateComponents([.day], from: centerDay, to: eventDay)
        if let dayDiff = comps.day {
            let centerIndex = calendarInterval / 2
            let dayIndex = dayDiff + centerIndex
            let isInRange = (0..<calendarInterval).contains(dayIndex)
            
            if isInRange {
                let xPosition = Double((getDayIndex(eventDate: Date(timeIntervalSince1970: event.date), centerDate: centerDate, calendarInterval: calendarInterval) ?? 0) * 60) + 1
                let yStartPosition = event.event.startTime / 3600 * 100
                let yOffset = (event.event.endTime - event.event.startTime) / 3600 * 100
                
                let eventCell = EventCell(frame: CGRect(x: xPosition, y: yStartPosition, width: 58, height: yOffset))
                eventCell.configureUI(event: event)
                eventCell.onSelectEvent = { [weak self] event in
                    self?.onTap?(event)
                }
                eventCell.isUserInteractionEnabled = true
                addSubview(eventCell)
            }
        }
    }
    
    func addRecurringEvent(events: [RecurringEvents], centerDate: Date, calendarInterval: Int) {
        
        let calendar = Calendar.current
        let centerDay = calendar.startOfDay(for: centerDate)
        let centerIndex = calendarInterval / 2
        
        for event in events {
            let eventDate = Date(timeIntervalSince1970: event.event.startDate)
            
            let eventDay = calendar.startOfDay(for: eventDate)
            
            let comps = calendar.dateComponents([.day], from: centerDay, to: eventDay)
            if let dayDiff = comps.day {
                let dayIndex = dayDiff + centerIndex
                let isInRange = (0..<calendarInterval).contains(dayIndex)
                
                if isInRange {
                    let xPosition = Double((getDayIndex(eventDate: Date(timeIntervalSince1970: event.date), centerDate: centerDate, calendarInterval: calendarInterval) ?? 0) * 60) + 1
                    let yStartPosition = event.event.startTime / 3600 * 100
                    let yOffset = (event.event.endTime - event.event.startTime) / 3600 * 100
                    
                    let eventCell = EventCell(frame: CGRect(x: xPosition, y: yStartPosition, width: 58, height: yOffset))
                    eventCell.configureUI(event: event)
                    eventCell.onSelectEvent = { [weak self] event in
                        self?.onTap?(event)
                    }
                    eventCell.isUserInteractionEnabled = true
                    addSubview(eventCell)
                }
            }
        }
    }
        
    func getDayIndex(eventDate: Date, centerDate: Date, calendarInterval: Int) -> Int? {
        
        // Calculate the difference in days between the event date and the center date.
        let components = Calendar.current.dateComponents([.day], from: centerDate, to: eventDate)
        guard let dayDifference = components.day else { return nil }

        // Calculate the center index of the date range.
        let centerIndex = calendarInterval / 2

        // The event's index is its difference from the center, offset by the center's index.
        let dayIndex = dayDifference + centerIndex

        // Ensure the calculated index is within the valid bounds of the date range.
        guard dayIndex >= 0 && dayIndex < calendarInterval else { return nil }
        
        return dayIndex
    }
}
