//
//  CollectionViewTimesColumn.swift
//  Schedoolr
//
//  Created by David Medina on 2/20/25.
//

import UIKit
import SwiftUICore

// custom UILabel class that allows for deeper level of padding for text of a UILabel
class InsetLabel: UILabel {

    var contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: -87, right: 0)

    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: contentInsets)
        super.drawText(in: insetRect)
    }

    override var intrinsicContentSize: CGSize {
        return addInsets(to: super.intrinsicContentSize)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return addInsets(to: super.sizeThatFits(size))
    }

    func addInsets(to size: CGSize) -> CGSize {
        let width = size.width + contentInsets.left + contentInsets.right
        let height = size.height + contentInsets.top + contentInsets.bottom
        return CGSize(width: width, height: height)
    }

}

class TimeLabel: UIView {
    private let label: UILabel = {
        let label = InsetLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 12),
        ])
    }
    
    var text: String? {
        get { label.text }
        set { label.text = newValue }
    }
}

class CollectionViewTimesColumn: UIView {
    
    static let identifier = "TimeColumn"
    
    // using a stack view since all time cells will be vertically stacked on top of one another
    let stackView = UIStackView()
    
    // we've defined the frame dimensions in our view controller
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    // necessary initializer for class of type UICollectionReusableView
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.borderColor = UIColor.clear.cgColor
        stackView.backgroundColor = UIColor(Color(hex: 0xf7f4f2))
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Create time labels for each hour
        setupTimeLabels()
    }
    
    private func setupTimeLabels() {
        // Remove any existing labels
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let hoursList = [
            "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM", "10 AM", "11 AM", "12 PM",
            "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM", ""
        ]
        
        // Add a label for each hour (0-23)
        for hour in hoursList {
            let label = TimeLabel()
            label.text = hour
            stackView.addArrangedSubview(label)
        }
    }
}
