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
    
    weak var delegate: ScheduleViewDelegate?
    
    let dayOption: UIButton!
    let weekOption: UIButton!
    let monthOption: UIButton!
    let yearOption: UIButton!
    
    private var selectedOption: UIButton?
    
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
        alignment = .fill
        spacing = 0
        translatesAutoresizingMaskIntoConstraints = false
        
        // Updated background color from your Palette #4
        backgroundColor = UIColor(Color(hex: 0xF5F3F0))
        layer.cornerRadius = 12
        layer.masksToBounds = false
        
        // Add subtle shadow
        layer.shadowColor = UIColor(Color(hex: 0xD1CCC6)).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.4
        
        // Create title section
        let titleView = createTitleView()
        addArrangedSubview(titleView)
        
        // Create option buttons
        let options = [
            ("Day", dayOption),
            ("Week", weekOption),
            ("Month", monthOption),
            ("Year", yearOption)
        ]
        
        for (title, button) in options {
            let optionView = createOptionView(title: title, button: button!)
            addArrangedSubview(optionView)
        }
        
        // Set default selection
        selectOption(weekOption)
    }
    
    private func createTitleView() -> UIView {
        let titleView = UIView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.backgroundColor = UIColor(Color(hex: 0xF5F3F0))
        titleView.layer.cornerRadius = 12
        
        let titleLabel = UILabel()
        titleLabel.text = "Calendar View"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.textColor = UIColor(Color(hex: 0x6D675F))
        
        titleView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -8),
            titleView.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        return titleView
    }
    
    private func createOptionView(title: String, button: UIButton) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        containerView.layer.cornerRadius = 8
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor(Color(hex: 0x544F47))
        label.translatesAutoresizingMaskIntoConstraints = false
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
        
        containerView.addSubview(button)
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            button.topAnchor.constraint(equalTo: containerView.topAnchor),
            button.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            containerView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return containerView
    }
    
    private func selectOption(_ button: UIButton) {
        // Reset all options
        [dayOption, weekOption, monthOption, yearOption].forEach { btn in
            btn?.superview?.backgroundColor = .clear
        }
        
        // Highlight selected option
        button.superview?.backgroundColor = UIColor(Color(hex: 0xE8E4E0))
        selectedOption = button
    }
    
    @objc
    func optionTapped(_ sender: UIButton) {
        selectOption(sender)
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Animate selection
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = CGAffineTransform.identity
                switch self.selectedOption {
                case self.dayOption:
                    self.delegate?.didRequestViewTypeChange(to: .day)
                case self.weekOption:
                    self.delegate?.didRequestViewTypeChange(to: .week)
                case self.monthOption:
                    self.delegate?.didRequestViewTypeChange(to: .month)
                case .none:
                    break
                case .some(_):
                    break
                }
            }
        }
    }
    
    // Public method to get selected option
    func getSelectedOption() -> String? {
        switch selectedOption {
        case dayOption: return "Day"
        case weekOption: return "Week"
        case monthOption: return "Month"
        case yearOption: return "Year"
        default: return nil
        }
    }
}
