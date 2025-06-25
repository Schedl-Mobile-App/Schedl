//
//  ScheduleViewOptions.swift
//  Schedl
//
//  Created by David Medina on 6/15/25.
//

import UIKit
import Foundation
import SwiftUI

class ScheduleViewOptions: UIStackView {
    
    let dayOption: UIButton!
    let weekOption: UIButton!
    let monthOption: UIButton!
    let yearOption: UIButton!
    
    override init(frame: CGRect) {
        
        dayOption = UIButton()
        weekOption = UIButton()
        monthOption = UIButton()
        yearOption = UIButton()
        
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        axis = .vertical
        distribution = .fillEqually
        alignment = .leading
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        let titleView = UIView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 10, trailing: 5)
        titleView.backgroundColor = UIColor(Color.black.opacity(0.07))
        
        let titleLabel = UILabel()
        titleLabel.text = "Calendar View"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 14, weight: .heavy)
        titleLabel.textColor = UIColor(Color(hex: 0x666666))
        
        titleView.addSubview(titleLabel)
        
        addArrangedSubview(titleView)
        
        let dayOptionView = UIView()
        dayOptionView.translatesAutoresizingMaskIntoConstraints = false
        dayOptionView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 5)
        dayOptionView.backgroundColor = UIColor(Color.black.opacity(0.07))
        
        
        
        let weekOptionView = UIView()
        weekOptionView.translatesAutoresizingMaskIntoConstraints = false
        weekOptionView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 5)
        weekOptionView.backgroundColor = UIColor(Color.black.opacity(0.07))
        
        
        
        let monthOptionView = UIView()
        monthOptionView.translatesAutoresizingMaskIntoConstraints = false
        monthOptionView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 5)
        monthOptionView.backgroundColor = UIColor(Color.black.opacity(0.07))
        
        
        
        let yearOptionView = UIView()
        yearOptionView.translatesAutoresizingMaskIntoConstraints = false
        yearOptionView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 5)
        yearOptionView.backgroundColor = UIColor(Color.black.opacity(0.07))
        
        dayOption.setImage(nil, for: .normal)
        dayOption.setImage(UIImage(systemName: "checkmark"), for: .selected)
        // push it to the trailing edge:
        dayOption.contentHorizontalAlignment = .trailing
        dayOption.translatesAutoresizingMaskIntoConstraints = false
        
        dayOptionView.addSubview(dayOption)
        
        weekOption.setImage(nil, for: .normal)
        weekOption.setImage(UIImage(systemName: "checkmark"), for: .selected)
        // push it to the trailing edge:
        weekOption.contentHorizontalAlignment = .trailing
        weekOption.translatesAutoresizingMaskIntoConstraints = false
        
        weekOptionView.addSubview(weekOption)
        
        monthOption.setImage(nil, for: .normal)
        monthOption.setImage(UIImage(systemName: "checkmark"), for: .selected)
        // push it to the trailing edge:
        monthOption.contentHorizontalAlignment = .trailing
        monthOption.translatesAutoresizingMaskIntoConstraints = false
        
        monthOptionView.addSubview(monthOption)
        
        yearOption.setImage(nil, for: .normal)
        yearOption.setImage(UIImage(systemName: "checkmark"), for: .selected)
        // push it to the trailing edge:
        yearOption.contentHorizontalAlignment = .trailing
        yearOption.translatesAutoresizingMaskIntoConstraints = false
        
        yearOptionView.addSubview(yearOption)
        
        dayOption.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
        weekOption.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
        monthOption.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
        yearOption.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
        
        addArrangedSubview(dayOptionView)
        addArrangedSubview(weekOptionView)
        addArrangedSubview(monthOptionView)
        addArrangedSubview(yearOptionView)
        
        let dayLabel = UILabel()
        dayLabel.text = "Day"
        dayLabel.font = .systemFont(ofSize: 15, weight: .bold)
        dayLabel.textColor = UIColor(Color(hex: 0x666666))
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let weekLabel = UILabel()
        weekLabel.text = "Week"
        weekLabel.font = .systemFont(ofSize: 15, weight: .bold)
        weekLabel.textColor = UIColor(Color(hex: 0x666666))
        weekLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let monthLabel = UILabel()
        monthLabel.text = "Month"
        monthLabel.font = .systemFont(ofSize: 15, weight: .bold)
        monthLabel.textColor = UIColor(Color(hex: 0x666666))
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let yearLabel = UILabel()
        yearLabel.text = "Year"
        yearLabel.font = .systemFont(ofSize: 15, weight: .bold)
        yearLabel.textColor = UIColor(Color(hex: 0x666666))
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dayOption.addSubview(dayLabel)
        weekOption.addSubview(weekLabel)
        monthOption.addSubview(monthLabel)
        yearOption.addSubview(yearLabel)
                
        NSLayoutConstraint.activate([
            
            titleView.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: titleView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleView.layoutMarginsGuide.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleView.layoutMarginsGuide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.layoutMarginsGuide.bottomAnchor),
            
            dayOptionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dayOptionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            weekOptionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            weekOptionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            monthOptionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            monthOptionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            yearOptionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            yearOptionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            dayOption.leadingAnchor.constraint(equalTo: dayOptionView.layoutMarginsGuide.leadingAnchor),
            dayOption.trailingAnchor.constraint(equalTo: dayOptionView.layoutMarginsGuide.trailingAnchor),
            dayOption.topAnchor.constraint(equalTo: dayOptionView.layoutMarginsGuide.topAnchor),
            dayOption.bottomAnchor.constraint(equalTo: dayOptionView.layoutMarginsGuide.bottomAnchor),
            
            weekOption.leadingAnchor.constraint(equalTo: weekOptionView.layoutMarginsGuide.leadingAnchor),
            weekOption.trailingAnchor.constraint(equalTo: weekOptionView.layoutMarginsGuide.trailingAnchor),
            weekOption.topAnchor.constraint(equalTo: weekOptionView.layoutMarginsGuide.topAnchor),
            weekOption.bottomAnchor.constraint(equalTo: weekOptionView.layoutMarginsGuide.bottomAnchor),
            
            monthOption.leadingAnchor.constraint(equalTo: monthOptionView.layoutMarginsGuide.leadingAnchor),
            monthOption.trailingAnchor.constraint(equalTo: monthOptionView.layoutMarginsGuide.trailingAnchor),
            monthOption.topAnchor.constraint(equalTo: monthOptionView.layoutMarginsGuide.topAnchor),
            monthOption.bottomAnchor.constraint(equalTo: monthOptionView.layoutMarginsGuide.bottomAnchor),
            
            yearOption.leadingAnchor.constraint(equalTo: yearOptionView.layoutMarginsGuide.leadingAnchor),
            yearOption.trailingAnchor.constraint(equalTo: yearOptionView.layoutMarginsGuide.trailingAnchor),
            yearOption.topAnchor.constraint(equalTo: yearOptionView.layoutMarginsGuide.topAnchor),
            yearOption.bottomAnchor.constraint(equalTo: yearOptionView.layoutMarginsGuide.bottomAnchor),
            
            
            dayLabel.leadingAnchor.constraint(equalTo: dayOption.leadingAnchor),
            dayLabel.topAnchor.constraint(equalTo: dayOption.topAnchor),
            dayLabel.bottomAnchor.constraint(equalTo: dayOption.bottomAnchor),
            
            weekLabel.leadingAnchor.constraint(equalTo: weekOption.leadingAnchor),
            weekLabel.topAnchor.constraint(equalTo: weekOption.topAnchor),
            weekLabel.bottomAnchor.constraint(equalTo: weekOption.bottomAnchor),
            
            monthLabel.leadingAnchor.constraint(equalTo: monthOption.leadingAnchor),
            monthLabel.topAnchor.constraint(equalTo: monthOption.topAnchor),
            monthLabel.bottomAnchor.constraint(equalTo: monthOption.bottomAnchor),
            
            yearLabel.leadingAnchor.constraint(equalTo: yearOption.leadingAnchor),
            yearLabel.topAnchor.constraint(equalTo: yearOption.topAnchor),
            yearLabel.bottomAnchor.constraint(equalTo: yearOption.bottomAnchor),
        ])
    }
    
    @objc
    func optionTapped(_ sender: UIButton) {
        [dayOption, weekOption, monthOption, yearOption].forEach {
            $0.isSelected = false
        }
        
        sender.isSelected = true
    }
}
