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
    let overlayView = UIView()
    
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
    }
    
    func setDates(dayList: [Date], weekList: [Int : String]) {
        
        // remove any existing labels
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for index in dayList.indices {
            let label = UILabel()
            let dayComponent = Calendar.current.dateComponents([.day], from: dayList[index])
            let actualDateComponent = Calendar.current.dateComponents([.weekday], from: dayList[index])
            label.text = "\(dayComponent.day ?? 0) \(weekList[actualDateComponent.weekday ?? 0] ?? "")"
            label.backgroundColor = .systemBackground
            label.textAlignment = .center
            
            stackView.addArrangedSubview(label)
        }
    }
}
