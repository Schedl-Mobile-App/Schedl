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
    
    weak var rootVC: UIViewController?
    weak var viewModel: ScheduleViewModel?
    
    var events: [Event] = []
    let containerView = SecondPassthroughView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("EventCellsContainer initialized with frame: \(frame)")
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        let panGesture = TapOnlyGestureRecognizer(target: containerView, action: nil)
//        panGesture.cancelsTouchesInView = true
        containerView.addGestureRecognizer(panGesture)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func populateEventCells(rootVC: UIViewController, scheduleViewModel: ScheduleViewModel, events: [Event], centerDate: Date, calendarInterval: Int) {
        
        for subview in containerView.subviews {
            subview.removeFromSuperview()
        }
        
        self.rootVC = rootVC
        self.viewModel = scheduleViewModel
        self.events = events
        
        // the width of placed events with some horizontal width shaved off
//        let paddedEventWidth: Double = 120
//        let adjustedXPosition: Double = (125 - paddedEventWidth) / 2
        
        for event in events {
            
            let dates = occurrenceDates(for: event, centerDate: centerDate, calendarInterval: calendarInterval)
            
            if dates.isEmpty {
                let eventObj = RecurringEvents(date: event.startDate, event: event)
                let xPosition = Double((getDayIndex(eventDate: Date(timeIntervalSince1970: event.startDate), centerDate: centerDate, calendarInterval: calendarInterval) ?? 0) * 60) + 1
                let yStartPosition = event.startTime / 3600 * 100
                let yOffset = (event.endTime - event.startTime) / 3600 * 100
                
                let eventCell = EventCell(frame: CGRect(x: xPosition, y: yStartPosition, width: 58, height: yOffset))
                eventCell.configureUI(viewModel: scheduleViewModel, event: eventObj, rootVC: rootVC)
                eventCell.isUserInteractionEnabled = true
                containerView.addSubview(eventCell)
            } else {
                for date in dates {
                    let eventObj = RecurringEvents(date: date.timeIntervalSince1970, event: event)
                    let xPosition = Double((getDayIndex(eventDate: date, centerDate: centerDate, calendarInterval: calendarInterval) ?? 0) * 60) + 1
                    let yStartPosition = event.startTime / 3600 * 100
                    let yOffset = (event.endTime - event.startTime) / 3600 * 100
                    
                    let eventCell = EventCell(frame: CGRect(x: xPosition, y: yStartPosition, width: 58, height: yOffset))
                    eventCell.configureUI(viewModel: scheduleViewModel, event: eventObj, rootVC: rootVC)
                    eventCell.isUserInteractionEnabled = true
                    containerView.addSubview(eventCell)
                }
            }
        }
    }
    
    func getDayIndex(eventDate: Date, centerDate: Date, calendarInterval: Int) -> Int? {
        
        // Calculate the difference in days between eventDate and centerDate
        let components = Calendar.current.dateComponents([.day], from: centerDate, to: eventDate)
        guard let dayDifference = components.day else { return nil }

        // Add 30 to adjust for the -30 to +30 range in dayList
        let dayIndex = dayDifference + 30

        // Ensure the index is within the valid range of dayList (0 to 60)
        guard dayIndex >= 0 && dayIndex < calendarInterval else { return nil }
        
        return dayIndex
    }
    
    func occurrenceDates(
        for event: Event,
        centerDate: Date,
        calendarInterval: Int
    ) -> [Date] {
        let cal = Calendar.current
        let halfWindow = calendarInterval / 2

        guard
        let viewStart = cal.date(byAdding: .day, value: -halfWindow, to: centerDate),
        let viewEnd = cal.date(byAdding: .day, value:  halfWindow, to: centerDate)
        else { return [] }

        let iterationStart = max(Date(timeIntervalSince1970: event.startDate), viewStart)
        let iterationEnd = min(Date(timeIntervalSince1970: event.endDate ?? viewEnd.timeIntervalSince1970), viewEnd)

        var dates: [Date] = []
        var cursor = iterationStart
                
        guard let repeatedDays = event.repeatingDays else { return dates }

        while cursor <= iterationEnd {
            // store the current iteration index
            let weekIndex = cal.component(.weekday, from: cursor) - 1
            
            // next, we need to find a way to check whether our event instance includes the same weekday index
            if repeatedDays.contains(String(weekIndex)) {
                dates.append(cursor)
            }
            guard let next = cal.date(byAdding: .day, value: 1, to: cursor) else { break }
                cursor = next
        }

        return dates
    }

    
    @objc
    func didPan(_ gesture: UIPanGestureRecognizer) {
        guard gesture.state == .ended else { return }
    }
}
