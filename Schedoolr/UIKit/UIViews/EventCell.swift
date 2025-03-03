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
        eventCell.configuration?.baseBackgroundColor = .systemTeal
        eventCell.configuration?.title = event.title
        eventCell.configuration?.titleAlignment = .center
        eventCell.translatesAutoresizingMaskIntoConstraints = false
        eventCell.layer.cornerRadius = 5
        
        eventCell.addTarget(self, action: #selector(showEventDetails), for: .touchUpInside)
        
        addSubview(eventCell)
        
        NSLayoutConstraint.activate([
            eventCell.topAnchor.constraint(equalTo: topAnchor),
            eventCell.bottomAnchor.constraint(equalTo: bottomAnchor),
            eventCell.leadingAnchor.constraint(equalTo: leadingAnchor),
            eventCell.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
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
