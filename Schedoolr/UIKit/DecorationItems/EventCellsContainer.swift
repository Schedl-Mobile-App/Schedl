//
//  EventCellsContainer.swift
//  Schedoolr
//
//  Created by David Medina on 3/1/25.
//

import UIKit

class EventCellsContainer: UICollectionReusableView {
    
    weak var rootVC: UIViewController?
    weak var viewModel: ScheduleViewModel?
    
    var events: [Event] = []
    let containerView = UIView()
    
    static weak var instance: EventCellsContainer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        EventCellsContainer.instance = self
        configureUI()
        print("Frame of Event Cells Container", frame)
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
    
    func populateEventCells(rootVC: UIViewController, viewModel: ScheduleViewModel, events: [Event], centerDate: Date, calendarInterval: Int) {
        
        self.rootVC = rootVC
        self.viewModel = viewModel
        self.events = events
        
        for event in events {
            let xPosition = (getDayIndex(eventDate: Date.convertTimeSince1970ToDate(time: event.eventDate), centerDate: centerDate, calendarInterval: calendarInterval) ?? 0) * 75
            let yStartPosition = event.startTime / 3600 * 100
            let yOffset = (event.endTime - event.startTime) / 3600 * 100
            
            let eventCell = EventCell(frame: CGRect(x: Double(xPosition), y: yStartPosition, width: 75, height: yOffset))
            eventCell.configureUI(viewModel: viewModel, event: event, rootVC: rootVC)
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
