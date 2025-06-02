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
    
//    private var bottomShadowLayer: CAShapeLayer!
//    private var topShadowLayer: CAShapeLayer!
    private var shadowLayer: CAShapeLayer!
    private var cornerRadius: CGFloat = 10.0
    private var shadowBackgroundColor: UIColor!
    
    weak var viewModel: ScheduleViewModel?
    weak var rootVC: UIViewController?
    
    var event: Event?
    let eventCell = UIButton()
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI(viewModel: ScheduleViewModel, event: Event, rootVC: UIViewController) {
        
        self.viewModel = viewModel
        self.event = event
        self.rootVC = rootVC
        
        shadowBackgroundColor = UIColor(Color(hex: Int(event.color, radix: 16)!))
        
        eventCell.configuration = .filled()
        eventCell.configuration?.baseBackgroundColor = shadowBackgroundColor
        eventCell.translatesAutoresizingMaskIntoConstraints = false
        
        eventCell.addTarget(self, action: #selector(showEventDetails), for: .touchUpInside)
        
        addSubview(eventCell)
        
        titleLabel.text = event.title
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0 // Allow unlimited lines initially for calculation
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Calculate optimal font size based on content and available space
        let optimalFont = calculateOptimalFont(for: event.title, in: frame.size)
        titleLabel.font = optimalFont
        titleLabel.adjustsFontSizeToFitWidth = true

        // Set final number of lines based on height
        titleLabel.numberOfLines = calculateMaxLines(for: frame.height, fontSize: optimalFont.pointSize)
        
        eventCell.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            eventCell.topAnchor.constraint(equalTo: topAnchor),
            eventCell.bottomAnchor.constraint(equalTo: bottomAnchor),
            eventCell.leadingAnchor.constraint(equalTo: leadingAnchor),
            eventCell.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: eventCell.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: eventCell.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: eventCell.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: eventCell.trailingAnchor, constant: -4)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        full shadow
//        let shadowHeight: CGFloat = 8
//        let rect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
//        
//        if shadowLayer == nil {
//            shadowLayer = CAShapeLayer()
//            
//            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
//            
//            shadowLayer.shadowPath = shadowLayer.path
//            shadowLayer.shadowColor  = UIColor.black.cgColor
//            shadowLayer.shadowOpacity = 0.7
//            shadowLayer.shadowOffset  = CGSize(width: 0.0, height: 1.0)
//            shadowLayer.shadowRadius = 3
//            
//            layer.insertSublayer(shadowLayer, at: 0)
//        }
        
//        bottom shadow
//        let bottomRect = CGRect(
//            x: 0,
//            y: bounds.maxY - shadowHeight - 1,
//            width: bounds.width,
//            height: shadowHeight
//        )
//        let topRect = CGRect(
//            x: 0,
//            y: bounds.minY + 1,
//            width: bounds.width,
//            height: shadowHeight
//        )
//
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.backgroundColor = shadowBackgroundColor.cgColor
            
            shadowLayer.shadowPath   = shadowLayer.path
            shadowLayer.shadowColor  = UIColor.black.cgColor
            shadowLayer.shadowOpacity = 0.20
            shadowLayer.shadowOffset  = CGSize(width: 0.0, height: 4.0)
            shadowLayer.shadowRadius = 3
            
//            topShadowLayer = CAShapeLayer()
//            
//            topShadowLayer.path = UIBezierPath(roundedRect: topRect, cornerRadius: cornerRadius).cgPath
//            
//            topShadowLayer.shadowPath   = topShadowLayer.path
//            topShadowLayer.shadowColor  = UIColor.black.cgColor
//            topShadowLayer.shadowOpacity = 0.7
//            topShadowLayer.shadowOffset  = CGSize(width: 0.0, height: -4.0)
//            topShadowLayer.shadowRadius = 3
//            
//            layer.insertSublayer(topShadowLayer, at: 0)
            layer.insertSublayer(shadowLayer, at: 0)
        }
    }
    
    @objc func showEventDetails() {
        
        guard let rootVC = rootVC, let viewModel = viewModel, let event = event else { return }
        
        let hostingController = UIHostingController(
            rootView: EventDetailsView(event: event, currentUser: viewModel.currentUser)
        )
        
        hostingController.modalPresentationStyle = .fullScreen
        
        // will present it as a full screen page rather than trying to implement some voodoo method
        // to push our view onto the navigation stack defined in our root view from this VC (possibly hard)
        rootVC.present(hostingController, animated: true)
    }
    
//    func convertHexStringToInt(colorCode: String) -> Int {
//        if let value = hexString
//    }
    
    private func calculateOptimalFont(for text: String, in size: CGSize) -> UIFont {
        let availableHeight = size.height - 8 // Account for padding
        let availableWidth = size.width - 8
        
        // Start with base font size
        var fontSize = calculateOptimalFontSize(for: size.height)
        
        while fontSize > 8 { // Minimum readable size
            let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
            let attributes = [NSAttributedString.Key.font: font]
            
            // Calculate text size with current font
            let textSize = text.boundingRect(
                with: CGSize(width: availableWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: attributes,
                context: nil
            ).size
            
            // Calculate number of lines needed
            let linesNeeded = ceil(textSize.height / font.lineHeight)
            let totalHeight = linesNeeded * font.lineHeight
            
            // If text fits, use this font size
            if totalHeight <= availableHeight {
                return font
            }
            
            // Reduce font size and try again
            fontSize -= 1
        }
        
        return UIFont.systemFont(ofSize: 8, weight: .bold)
    }

    private func calculateMaxLines(for height: CGFloat, fontSize: CGFloat) -> Int {
        let lineHeight = UIFont.systemFont(ofSize: fontSize, weight: .bold).lineHeight
        let availableHeight = height - 8 // Account for padding
        return max(1, Int(availableHeight / lineHeight))
    }

    private func calculateOptimalFontSize(for height: CGFloat) -> CGFloat {
        switch height {
        case 0..<30:
            return 10
        case 30..<50:
            return 11
        case 50..<80:
            return 12
        default:
            return 13
        }
    }
}
