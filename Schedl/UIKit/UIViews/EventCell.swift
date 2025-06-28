//
//  EventCell.swift
//  Schedoolr
//
//  Created by David Medina on 3/1/25.
//

import UIKit
import SwiftUI
import Combine

class EventCell: UIView {
    
    private var shadowLayer: CAShapeLayer!
    private var cornerRadius: CGFloat = 5.0
    private var shadowBackgroundColor: UIColor!
    
    weak var viewModel: ScheduleViewModel?
    weak var rootVC: UIViewController?
    
    var onSelectEvent: ((RecurringEvents) -> Void)?
    
    var event: RecurringEvents?
    let eventCell = UIButton(type: .custom)
    let titleLabel = UILabel()
    let startTimeLabel = UILabel()
    let endTimeLabel = UILabel()
    let shortenedTimeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI(event: RecurringEvents) {
        
        self.event = event
        
//        EventCell.performWithoutAnimation {
//            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
//            layer.shadowColor = UIColor(Color.black).cgColor
//            layer.shadowOpacity = 0.2
//            layer.shadowOffset = CGSize(width: 1, height: 4)
//            layer.shouldRasterize = true
//            layer.rasterizationScale = UIScreen.main.scale
//        }
        
        shadowBackgroundColor = UIColor(Color(hex: Int(event.event.color, radix: 16)!))
        
        eventCell.translatesAutoresizingMaskIntoConstraints = false
        eventCell.backgroundColor = shadowBackgroundColor
        eventCell.layer.cornerRadius = cornerRadius
                
        eventCell.addTarget(self, action: #selector(showEventDetails), for: .touchUpInside)
        
        addSubview(eventCell)
        
        let startTimeText = "\(Date.convertHourAndMinuteToDate(time: event.event.startTime).formatted(date: .omitted, time: .shortened))-"
        let endTimeText = "\(Date.convertHourAndMinuteToDate(time: event.event.endTime).formatted(date: .omitted, time: .shortened))"
        
        // title label for the event
        titleLabel.text = event.event.title
        titleLabel.textAlignment = .left
        titleLabel.backgroundColor = .clear
        titleLabel.numberOfLines = 0                                    // allow the label to determine the number of lines
        titleLabel.textColor = UIColor(Color(hex: 0xf7f4f2))
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 10, weight: .heavy)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = calculateMaxLines(for: frame.height, fontWeight: .heavy)
        
        eventCell.addSubview(titleLabel)
                
        // start time label for the event
        startTimeLabel.text = startTimeText
        startTimeLabel.textAlignment = .left
        startTimeLabel.textColor = UIColor(Color(hex: 0xf7f4f2))
        startTimeLabel.backgroundColor = .clear
        startTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        startTimeLabel.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        
        // end time label for the event
        endTimeLabel.text = endTimeText
        endTimeLabel.textAlignment = .left
        endTimeLabel.textColor = UIColor(Color(hex: 0xf7f4f2))
        endTimeLabel.backgroundColor = .clear
        endTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        endTimeLabel.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        
        // single lined time label for really short events
        shortenedTimeLabel.text = startTimeText + endTimeText
        shortenedTimeLabel.textAlignment = .left
        shortenedTimeLabel.textColor = UIColor(Color(hex: 0xf7f4f2))
        shortenedTimeLabel.backgroundColor = .clear
        shortenedTimeLabel.numberOfLines = 1
        shortenedTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        shortenedTimeLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        shortenedTimeLabel.adjustsFontSizeToFitWidth = true
                
        let spacingBetweenTitleAndStartTime: CGFloat = frame.size.height < 75 ? 1 : 3
        let spacingBetweenTimes: CGFloat = frame.size.height <= 75 ? -3 : -1
                    
        // hide the multi-line time labels for a fixed height threshold
        let hideTimeLabels = frame.size.height > 40
        startTimeLabel.isHidden = !hideTimeLabels
        endTimeLabel.isHidden = !hideTimeLabels
        let topPadding = CGFloat(hideTimeLabels ? 5 : 2)
        
        // show the single line time label when height is less than the above value
        shortenedTimeLabel.isHidden = hideTimeLabels

        eventCell.addSubview(startTimeLabel)
        eventCell.addSubview(endTimeLabel)
        eventCell.addSubview(shortenedTimeLabel)
        
        NSLayoutConstraint.activate([
            eventCell.topAnchor.constraint(equalTo: topAnchor),
            eventCell.bottomAnchor.constraint(equalTo: bottomAnchor),
            eventCell.leadingAnchor.constraint(equalTo: leadingAnchor),
            eventCell.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: eventCell.leadingAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: eventCell.trailingAnchor, constant: -2),
            titleLabel.topAnchor.constraint(equalTo: eventCell.topAnchor, constant: topPadding),
            
            startTimeLabel.leadingAnchor.constraint(equalTo: eventCell.leadingAnchor, constant: 2),
            startTimeLabel.trailingAnchor.constraint(equalTo: eventCell.trailingAnchor, constant: -2),
            startTimeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: spacingBetweenTitleAndStartTime),
            
            endTimeLabel.leadingAnchor.constraint(equalTo: eventCell.leadingAnchor, constant: 2),
            endTimeLabel.trailingAnchor.constraint(equalTo: eventCell.trailingAnchor, constant: -2),
            endTimeLabel.topAnchor.constraint(equalTo: startTimeLabel.bottomAnchor, constant: spacingBetweenTimes),
            
            shortenedTimeLabel.leadingAnchor.constraint(equalTo: eventCell.leadingAnchor, constant: 2),
            shortenedTimeLabel.trailingAnchor.constraint(equalTo: eventCell.trailingAnchor, constant: -2),
            shortenedTimeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -2),
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = UIColor.clear.cgColor

            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowOpacity = 0.20
            shadowLayer.shadowOffset = CGSize(width: 0, height: 4.0)
            shadowLayer.shadowRadius = 3
            
            layer.insertSublayer(shadowLayer, at: .zero)
        }
    }
    
    @objc func showEventDetails() {
        guard let event = event else { return }
        self.onSelectEvent?(event)
    }
    
    private func calculateMaxLines(for height: CGFloat, fontSize: CGFloat = 10, fontWeight: UIFont.Weight) -> Int {
        let lineHeight = UIFont.systemFont(ofSize: fontSize, weight: fontWeight).lineHeight
        let availableHeight = height - 4 // Account for padding
        
        switch Int(availableHeight) {
        case  ..<50:
            return 2
        default:
            return max(1, Int(availableHeight / lineHeight))
        }
    }
}

extension UIColor {
    /// Returns a color with its brightness adjusted by the given factor.
    /// - Parameter factor: Multiplier for brightness (e.g. 1.2 = 20% brighter, 0.8 = 20% darker).
    func withBrightnessAdjusted(by factor: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        // Extract HSB components; fallback to original if unavailable
        guard getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return self
        }

        // Clamp brightness to [0,1]
        let newBrightness = min(max(brightness * factor, 0), 1)

        return UIColor(
            hue: hue,
            saturation: saturation,
            brightness: newBrightness,
            alpha: alpha
        )
    }
}

