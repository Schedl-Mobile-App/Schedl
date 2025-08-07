//
//  MultiDayViewController.swift
//  Schedoolr
//
//  Created by David Medina on 3/13/25.
//

import UIKit
import SwiftUI
import Combine

enum ViewType {
    case day, week, month
}

enum ScheduleType {
    case schedule, blend
}

protocol ScheduleViewDelegate: AnyObject {
    func didRequestViewTypeChange(to viewType: ViewType)
}

protocol ScheduleViewTypeDelegate: AnyObject {
    func didRequestScheduleViewTypeChange(to scheduleType: ScheduleType, id: String)
}

class ScheduleViewController: UIViewController {
    
    var coordinator: ScheduleView.Coordinator?
    var currentViewType: ViewType = .week {
        didSet { switchViewType(type: currentViewType) }
    }
    var currentVC: UIViewController!
    var incomingVC: UIViewController!
    let filterButton = UIButton()
    let scheduleNameLabel = UILabel()
    let scheduleViewOptions = ScheduleViewOptions()
    let scheduleNameButton = UIButton()
    
    let scheduleViewTypeOptions = ScheduleTypeOptions()
    
    private var showScheduleOptions = false
    private var showScheduleNameEditor = false
    
    private var loadingHostingController: UIHostingController<ScheduleLoadingView>?
    private var cancellables: Set<AnyCancellable> = []
    let dayVC = DayViewController()
    let weekVC = WeekViewController()
    let monthVC = MonthViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let coordinator = coordinator {
            dayVC.coordinator = coordinator
            weekVC.coordinator = coordinator
        }
        
        configureUI()
    }
    
    func configureUI() {
        
        showLoading()
        
        if let scheduleViewModel = coordinator?.scheduleViewModel {
            setupModelObservation(scheduleViewModel: scheduleViewModel)
            loadInitialData(scheduleViewModel: scheduleViewModel)
        }
        
        
        
        filterButton.configuration = .filled()
        filterButton.configuration?.baseBackgroundColor = UIColor(Color(hex: 0xf7f4f2))
        filterButton.layer.borderWidth = 1.25
        filterButton.layer.borderColor = UIColor(Color(hex: 0x857F78)).cgColor
        filterButton.layer.cornerRadius = 10
        filterButton.configuration?.image = UIImage(systemName: "line.horizontal.3")
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        filterButton.addTarget(self, action: #selector(toggleOptions), for: .touchUpInside)
        filterButton.configuration?.baseForegroundColor = UIColor(Color(hex: 0x857F78))
        
        scheduleNameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        scheduleNameLabel.translatesAutoresizingMaskIntoConstraints = false
        scheduleNameLabel.textAlignment = .left
        scheduleNameLabel.textColor = UIColor(Color(hex: 0x544F47))
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleScheduleOptions))
        scheduleNameLabel.isUserInteractionEnabled = true
        scheduleNameLabel.addGestureRecognizer(tap)
        
        scheduleNameButton.translatesAutoresizingMaskIntoConstraints = false
        scheduleNameButton.configuration = .borderless()
        scheduleNameButton.configuration?.baseBackgroundColor = .clear
        scheduleNameButton.configuration?.image = UIImage(systemName: "chevron.down")
        scheduleNameButton.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        scheduleNameButton.addTarget(self, action: #selector(toggleScheduleOptions), for: .touchUpInside)
        scheduleNameButton.configuration?.baseForegroundColor = UIColor(Color(hex: 0x857F78))
        
        scheduleViewOptions.delegate = self
        scheduleViewOptions.isHidden = true
        
        scheduleViewTypeOptions.delegate = self
        scheduleViewTypeOptions.isHidden = true
        
        switch currentViewType {
        case .day:
            currentVC = dayVC
        case .week:
            currentVC = weekVC
        case .month:
            currentVC = monthVC
        }
        
        currentVC.edgesForExtendedLayout = [.bottom]
        currentVC.extendedLayoutIncludesOpaqueBars = true
                
        addChild(currentVC)
        view.addSubview(currentVC.view)
        currentVC.didMove(toParent: self)
        currentVC.view.translatesAutoresizingMaskIntoConstraints = false
                
        view.addSubview(filterButton)
        view.addSubview(scheduleNameLabel)
        view.addSubview(scheduleViewOptions)
        view.addSubview(scheduleNameButton)
        view.addSubview(scheduleViewTypeOptions)
        
        NSLayoutConstraint.activate([
            filterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            filterButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            filterButton.widthAnchor.constraint(equalToConstant: 30),
            filterButton.heightAnchor.constraint(equalToConstant: 30),
            
            scheduleNameLabel.leadingAnchor.constraint(equalTo: filterButton.trailingAnchor, constant: 10),
            scheduleNameLabel.centerYAnchor.constraint(equalTo: filterButton.centerYAnchor),
            
            scheduleNameButton.leadingAnchor.constraint(equalTo: scheduleNameLabel.layoutMarginsGuide.trailingAnchor),
            scheduleNameButton.centerYAnchor.constraint(equalTo: scheduleNameLabel.centerYAnchor),
            
            currentVC.view.topAnchor.constraint(equalTo: filterButton.bottomAnchor),
            currentVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            currentVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            currentVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scheduleViewOptions.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 5),
            scheduleViewOptions.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            scheduleViewOptions.widthAnchor.constraint(equalToConstant: 150),
            scheduleViewOptions.heightAnchor.constraint(equalToConstant: 175),
            
            scheduleViewTypeOptions.topAnchor.constraint(equalTo: scheduleNameLabel.bottomAnchor, constant: 5),
            scheduleViewTypeOptions.leadingAnchor.constraint(equalTo: scheduleNameLabel.layoutMarginsGuide.leadingAnchor, constant: 10),
            scheduleViewTypeOptions.widthAnchor.constraint(equalToConstant: 150),
            scheduleViewTypeOptions.heightAnchor.constraint(equalToConstant: 175),
            
        ])
    }
    
    func switchViewType(type: ViewType) {
        guard let currentVC = currentVC else { return }
            
        // remove the current displayed VC
        currentVC.willMove(toParent: nil)
        currentVC.view.removeFromSuperview()
        currentVC.removeFromParent()

        // determine which VC we are transitioning to
        let newVC: UIViewController
        switch type {
        case .day:
            newVC = dayVC
        case .week:
            newVC = weekVC
        case .month:
            newVC = monthVC
        }

        // add the new VC and it's view to the root VC
        addChild(newVC)
        view.addSubview(newVC.view)
        newVC.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            newVC.view.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 5),
            newVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        newVC.didMove(toParent: self)
        
        view.bringSubviewToFront(scheduleViewOptions)
        view.bringSubviewToFront(scheduleViewTypeOptions)
                
        // ensure that the current VC retains a reference to the newly added VC
        self.currentVC = newVC
    }
    
    @objc func toggleOptions() {
        spinButtonCABasic(filterButton)
        
        if showScheduleNameEditor && !showScheduleOptions {
            toggleScheduleOptions()
        }
        
        showScheduleOptions.toggle()
        
        if showScheduleOptions {
            scheduleViewOptions.isHidden = false
            UIView.animate(withDuration: 0.4) { [weak self] in
                self?.scheduleViewOptions.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.4, animations: { [weak self] in
                guard let self else { return }
                self.scheduleViewOptions.alpha = 0
            }, completion: { finished in
                self.scheduleViewOptions.isHidden = finished
            })
        }
    }
    
    @objc func toggleScheduleOptions() {
        
        if showScheduleOptions && !showScheduleNameEditor {
            toggleOptions()
        }
        
        showScheduleNameEditor.toggle()
        if showScheduleNameEditor {
            scheduleViewTypeOptions.isHidden = false
            UIView.animate(withDuration: 0.4) { [weak self] in
                guard let self else { return }
                self.scheduleNameButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                self.scheduleViewTypeOptions.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.4, animations: { [weak self] in
                guard let self else { return }
                self.scheduleViewTypeOptions.alpha = 0
                self.scheduleNameButton.transform = .identity
            }, completion: { finished in
                self.scheduleViewTypeOptions.isHidden = finished
            })
        }
    }
    
    func spinButtonCABasic(_ button: UIButton, duration: TimeInterval = 0.4) {
        if !showScheduleOptions {
            // Opening: rotate 90 degrees and change to X
            UIView.animate(withDuration: duration) {
                button.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
            }
            
            // Change image/colors at halfway point for smooth transition
            DispatchQueue.main.asyncAfter(deadline: .now() + duration / 2) {
                button.layer.borderWidth = 0
                button.configuration?.baseForegroundColor = UIColor(Color(hex: 0x3C372F))
                button.configuration?.image = UIImage(systemName: "xmark")
            }
        } else {
            // Closing: rotate back to 0 degrees and change to hamburger
            UIView.animate(withDuration: duration) {
                button.transform = CGAffineTransform.identity // Back to 0 degrees
            }
            
            // Change image/colors at halfway point for smooth transition
            DispatchQueue.main.asyncAfter(deadline: .now() + duration / 2) {
                button.layer.borderWidth = 1.25 // Your original border width
                button.configuration?.baseForegroundColor = UIColor(Color(hex: 0x857F78))
                button.configuration?.image = UIImage(systemName: "line.horizontal.3")
            }
        }
    }

    func showLoading() {
        if loadingHostingController == nil {
            let loadingVC = UIHostingController(rootView: ScheduleLoadingView())
            loadingVC.view.backgroundColor = .black
            loadingVC.view.frame = view.bounds
            loadingVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addChild(loadingVC)
            view.addSubview(loadingVC.view)
            view.bringSubviewToFront(loadingVC.view)
            loadingVC.didMove(toParent: self)
            loadingHostingController = loadingVC
        }
    }

    func hideLoading() {
        if let loadingVC = loadingHostingController {
            loadingVC.willMove(toParent: nil)
            loadingVC.view.removeFromSuperview()
            loadingVC.removeFromParent()
            loadingHostingController = nil
            
            self.placeholderLabel?.removeFromSuperview()
            self.placeholderLabel = nil
            self.placeholderBackground?.removeFromSuperview()
            self.placeholderBackground = nil
            self.createScheduleButton?.removeFromSuperview()
            self.createScheduleButton = nil
        }
    }
    
    func setupModelObservation(scheduleViewModel: ScheduleViewModel) {
        scheduleViewModel.$isLoading
            .combineLatest(scheduleViewModel.$userSchedules, scheduleViewModel.$userBlends)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading, userSchedules, userBlends in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                    if userSchedules.isEmpty {
                        self?.blankSchedule()
                    } else {
                        self?.scheduleViewTypeOptions.configureUI(userSchedules: userSchedules, userBlends: userBlends)
                    }
                }
            }
            .store(in: &cancellables)
        
        scheduleViewModel.$selectedSchedule
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedSchedule in
                guard let self = self else { return }
                if let selectedSchedule = selectedSchedule {
                    self.hideLoading()
                    self.scheduleNameLabel.text = selectedSchedule.title
                    self.view.bringSubviewToFront(self.scheduleNameLabel)
                }
            }
            .store(in: &cancellables)
        
        scheduleViewModel.$selectedBlend
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedBlend in
                if let selectedBlend = selectedBlend {
                    self?.hideLoading()
                    self?.scheduleNameLabel.text = selectedBlend.title
                }
            }
            .store(in: &cancellables)
    }
    
    func loadInitialData(scheduleViewModel: ScheduleViewModel) {
        Task {
            await scheduleViewModel.fetchSchedule()
        }
    }
    
    private var placeholderBackground: UIView?
    private var placeholderLabel: UILabel?
    private var createScheduleButton: UIButton?
    
    // your action to kick off creation
    @objc private func didTapCreateSchedule() {
        if let scheduleViewModel = coordinator?.scheduleViewModel {
            Task {
                let firstName = scheduleViewModel.currentUser.displayName.split(separator: " ").first ?? ""
                await scheduleViewModel.createSchedule(title: "\(firstName)'s Schedule")
            }
        }
    }

    func blankSchedule() {
        
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = UIColor(Color(hex: 0xf7f4f2))
        view.addSubview(backgroundView)
        
        // show placeholder
        let label = UILabel()
        label.text = "You don’t have a schedule yet!"
        label.font = .monospacedSystemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(Color(hex: 0x666666))
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        view.bringSubviewToFront(label)
        
        let button = UIButton()
        button.backgroundColor = UIColor(Color(hex: 0x3C859E))
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor(Color(hex: 0x333333)).cgColor
        button.setTitle("Create Schedule", for: .normal)
        button.setTitleColor(UIColor(Color(hex: 0xf7f4f2)), for: .normal)
        button.addTarget(self, action: #selector(didTapCreateSchedule), for: .touchUpInside)
        button.titleLabel?.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        view.bringSubviewToFront(button)
        
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 150),
            button.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        // keep strong refs so we can remove them later
        placeholderBackground   = backgroundView
        placeholderLabel        = label
        createScheduleButton    = button
    }
}

extension ScheduleViewController: ScheduleViewDelegate {
    func didRequestViewTypeChange(to viewType: ViewType) {
        if currentViewType != viewType {
            currentViewType = viewType
        }
    }
}

extension ScheduleViewController: ScheduleViewTypeDelegate {
    func didRequestScheduleViewTypeChange(to scheduleType: ScheduleType, id: String) {
        guard let scheduleViewModel = coordinator?.scheduleViewModel else { return }
        if scheduleType == .schedule {
            Task {
                await scheduleViewModel.fetchNewSchedule(id: id)
            }
        } else if scheduleType == .blend {
            Task {
                await scheduleViewModel.fetchBlendSchedule(id: id)
            }
        }
    }
}
