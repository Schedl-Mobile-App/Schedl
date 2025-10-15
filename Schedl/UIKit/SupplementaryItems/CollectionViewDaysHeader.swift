//
//  CollectionViewDaysHeader.swift
//  Schedoolr
//
//  Created by David Medina on 2/20/25.
//

import UIKit
import Foundation
import SwiftUI

class DayBorderedCellView: UIView {
    
    // We will draw these borders ourselves
    let bottomBorderWidth: CGFloat = 1
    let sideBorderWidth: CGFloat = 0.5
    let borderColor = UIColor(Color("DividerLines"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Set the background color here
        backgroundColor = UIColor(Color("BackgroundColor"))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // This is where the magic happens!
    override func draw(_ rect: CGRect) {
        super.draw(rect) // Draws the background color
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setStrokeColor(borderColor.cgColor)
        context.setLineWidth(sideBorderWidth)
        
        // Draw Left Border
        context.move(to: CGPoint(x: 0, y: 10))
        context.addLine(to: CGPoint(x: 0, y: bounds.height))
        context.strokePath()
        
        // Draw Right Border
        context.move(to: CGPoint(x: bounds.width, y: 10))
        context.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        context.strokePath()
        
        // Draw Bottom Border
        context.setLineWidth(bottomBorderWidth)
        context.move(to: CGPoint(x: 0, y: bounds.height))
        context.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        context.strokePath()
        
        
    }
}

class CollectionViewDaysHeader: UIView {
    
    static let identifier = "DayHeader"
    
    var currentDate = Date()
    
    let weekList: [Int: String] = [
        1 : "Sun",
        2 : "Mon",
        3 : "Tue",
        4 : "Wed",
        5 : "Thu",
        6 : "Fri",
        7 : "Sat"
    ]
    
    // using a stack view since all time cells will be vertically stacked on top of one another
    let stackView = UIStackView()
    let dayLabelContainer = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        // Setup stackView (your existing code)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 5
        stackView.backgroundColor = UIColor(Color("BackgroundColor"))
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func createDayLabel(dateComponent: Date) -> UIView {
        let dayComponent = Calendar.current.dateComponents([.day], from: dateComponent)
        let actualDateComponent = Calendar.current.dateComponents([.weekday], from: dateComponent)
        
        let borderedView: DayBorderedCellView = {
            let view = DayBorderedCellView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        let dateContainer = UIStackView()
        dateContainer.axis = .vertical
        dateContainer.distribution = .fillEqually
        dateContainer.alignment = .leading
        dateContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let dateLabel = UILabel()
        if Calendar.current.startOfDay(for: Date.now) == dateComponent {
            dateLabel.textColor = .red
        } else {
            dateLabel.textColor = UIColor(Color("ScheduleSecondaryText"))
        }
        dateLabel.text = "\(weekList[actualDateComponent.weekday ?? 0] ?? "")"
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.monospacedSystemFont(ofSize: 13, weight: .semibold)
        dateLabel.tag = 2
        
        dateContainer.addArrangedSubview(dateLabel)
        
        let dayLabel = UILabel()
        dayLabel.text = "\(dayComponent.day ?? 0)"
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .heavy)
        dayLabel.tag = 1
        
        if Calendar.current.startOfDay(for: Date.now) == dateComponent {
            dayLabel.textColor = .red
        } else {
            dayLabel.textColor = UIColor(Color("ScheduleSecondaryText"))
        }
        
        dateContainer.addArrangedSubview(dayLabel)
        
        borderedView.addSubview(dateContainer)
        borderedView.bringSubviewToFront(dateContainer)

        NSLayoutConstraint.activate([
            dateContainer.topAnchor.constraint(equalTo: borderedView.topAnchor, constant: 10),
            dateContainer.bottomAnchor.constraint(equalTo: borderedView.bottomAnchor, constant: -10),
            dateContainer.leadingAnchor.constraint(equalTo: borderedView.leadingAnchor, constant: 10),
            dateContainer.trailingAnchor.constraint(equalTo: borderedView.trailingAnchor),
        ])
        
        return borderedView
    }
    
    func updateDayLabel(view: UIView, date: Date) {
        guard let dayLabel = view.viewWithTag(1) as? UILabel,
              let dateLabel = view.viewWithTag(2) as? UILabel else { return }
        
        let dayComponent = Calendar.current.dateComponents([.day], from: date)
        let actualDateComponent = Calendar.current.dateComponents([.weekday], from: date)
        
        dayLabel.text = "\(dayComponent.day ?? 0)"
        dateLabel.text = "\(weekList[actualDateComponent.weekday ?? 0] ?? "")"
    }
    
    func addNextDates(updatedDayList: [Date]) {
        for newDate in updatedDayList {
            // 1. Get the first view to recycle
            guard let viewToRecycle = stackView.arrangedSubviews.first else { continue }
            
            // 2. Remove it from the beginning of the stack
            stackView.removeArrangedSubview(viewToRecycle)
            
            // 3. Update its content with the new date ✨
            updateDayLabel(view: viewToRecycle, date: newDate)
            
            // 4. Add the recycled view to the end of the stack
            stackView.addArrangedSubview(viewToRecycle)
        }
    }

    func addPreviousDates(updatedDayList: [Date]) {
        for newDate in updatedDayList {
            // 1. Get the last view to recycle
            guard let viewToRecycle = stackView.arrangedSubviews.last else { continue }
            
            // 2. Remove it from the end of the stack
            stackView.removeArrangedSubview(viewToRecycle)
            
            // 3. Update its content with the new date ✨
            updateDayLabel(view: viewToRecycle, date: newDate)
            
            // 4. Insert the recycled view at the beginning of the stack
            stackView.insertArrangedSubview(viewToRecycle, at: 0)
        }
    }
    
    func setDates(dayList: [Date]) {
        
        // remove any existing labels from the stack view
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
                
        for index in dayList.indices {
            let containerView = createDayLabel(dateComponent: dayList[index])
            stackView.addArrangedSubview(containerView)
        }
    }
}
