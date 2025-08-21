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
    
    var onTap: ((RecurringEvents) -> Void)?
    
    var events: [RecurringEvents] = []
    let containerView = SecondPassthroughView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    
    func populateEventCells(rootVC: UIViewController, scheduleViewModel: ScheduleViewModel, events: [RecurringEvents], centerDate: Date, calendarInterval: Int) {
        
        for subview in containerView.subviews {
            subview.removeFromSuperview()
        }
        
        self.rootVC = rootVC
        self.viewModel = scheduleViewModel
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
            containerView.addSubview(eventCell)
            containerView.bringSubviewToFront(eventCell)
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
}
