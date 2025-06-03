//
//  EventCellsContainer.swift
//  Schedoolr
//
//  Created by David Medina on 3/1/25.
//

import UIKit

class SecondPassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 1️⃣ If the collection is currently dragging or decelerating, let the touch pass through
        if let cv = findCollectionView(), (cv.isDragging || cv.isDecelerating) {
            print("Exiting out of hitTest")
            return nil
        }
        // 2️⃣ Otherwise, do your normal hitTest→passthrough logic
        let tapped = super.hitTest(point, with: event)
        return tapped == self ? nil : tapped
    }

    private func findCollectionView() -> UICollectionView? {
        var v = superview
        while let view = v {
          if let cv = view as? UICollectionView { return cv }
          v = view.superview
        }
        return nil
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
            let xPosition = (getDayIndex(eventDate: Date.convertTimeSince1970ToDate(time: event.eventDate), centerDate: centerDate, calendarInterval: calendarInterval) ?? 0) * 60
            let yStartPosition = event.startTime / 3600 * 100
            let yOffset = (event.endTime - event.startTime) / 3600 * 100
            
            let eventCell = EventCell(frame: CGRect(x: Double(xPosition), y: yStartPosition, width: 60, height: yOffset))
            eventCell.configureUI(viewModel: scheduleViewModel, event: event, rootVC: rootVC)
            eventCell.isUserInteractionEnabled = true
            containerView.addSubview(eventCell)
        }
    }
    
    func getDayIndex(eventDate: Date, centerDate: Date, calendarInterval: Int) -> Int? {
        
        // Calculate the difference in days between eventDate and centerDate
        let components = Calendar.current.dateComponents([.day], from: centerDate, to: eventDate)
        guard let dayDifference = components.day else { return nil }

        // Add 30 to adjust for the -30 to +30 range in dayList
        let dayIndex = dayDifference + 30

        // Ensure the index is within the valid range of dayList (0 to 59)
        guard dayIndex >= 0 && dayIndex < calendarInterval else { return nil }
        
        return dayIndex
    }
}
