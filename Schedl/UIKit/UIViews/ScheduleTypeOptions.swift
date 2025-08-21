//
//  ScheduleTypeOptions.swift
//  Schedl
//
//  Created by David Medina on 8/5/25.
//

import UIKit
import Foundation
import SwiftUI

class ScheduleTypeOptions: UIStackView {
    
    weak var delegate: ScheduleViewTypeDelegate?
    
    private var scheduleButtons: [UIButton] = []
    private var buttonToSchedule: [UIButton: Schedule] = [:]
    private var selectedSchedule: Schedule?
    
    private var optionButtons: [UIButton] = []
    private var buttonToBlend: [UIButton: Blend] = [:]
    private var selectedBlend: Blend?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI(userSchedules: [Schedule], userBlends: [Blend]) {
        print("Being reconfigured")
        
        // schedule is always the initially selected option between schedules and blends
        selectedSchedule = userSchedules.first!
        
        axis = .vertical
        distribution = .fillEqually
        alignment = .fill
        spacing = 0
        translatesAutoresizingMaskIntoConstraints = false
        
        // Remove existing arranged subviews
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        // Updated background color from your Palette #4
        backgroundColor = UIColor(Color(hex: 0xF5F3F0))
        layer.cornerRadius = 12
        layer.masksToBounds = false
        
        // Add subtle shadow
        layer.shadowColor = UIColor(Color(hex: 0xD1CCC6)).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.4
        
        // YOUR SCHEDULES SECTION
        let schedulesTitleView = createSectionTitleView(title: "Your Schedules")
        addArrangedSubview(schedulesTitleView)
        
        scheduleButtons.removeAll()
        buttonToSchedule.removeAll()
        
        for schedule in userSchedules {
            let button = UIButton()
            let optionView: UIView
            if selectedSchedule?.id == schedule.id {
                optionView = createOptionView(title: schedule.title, button: button, isSelected: true)
            } else {
                optionView = createOptionView(title: schedule.title, button: button, isSelected: false)
            }
            addArrangedSubview(optionView)
            buttonToSchedule[button] = schedule
            scheduleButtons.append(button)
        }
        
        // YOUR BLENDS SECTION
        let blendsTitleView = createSectionTitleView(title: "Your Blends")
        addArrangedSubview(blendsTitleView)
        
        optionButtons.removeAll()
        buttonToBlend.removeAll()
        
        for blend in userBlends {
            let button = UIButton()
            let optionView = createOptionView(title: blend.title, button: button, isSelected: false)
            addArrangedSubview(optionView)
            buttonToBlend[button] = blend
            optionButtons.append(button)
        }
    }
    
    private func createSectionTitleView(title: String) -> UIView {
        let titleView = UIView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.backgroundColor = UIColor(Color(hex: 0xF5F3F0))
        titleView.layer.cornerRadius = 12
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = UIColor(Color(hex: 0x6D675F))
        
        titleView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -8),
//            titleView.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        return titleView
    }
    
    private func createOptionView(title: String, button: UIButton, isSelected: Bool) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = isSelected ? UIColor(Color(hex: 0xE8E4E0)) : .clear
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
            
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
//            containerView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return containerView
    }
    
    private func selectOption(_ button: UIButton) {
        scheduleButtons.forEach { $0.superview?.backgroundColor = .clear }
        optionButtons.forEach { $0.superview?.backgroundColor = .clear }
        if let _ = buttonToSchedule[button] {
            // Button is a schedule button
            selectedBlend = nil
            
            button.superview?.backgroundColor = UIColor(Color(hex: 0xE8E4E0))
            selectedSchedule = buttonToSchedule[button]
            if let selectedSchedule = selectedSchedule {
                    delegate?.didRequestScheduleViewTypeChange(to: .schedule, id: selectedSchedule.id)
            }
        } else if let _ = buttonToBlend[button] {
            // Button is a blend button
            selectedSchedule = nil
            
            button.superview?.backgroundColor = UIColor(Color(hex: 0xE8E4E0))
            selectedBlend = buttonToBlend[button]
            if let selectedBlend = selectedBlend {
                    delegate?.didRequestScheduleViewTypeChange(to: .blend, id: selectedBlend.id)
            }
        }
        // If button not found in either dictionary, do nothing
    }
    
    @objc
    func optionTapped(_ sender: UIButton) {
        if let selectedSchedule = selectedSchedule {
            if selectedSchedule.id == buttonToSchedule[sender]?.id {
                return
            }
        }
        if let selectedBlend = selectedBlend {
            if selectedBlend.id == buttonToBlend[sender]?.id {
                return
            }
        }
        
        selectOption(sender)
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Animate selection
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
                // Notify delegate or handle selection
            }
        }
    }
    
    // Public method to get selected schedule
    func getSelectedSchedule() -> Schedule? {
        return selectedSchedule
    }
    
    // Public method to get selected blend
    func getSelectedBlend() -> Blend? {
        return selectedBlend
    }
}

