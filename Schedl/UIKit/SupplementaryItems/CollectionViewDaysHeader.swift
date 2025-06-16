//
//  CollectionViewDaysHeader.swift
//  Schedoolr
//
//  Created by David Medina on 2/20/25.
//

import UIKit
import Foundation
import SwiftUICore

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
        stackView.backgroundColor = UIColor(Color(hex: 0xf7f4f2))
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
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        
        // Create and add borders to the container (left, right, bottom)
        let leftBorder = UIView()
        leftBorder.backgroundColor = UIColor(Color.black.opacity(0.30))
        leftBorder.translatesAutoresizingMaskIntoConstraints = false
        
        let rightBorder = UIView()
        rightBorder.backgroundColor = UIColor(Color.black.opacity(0.30))
        rightBorder.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomBorder = UIView()
        bottomBorder.backgroundColor = UIColor(Color.black.opacity(0.30))
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(leftBorder)
        containerView.addSubview(rightBorder)
        containerView.addSubview(bottomBorder)
        
        let dayLabel = UILabel()
        dayLabel.text = "\(dayComponent.day ?? 0)"
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .bold)
        
        let dateLabel = UILabel()
        dateLabel.text = "\(weekList[actualDateComponent.weekday ?? 0] ?? "")"
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.monospacedSystemFont(ofSize: 13, weight: .medium)
        
        let dateContainer = UIStackView()
        dateContainer.axis = .vertical
        dateContainer.distribution = .fillEqually
        dateContainer.translatesAutoresizingMaskIntoConstraints = false
        
        dateContainer.addArrangedSubview(dateLabel)
        dateContainer.addArrangedSubview(dayLabel)

        containerView.addSubview(dateContainer)
        
        let bottomBorderWidth: CGFloat = 1
        let sideBorderWidth: CGFloat = 0.5
        
        // Setup constraints
        NSLayoutConstraint.activate([
            
            // Label fills container
            dateContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            dateContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            dateContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            dateContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            
            // Left border
            leftBorder.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            leftBorder.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            leftBorder.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            leftBorder.widthAnchor.constraint(equalToConstant: sideBorderWidth),
            
            // Right border
            rightBorder.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            rightBorder.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            rightBorder.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            rightBorder.widthAnchor.constraint(equalToConstant: sideBorderWidth),
            
            // Bottom border
            bottomBorder.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            bottomBorder.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            bottomBorder.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            bottomBorder.heightAnchor.constraint(equalToConstant: bottomBorderWidth)
        ])
        
        return containerView
    }
    
    func addNextDates(updatedDayList: [Date]) {
        
        for index in updatedDayList.indices {
            if let viewToRemove = stackView.arrangedSubviews.first {
                viewToRemove.removeFromSuperview()
                stackView.removeArrangedSubview(viewToRemove)
            }
            
            let viewContainer = createDayLabel(dateComponent: updatedDayList[index])
            stackView.addArrangedSubview(viewContainer)
        }
    }
    
    func addPreviousDates(updatedDayList: [Date]) {
        for index in updatedDayList.indices {
            if let viewToRemove = stackView.arrangedSubviews.last {
                viewToRemove.removeFromSuperview()
                stackView.removeArrangedSubview(viewToRemove)
            }
            
            let viewContainer = createDayLabel(dateComponent: updatedDayList[index])
            stackView.insertArrangedSubview(viewContainer, at: 0)
        }
    }
    
    func setDates(dayList: [Date]) {
        
        // remove any existing labels from the stack view
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                
        for index in dayList.indices {
            let containerView = createDayLabel(dateComponent: dayList[index])
            stackView.addArrangedSubview(containerView)
        }
    }
}
