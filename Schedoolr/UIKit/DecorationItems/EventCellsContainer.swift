//
//  EventCellsContainer.swift
//  Schedoolr
//
//  Created by David Medina on 3/1/25.
//

import UIKit

class SecondPassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
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
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func updateContentOffset(to offset: CGPoint) {
        // Apply transforms to the containerView to match scroll position
        containerView.transform = CGAffineTransform(translationX: -offset.x, y: -offset.y)
    }
    
    func populateEventCells(rootVC: UIViewController, scheduleViewModel: ScheduleViewModel, events: [Event], centerDate: Date, calendarInterval: Int) {
        
        for subview in containerView.subviews {
            subview.removeFromSuperview()
        }
        
        self.rootVC = rootVC
        self.viewModel = scheduleViewModel
        self.events = events
        
        for event in events {
            let xPosition = (getDayIndex(eventDate: Date.convertTimeSince1970ToDate(time: event.eventDate), centerDate: centerDate, calendarInterval: calendarInterval) ?? 0) * 75
            let yStartPosition = event.startTime / 3600 * 100
            let yOffset = (event.endTime - event.startTime) / 3600 * 100
            
            let eventCell = EventCell(frame: CGRect(x: Double(xPosition), y: yStartPosition, width: 75, height: yOffset))
            eventCell.configureUI(viewModel: scheduleViewModel, event: event, rootVC: rootVC)
            eventCell.isUserInteractionEnabled = true
            containerView.addSubview(eventCell)
        }
    }
    
    func getDayIndex(eventDate: Date, centerDate: Date, calendarInterval: Int) -> Int? {
        
        let calendar = Calendar(identifier: .gregorian)
        var calculationCalendar = calendar
        calculationCalendar.timeZone = TimeZone(identifier: "UTC")! // Remove time zone differences
        
        let normalizedCenterDate = calculationCalendar.startOfDay(for: centerDate)
        let normalizedEventDate = calculationCalendar.startOfDay(for: eventDate)
        
        // Calculate the difference in days between eventDate and centerDate
        let components = Calendar.current.dateComponents([.day], from: normalizedCenterDate, to: normalizedEventDate)
        guard let dayDifference = components.day else { return nil }

        // Add 30 to adjust for the -30 to +29 range in dayList
        let dayIndex = dayDifference + 30

        // Ensure the index is within the valid range of dayList (0 to 59)
        guard dayIndex >= 0 && dayIndex < calendarInterval else { return nil }
        
        return dayIndex
    }
}
