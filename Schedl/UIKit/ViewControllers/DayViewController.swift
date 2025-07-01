//
//  DayViewController.swift
//  Schedl
//
//  Created by David Medina on 6/29/25.
//

import UIKit
import SwiftUI
import Combine

class DayViewController: UIViewController {
    
    var coordinator: ScheduleView.Coordinator?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        view.backgroundColor = UIColor(Color(hex: 0xf7f4f2))
    }
    
//    private func setupViewModelObservation(viewModel: ScheduleViewModel) {
////        // Using Combine for reactive updates
//        viewModel.$scheduleEvents
//            .sink { [weak self] newEvents in
//                // Update UI when the scheduleItems changes
//                self?.updateEventsOverlay()
//            }
//            .store(in: &cancellables)
//        
//        viewModel.$isLoading
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] loading in
//                if loading {
//                    self?.showLoading()
//                } else {
//                    self?.hideLoading()
//                }
//            }
//            .store(in: &cancellables)
//        
//        viewModel.$userSchedule
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] maybeSchedule in
//                if let schedule = maybeSchedule {
//                    self?.showSchedule(schedule)
//                } else if maybeSchedule == nil && !viewModel.isLoading {
//                    self?.blankSchedule()
//                }
//            }
//          .store(in: &cancellables)
//    }
}
