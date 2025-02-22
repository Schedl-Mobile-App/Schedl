//
//  CollectionViewDaysHeader.swift
//  Schedoolr
//
//  Created by David Medina on 2/20/25.
//

import UIKit

class CollectionViewDaysHeader: UICollectionReusableView {
    
    static let identifier = "DayHeader"
    
    // using a stack view since all time cells will be vertically stacked on top of one another
    let stackView = UIStackView()
    let overlayView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // Setup stackView (your existing code)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 5
        stackView.backgroundColor = .systemBackground
        addSubview(stackView)
        
        // Setup overlay view
        overlayView.backgroundColor = .systemBackground
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlayView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Position overlay at leading edge with width of time column
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor),
            overlayView.widthAnchor.constraint(equalToConstant: 44) // Match time column width
        ])
        
        setupDayLabels()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Get the visible frame in window coordinates
        guard let window = window else { return }
        let visibleFrame = convert(bounds, to: window)
        
        // Convert window coordinates back to our view's coordinate space
        let overlayX = convert(CGPoint(x: visibleFrame.minX, y: 0), from: window).x
        
        // Update overlay frame to stay at visible left edge
        overlayView.frame = CGRect(
            x: overlayX,
            y: 0,
            width: 44,  // Time column width
            height: bounds.height
        )
    }
    
    private func setupDayLabels() {
        // Remove any existing labels
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // current day
        let currentDay = Date()
        var dayList: [Date] = []
        
        for index in -30..<30 {
            dayList.append(Calendar.current.date(byAdding: .day, value: index, to: currentDay) ?? Date())
        }
        
        let weekList: [Int: String] = [
            1 : "Sun",
            2 : "Mon",
            3 : "Tue",
            4 : "Wed",
            5 : "Thu",
            6 : "Fri",
            7 : "Sat"
        ]
        
        for index in dayList.indices {
            let label = UILabel()
            let dayComponent = Calendar.current.dateComponents([.day], from: dayList[index])
            let actualDateComponent = Calendar.current.dateComponents([.weekday], from: dayList[index])
            print("\(dayComponent) \(actualDateComponent)")
            label.text = "\(dayComponent.day ?? 0) \(weekList[actualDateComponent.weekday ?? 0] ?? "")"
            label.backgroundColor = .systemBackground
            label.textAlignment = .center
            label.layer.borderWidth = 0.25
            label.layer.borderColor = UIColor.black.cgColor
            stackView.addArrangedSubview(label)
        }
    }
}
