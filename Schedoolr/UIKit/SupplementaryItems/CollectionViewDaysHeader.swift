//
//  CollectionViewDaysHeader.swift
//  Schedoolr
//
//  Created by David Medina on 2/20/25.
//

import UIKit
import Foundation

class CollectionViewDaysHeader: UICollectionReusableView {
    
    static let identifier = "DayHeader"
    
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
        stackView.backgroundColor = UIColor(named: "DarkBackground")
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func setDates(dayList: [Date], weekList: [Int : String]) {
        
        // remove any existing labels
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                
        for index in dayList.indices {
            
            let dayComponent = Calendar.current.dateComponents([.day], from: dayList[index])
            let actualDateComponent = Calendar.current.dateComponents([.weekday], from: dayList[index])
            
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.backgroundColor = .clear
            
            // Create and add borders to the container (left, right, bottom)
            let leftBorder = UIView()
            leftBorder.backgroundColor = UIColor.systemGray
            leftBorder.translatesAutoresizingMaskIntoConstraints = false
            
            let rightBorder = UIView()
            rightBorder.backgroundColor = UIColor.systemGray
            rightBorder.translatesAutoresizingMaskIntoConstraints = false
            
            let bottomBorder = UIView()
            bottomBorder.backgroundColor = UIColor.systemGray
            bottomBorder.translatesAutoresizingMaskIntoConstraints = false
            
            containerView.addSubview(leftBorder)
            containerView.addSubview(rightBorder)
            containerView.addSubview(bottomBorder)
            
            let dayLabel = UILabel()
            dayLabel.text = "\(dayComponent.day ?? 0)"
            dayLabel.translatesAutoresizingMaskIntoConstraints = false
            dayLabel.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)
            
            let dateLabel = UILabel()
            dateLabel.text = "\(weekList[actualDateComponent.weekday ?? 0] ?? "")"
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            dateLabel.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .bold)
            
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
            
            stackView.addArrangedSubview(containerView)
        }
    }
}
