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
    
    weak var viewModel: ScheduleViewModel?
    weak var rootVC: UIViewController?
    
    var event: Event?
    let eventCell = UIButton()
    
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
        
        eventCell.configuration = .filled()
        eventCell.configuration?.baseBackgroundColor = UIColor(Color(hex: 0x3C859E))
        eventCell.configuration?.title = event.title
        eventCell.configuration?.titleAlignment = .center
        eventCell.translatesAutoresizingMaskIntoConstraints = false
        
        eventCell.addTarget(self, action: #selector(showEventDetails), for: .touchUpInside)
        
        addSubview(eventCell)
        
        NSLayoutConstraint.activate([
            eventCell.topAnchor.constraint(equalTo: topAnchor),
            eventCell.bottomAnchor.constraint(equalTo: bottomAnchor),
            eventCell.leadingAnchor.constraint(equalTo: leadingAnchor),
            eventCell.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        let shadowHeight: CGFloat = 8
//        let rect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowColor  = UIColor.black.cgColor
            shadowLayer.shadowOpacity = 0.7
            shadowLayer.shadowOffset  = CGSize(width: 0.0, height: 1.0)
            shadowLayer.shadowRadius = 3
            
            layer.insertSublayer(shadowLayer, at: 0)
        }
        
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
//        if bottomShadowLayer == nil && topShadowLayer == nil {
//            bottomShadowLayer = CAShapeLayer()
//            
//            bottomShadowLayer.path = UIBezierPath(roundedRect: bottomRect, cornerRadius: cornerRadius).cgPath
//            
//            bottomShadowLayer.shadowPath   = bottomShadowLayer.path
//            bottomShadowLayer.shadowColor  = UIColor.black.cgColor
//            bottomShadowLayer.shadowOpacity = 0.7
//            bottomShadowLayer.shadowOffset  = CGSize(width: 0.0, height: 4.0)
//            bottomShadowLayer.shadowRadius = 3
//            
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
//            layer.insertSublayer(bottomShadowLayer, at: 0)
//        }
    }
    
    @objc func showEventDetails() {
        
        guard let rootVC = rootVC, let viewModel = viewModel, let event = event else { return }
        
        let hostingController = UIHostingController(
            rootView: EventDetailsView(event: event)
                .environmentObject(viewModel)
        )
        
        hostingController.modalPresentationStyle = .fullScreen
        
        // will present it as a full screen page rather than trying to implement some voodoo method
        // to push our view onto the navigation stack defined in our root view from this VC (possibly hard)
        rootVC.present(hostingController, animated: true)
    }
}
