////
////  EventCell.swift
////  Schedoolr
////
////  Created by David Medina on 3/1/25.
////
//
//import UIKit
//import SwiftUI
//import Combine
//
//class EventCell: UIView {
//    
//    private var shadowLayer: CAShapeLayer!
//    private var cornerRadius: CGFloat = 8.0
//    private var shadowBackgroundColor: UIColor!
//    
//    weak var viewModel: ScheduleViewModel?
//    weak var rootVC: UIViewController?
//    
//    var onSelectEvent: ((RecurringEvents) -> Void)?
//    
//    var event: RecurringEvents?
//    let glassContainer = UIVisualEffectView()
//    let eventCell = UIButton(type: .custom)
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        registerForTraitChanges([UITraitUserInterfaceStyle.self], action: #selector(updateColorsForCurrentAppearance))
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func configureUI(event: RecurringEvents) {
//        
//        self.event = event
//        
//        if traitCollection.userInterfaceStyle == .dark {
//            shadowBackgroundColor = UIColor(Color(hex: Int(event.event.color, radix: 16)!)).withBrightnessAdjusted(by: 0.675)
//        } else {
//            shadowBackgroundColor = UIColor(Color(hex: Int(event.event.color, radix: 16)!))
//                .withBrightnessAdjusted(by: 0.875)
//        }
//        
//        if #available(iOS 26.0, *) {
//            
//            glassContainer.translatesAutoresizingMaskIntoConstraints = false
//            glassContainer.backgroundColor = shadowBackgroundColor
//            glassContainer.cornerRadiusV = cornerRadius
//            
//            addSubview(glassContainer)
//                        
//            NSLayoutConstraint.activate([
//                glassContainer.topAnchor.constraint(equalTo: topAnchor),
//                glassContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
//                glassContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
//                glassContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
//            ])
//            
//            eventCell.configuration = .clearGlass()
//            eventCell.configuration?.cornerStyle = .fixed
//            eventCell.configuration?.background.cornerRadius = cornerRadius
//            eventCell.translatesAutoresizingMaskIntoConstraints = false
//            
//            let titleLabel = UILabel()
//            let startTimeLabel = UILabel()
//            let endTimeLabel = UILabel()
//            let shortenedTimeLabel = UILabel()
//            
//            glassContainer.contentView.addSubview(eventCell)
//            
//            NSLayoutConstraint.activate([
//                eventCell.topAnchor.constraint(equalTo: glassContainer.topAnchor),
//                eventCell.bottomAnchor.constraint(equalTo: glassContainer.bottomAnchor),
//                eventCell.leadingAnchor.constraint(equalTo: glassContainer.leadingAnchor),
//                eventCell.trailingAnchor.constraint(equalTo: glassContainer.trailingAnchor)
//            ])
//            
//            eventCell.addTarget(self, action: #selector(showEventDetails), for: .touchUpInside)
//            
//            let startTimeText = "\(Date.convertHourAndMinuteToDate(time: event.event.startTime).formatted(date: .omitted, time: .shortened))-"
//            let endTimeText = "\(Date.convertHourAndMinuteToDate(time: event.event.endTime).formatted(date: .omitted, time: .shortened))"
//            
//            titleLabel.text = event.event.title
//            titleLabel.textAlignment = .left
//            titleLabel.backgroundColor = .clear
//            titleLabel.numberOfLines = 0
//            titleLabel.textColor = UIColor(Color(hex: 0xf7f4f2))
//            titleLabel.translatesAutoresizingMaskIntoConstraints = false
//            titleLabel.font = UIFont.systemFont(ofSize: 10, weight: .heavy)
//            titleLabel.adjustsFontSizeToFitWidth = true
//            titleLabel.numberOfLines = calculateMaxLines(for: frame.height, fontWeight: .heavy)
//            
//            glassContainer.contentView.addSubview(titleLabel)
//            
//            startTimeLabel.text = startTimeText
//            startTimeLabel.textAlignment = .left
//            startTimeLabel.textColor = UIColor(Color(hex: 0xf7f4f2))
//            startTimeLabel.backgroundColor = .clear
//            startTimeLabel.translatesAutoresizingMaskIntoConstraints = false
//            startTimeLabel.font = UIFont.systemFont(ofSize: 9, weight: .bold)
//            
//            endTimeLabel.text = endTimeText
//            endTimeLabel.textAlignment = .left
//            endTimeLabel.textColor = UIColor(Color(hex: 0xf7f4f2))
//            endTimeLabel.backgroundColor = .clear
//            endTimeLabel.translatesAutoresizingMaskIntoConstraints = false
//            endTimeLabel.font = UIFont.systemFont(ofSize: 9, weight: .bold)
//            
//            shortenedTimeLabel.text = startTimeText + endTimeText
//            shortenedTimeLabel.textAlignment = .left
//            shortenedTimeLabel.textColor = UIColor(Color(hex: 0xf7f4f2))
//            shortenedTimeLabel.backgroundColor = .clear
//            shortenedTimeLabel.numberOfLines = 1
//            shortenedTimeLabel.translatesAutoresizingMaskIntoConstraints = false
//            shortenedTimeLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
//            shortenedTimeLabel.adjustsFontSizeToFitWidth = true
//            
//            let spacingBetweenTitleAndStartTime: CGFloat = frame.size.height < 75 ? 1 : 3
//            let spacingBetweenTimes: CGFloat = frame.size.height <= 75 ? -3 : -1
//            
//            let hideTimeLabels = frame.size.height > 40
//            startTimeLabel.isHidden = !hideTimeLabels
//            endTimeLabel.isHidden = !hideTimeLabels
//            let topPadding = CGFloat(hideTimeLabels ? 5 : 2)
//            
//            shortenedTimeLabel.isHidden = hideTimeLabels
//            
//            glassContainer.contentView.addSubview(startTimeLabel)
//            glassContainer.contentView.addSubview(endTimeLabel)
//            glassContainer.contentView.addSubview(shortenedTimeLabel)
//            
//            NSLayoutConstraint.activate([
//                titleLabel.leadingAnchor.constraint(equalTo: glassContainer.leadingAnchor, constant: 2),
//                titleLabel.trailingAnchor.constraint(equalTo: glassContainer.trailingAnchor, constant: -2),
//                titleLabel.topAnchor.constraint(equalTo: glassContainer.topAnchor, constant: topPadding),
//                
//                startTimeLabel.leadingAnchor.constraint(equalTo: glassContainer.leadingAnchor, constant: 2),
//                startTimeLabel.trailingAnchor.constraint(equalTo: glassContainer.trailingAnchor, constant: -2),
//                startTimeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: spacingBetweenTitleAndStartTime),
//                
//                endTimeLabel.leadingAnchor.constraint(equalTo: glassContainer.leadingAnchor, constant: 2),
//                endTimeLabel.trailingAnchor.constraint(equalTo: glassContainer.trailingAnchor, constant: -2),
//                endTimeLabel.topAnchor.constraint(equalTo: startTimeLabel.bottomAnchor, constant: spacingBetweenTimes),
//                
//                shortenedTimeLabel.leadingAnchor.constraint(equalTo: glassContainer.leadingAnchor, constant: 2),
//                shortenedTimeLabel.trailingAnchor.constraint(equalTo: glassContainer.trailingAnchor, constant: -2),
//                shortenedTimeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -2),
//            ])
//            
//        } else {
//            
//            eventCell.configuration = .filled()
//            eventCell.configuration?.baseBackgroundColor = shadowBackgroundColor
//            eventCell.configuration?.cornerStyle = .fixed
//            eventCell.configuration?.background.cornerRadius = cornerRadius
//            eventCell.translatesAutoresizingMaskIntoConstraints = false
//            addSubview(eventCell)
//            
//            NSLayoutConstraint.activate([
//                eventCell.topAnchor.constraint(equalTo: topAnchor),
//                eventCell.bottomAnchor.constraint(equalTo: bottomAnchor),
//                eventCell.leadingAnchor.constraint(equalTo: leadingAnchor),
//                eventCell.trailingAnchor.constraint(equalTo: trailingAnchor)
//            ])
//            
//            eventCell.addTarget(self, action: #selector(showEventDetails), for: .touchUpInside)
//            
//            let startTimeText = "\(Date.convertHourAndMinuteToDate(time: event.event.startTime).formatted(date: .omitted, time: .shortened))-"
//            let endTimeText = "\(Date.convertHourAndMinuteToDate(time: event.event.endTime).formatted(date: .omitted, time: .shortened))"
//            
//            let titleLabel = UILabel()
//            let startTimeLabel = UILabel()
//            let endTimeLabel = UILabel()
//            let shortenedTimeLabel = UILabel()
//            
//            titleLabel.text = event.event.title
//            titleLabel.textAlignment = .left
//            titleLabel.backgroundColor = .clear
//            titleLabel.numberOfLines = 0
//            titleLabel.textColor = UIColor(Color(hex: 0xf7f4f2))
//            titleLabel.translatesAutoresizingMaskIntoConstraints = false
//            titleLabel.font = UIFont.systemFont(ofSize: 10, weight: .heavy)
//            titleLabel.adjustsFontSizeToFitWidth = true
//            titleLabel.numberOfLines = calculateMaxLines(for: frame.height, fontWeight: .heavy)
//            
//            eventCell.addSubview(titleLabel)
//            
//            startTimeLabel.text = startTimeText
//            startTimeLabel.textAlignment = .left
//            startTimeLabel.textColor = UIColor(Color(hex: 0xf7f4f2))
//            startTimeLabel.backgroundColor = .clear
//            startTimeLabel.translatesAutoresizingMaskIntoConstraints = false
//            startTimeLabel.font = UIFont.systemFont(ofSize: 9, weight: .bold)
//            
//            endTimeLabel.text = endTimeText
//            endTimeLabel.textAlignment = .left
//            endTimeLabel.textColor = UIColor(Color(hex: 0xf7f4f2))
//            endTimeLabel.backgroundColor = .clear
//            endTimeLabel.translatesAutoresizingMaskIntoConstraints = false
//            endTimeLabel.font = UIFont.systemFont(ofSize: 9, weight: .bold)
//            
//            shortenedTimeLabel.text = startTimeText + endTimeText
//            shortenedTimeLabel.textAlignment = .left
//            shortenedTimeLabel.textColor = UIColor(Color(hex: 0xf7f4f2))
//            shortenedTimeLabel.backgroundColor = .clear
//            shortenedTimeLabel.numberOfLines = 1
//            shortenedTimeLabel.translatesAutoresizingMaskIntoConstraints = false
//            shortenedTimeLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
//            shortenedTimeLabel.adjustsFontSizeToFitWidth = true
//            
//            let spacingBetweenTitleAndStartTime: CGFloat = frame.size.height < 75 ? 1 : 3
//            let spacingBetweenTimes: CGFloat = frame.size.height <= 75 ? -3 : -1
//            
//            let hideTimeLabels = frame.size.height > 40
//            startTimeLabel.isHidden = !hideTimeLabels
//            endTimeLabel.isHidden = !hideTimeLabels
//            let topPadding = CGFloat(hideTimeLabels ? 5 : 2)
//            
//            shortenedTimeLabel.isHidden = hideTimeLabels
//            
//            eventCell.addSubview(startTimeLabel)
//            eventCell.addSubview(endTimeLabel)
//            eventCell.addSubview(shortenedTimeLabel)
//            
//            NSLayoutConstraint.activate([
//                titleLabel.leadingAnchor.constraint(equalTo: eventCell.leadingAnchor, constant: 2),
//                titleLabel.trailingAnchor.constraint(equalTo: eventCell.trailingAnchor, constant: -2),
//                titleLabel.topAnchor.constraint(equalTo: eventCell.topAnchor, constant: topPadding),
//                
//                startTimeLabel.leadingAnchor.constraint(equalTo: eventCell.leadingAnchor, constant: 2),
//                startTimeLabel.trailingAnchor.constraint(equalTo: eventCell.trailingAnchor, constant: -2),
//                startTimeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: spacingBetweenTitleAndStartTime),
//                
//                endTimeLabel.leadingAnchor.constraint(equalTo: eventCell.leadingAnchor, constant: 2),
//                endTimeLabel.trailingAnchor.constraint(equalTo: eventCell.trailingAnchor, constant: -2),
//                endTimeLabel.topAnchor.constraint(equalTo: startTimeLabel.bottomAnchor, constant: spacingBetweenTimes),
//                
//                shortenedTimeLabel.leadingAnchor.constraint(equalTo: eventCell.leadingAnchor, constant: 2),
//                shortenedTimeLabel.trailingAnchor.constraint(equalTo: eventCell.trailingAnchor, constant: -2),
//                shortenedTimeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -2),
//            ])
//        }
//    }
//
//    @objc private func updateColorsForCurrentAppearance() {
//        guard let event = self.event else { return }
//        
//        if #available(iOS 26.0, *) {
//            let base = UIColor(Color(hex: Int(event.event.color, radix: 16)!))
//            
//            let adjusted: UIColor
//            if traitCollection.userInterfaceStyle == .dark {
//                adjusted = base.withBrightnessAdjusted(by: 0.675)
//            } else {
//                adjusted = base.withBrightnessAdjusted(by: 0.875)
//            }
//            
//            glassContainer.backgroundColor = adjusted
//        } else {
//            let base = UIColor(Color(hex: Int(event.event.color, radix: 16)!))
//            
//            let adjusted: UIColor
//            if traitCollection.userInterfaceStyle == .dark {
//                adjusted = base.withBrightnessAdjusted(by: 0.675)
//            } else {
//                adjusted = base.withBrightnessAdjusted(by: 0.875)
//            }
//            
//            eventCell.configuration?.baseBackgroundColor = adjusted
//        }
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//            if shadowLayer == nil {
//                shadowLayer = CAShapeLayer()
//                
//                shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
//                shadowLayer.fillColor = UIColor.clear.cgColor
//                
//                shadowLayer.shadowPath = shadowLayer.path
//                shadowLayer.shadowColor = UIColor.black.cgColor
//                shadowLayer.shadowOpacity = 0.20
//                shadowLayer.shadowOffset = CGSize(width: 0, height: 4.0)
//                shadowLayer.shadowRadius = 3
//                
//                layer.insertSublayer(shadowLayer, at: .zero)
//            }
//    }
//    
//    @objc func showEventDetails(_ sender: UIButton) {
//        guard let event = event else { return }
//        self.onSelectEvent?(event)
//    }
//    
//    private func calculateMaxLines(for height: CGFloat, fontSize: CGFloat = 10, fontWeight: UIFont.Weight) -> Int {
//        let lineHeight = UIFont.systemFont(ofSize: fontSize, weight: fontWeight).lineHeight
//        let availableHeight = height - 4
//        
//        switch Int(availableHeight) {
//        case  ..<50:
//            return 2
//        default:
//            return max(1, Int(availableHeight / lineHeight))
//        }
//    }
//}
//
//extension UIColor {
//    func withBrightnessAdjusted(by factor: CGFloat) -> UIColor {
//        var hue: CGFloat = 0
//        var saturation: CGFloat = 0
//        var brightness: CGFloat = 0
//        var alpha: CGFloat = 0
//
//        guard getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
//            return self
//        }
//
//        let newBrightness = min(max(brightness * factor, 0), 1)
//
//        return UIColor(
//            hue: hue,
//            saturation: saturation,
//            brightness: newBrightness,
//            alpha: alpha
//        )
//    }
//}
//
