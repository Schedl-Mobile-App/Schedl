////
////  ScheduleViewOptions.swift
////  Schedl
////
////  Created by David Medina on 6/15/25.
////
//
//import UIKit
//import Foundation
//import SwiftUI
//
//class ScheduleViewOptions: UIView {
//    
//    weak var delegate: ScheduleViewDelegate?
//    
//    // UI
//    private let titleLabel = UILabel()
//    private let menuButton = UIButton(type: .system)
//    private let underlineView = UIView() // optional accent that animates on selection
//    
//    // State
//    
//    
//    // Icons
//    
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        configureUI()
//        updateMenu()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        configureUI()
//        updateMenu()
//    }
//    
//    private func configureUI() {
//        translatesAutoresizingMaskIntoConstraints = false
//        
//        // Title label (if you want to show a header; currently unused text)
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.text = ""
//        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
//        titleLabel.textColor = UIColor(Color(hex: 0x544F47))
//        
//        // Menu button
//        menuButton.translatesAutoresizingMaskIntoConstraints = false
//        menuButton.configuration = .plain()
//        menuButton.configuration?.imagePlacement = .leading
//        menuButton.configuration?.imagePadding = 8
//        menuButton.configuration?.baseForegroundColor = UIColor(Color(hex: 0x544F47))
//        menuButton.setTitleColor(UIColor(Color(hex: 0x544F47)), for: .normal)
//        menuButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
//        menuButton.contentHorizontalAlignment = .leading
//        menuButton.showsMenuAsPrimaryAction = true
//        menuButton.changesSelectionAsPrimaryAction = false
//        
//        // Optional underline accent
//        underlineView.translatesAutoresizingMaskIntoConstraints = false
//        underlineView.backgroundColor = UIColor(Color(hex: 0x544F47)).withAlphaComponent(0.15)
//        underlineView.layer.cornerRadius = 1
//        
//        addSubview(titleLabel)
//        addSubview(menuButton)
//        addSubview(underlineView)
//        
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: topAnchor),
//            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
//            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
//            
//            menuButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
//            menuButton.leadingAnchor.constraint(equalTo: leadingAnchor),
//            menuButton.trailingAnchor.constraint(equalTo: trailingAnchor),
//            menuButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
//            menuButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
//            
//            underlineView.topAnchor.constraint(equalTo: menuButton.bottomAnchor, constant: 2),
//            underlineView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            underlineView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            underlineView.heightAnchor.constraint(equalToConstant: 2)
//        ])
//        
//        // Accessibility grouping
//        isAccessibilityElement = false
//        accessibilityElements = [titleLabel, menuButton]
//    }
//    
//    private func updateMenu() {
//        // Actions with checkmark state and SF Symbols
//        let dayAction = UIAction(title: "Day", image: UIImage(systemName: daySymbol), state: currentSelection == .day ? .on : .off) { [weak self] _ in
//            self?.handleSelection(.day)
//        }
//        let weekAction = UIAction(title: "Week", image: UIImage(systemName: weekSymbol), state: currentSelection == .week ? .on : .off) { [weak self] _ in
//            self?.handleSelection(.week)
//        }
//        let monthAction = UIAction(title: "Month", image: UIImage(systemName: monthSymbol), state: currentSelection == .month ? .on : .off) { [weak self] _ in
//            self?.handleSelection(.month)
//        }
//        
//        // Year is visually available; no delegate call since enum lacks .year
//        let yearAction = UIAction(title: "Year", image: UIImage(systemName: yearSymbol), state: .off) { [weak self] _ in
//            self?.animateSelectionFeedback()
//            // Optionally show a hint/toast if needed
//        }
//        
//        let menu = UIMenu(title: "", options: .displayInline, children: [dayAction, weekAction, monthAction, yearAction])
//        menuButton.menu = menu
//        
//        // Update button title/icon to match current selection
//        switch currentSelection {
//        case .day:
//            menuButton.setTitle("Day", for: .normal)
//            menuButton.setImage(UIImage(systemName: daySymbol), for: .normal)
//        case .week:
//            menuButton.setTitle("Week", for: .normal)
//            menuButton.setImage(UIImage(systemName: weekSymbol), for: .normal)
//        case .month:
//            menuButton.setTitle("Month", for: .normal)
//            menuButton.setImage(UIImage(systemName: monthSymbol), for: .normal)
//        }
//        
//        // Ensure image sits to the left
//        menuButton.configuration?.imagePlacement = .leading
//        menuButton.configuration?.imagePadding = 8
//    }
//    
//    
//
//    
//    // Public API to read selection (kept for compatibility; returns string)
//    func getSelectedOption() -> String? {
//        switch currentSelection {
//        case .day: return "Day"
//        case .week: return "Week"
//        case .month: return "Month"
//        }
//    }
//}
