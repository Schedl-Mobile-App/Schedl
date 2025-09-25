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
    
    var name: String {
        switch self {
        case .day: return "Day"
        case .week: return "Week"
        case .month: return "Month"
        }
    }
    
    var symbolName: String {
        switch self {
        case .day: return "calendar.day.timeline.trailing"
        case .week: return "circle.hexagongrid"
        case .month: return "calendar"
        }
    }
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

protocol ScheduleViewMenuDelegate: AnyObject {
    func closeMenus()
}

class ScheduleViewController: UIViewController {
    
    var coordinator: ScheduleView.Coordinator?
    var currentViewType: ViewType = .week {
        didSet { switchViewType(type: currentViewType) }
    }
    var currentVC: UIViewController!
    var incomingVC: UIViewController!
    
    let scheduleTitleView = UIView()
    let scheduleTitleButton = UIButton()
    
    let calendarTypeView = UIView()
    let calendarTypeButton = UIButton()
        
    private var showScheduleOptions = false
    private var showScheduleNameEditor = false
    
    private var loadingHostingController: UIHostingController<ScheduleLoadingView>?
    private var cancellables: Set<AnyCancellable> = []
    let dayVC = DayViewController()
    
    let weekVC = WeekViewController()
    
    let monthVC = MonthViewController()
    let scheduleNameBarButton = UIBarButtonItem()
    
    // Build a base menu; we’ll also rebuild dynamically via context menu actionProvider
    lazy var calendarTypeMenu: UIMenu = {
        buildCalendarTypeMenu()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let coordinator = coordinator {
            dayVC.coordinator = coordinator
            weekVC.coordinator = coordinator
        }
                    
        weekVC.delegate = self
        
        // Once in viewDidLoad or configureUI:
        addChild(dayVC); addChild(weekVC); addChild(monthVC)
        for vc in [dayVC, weekVC, monthVC] {
            view.addSubview(vc.view)
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                vc.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                vc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            vc.didMove(toParent: self)
            vc.view.isHidden = true
        }

        // Then switch with:
        dayVC.view.isHidden = true
        weekVC.view.isHidden = false
        monthVC.view.isHidden = true
//        currentVC = weekVC
        
        configureUI()
        
        guard let navigationController = self.navigationController else { return }
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.configureWithTransparentBackground()
        navigationController.navigationBar.standardAppearance = navBarAppearance
        navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController.navigationBar.compactAppearance = navBarAppearance
        
        let tabBarAppearance = UITabBarAppearance()
        
        tabBarAppearance.configureWithTransparentBackground()
        navigationController.tabBarController?.tabBar.standardAppearance = tabBarAppearance
        navigationController.tabBarController?.tabBar.scrollEdgeAppearance = tabBarAppearance
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let tabBarState = coordinator?.tabBarState {
            tabBarState.hideTabbar = false
        }
    }
    
    func configureUI() {
        
        showLoading()
        
        view.backgroundColor = UIColor(Color("BackgroundColor"))
        
        if let scheduleViewModel = coordinator?.scheduleViewModel {
            setupModelObservation(scheduleViewModel: scheduleViewModel)
            loadInitialData(scheduleViewModel: scheduleViewModel)
        }
        
        calendarTypeView.addSubview(calendarTypeButton)
        calendarTypeButton.tintColor = UIColor(Color("NavItemsColors"))
        calendarTypeButton.menu = calendarTypeMenu
        calendarTypeButton.showsMenuAsPrimaryAction = true

        // Set up the image
        if #available(iOS 26.0, *) {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
            let image = UIImage(systemName: "ellipsis.calendar", withConfiguration: symbolConfig)
            calendarTypeButton.setImage(image, for: .normal)
        } else {
            calendarTypeButton.configurationUpdateHandler = { [weak self] button in
                var config = button.configuration ?? .borderless()
                    config.imagePlacement = .trailing
                    config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)

                    let showingX = button.isHighlighted
                    let targetImage = UIImage(systemName: showingX ? "xmark" : "ellipsis")
                    config.image = targetImage

                    // Use the built-in symbol transition
                    UIView.transition(with: button, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                        self?.calendarTypeButton.configuration = config
                    }, completion: nil)
            }
        }
        
        scheduleTitleView.addSubview(scheduleTitleButton)
        scheduleTitleButton.showsMenuAsPrimaryAction = true
        
        if #available(iOS 26.0, *) {
        } else {
            scheduleTitleButton.configurationUpdateHandler = { [weak self] button in
                var config = button.configuration ?? .borderless()
                let symbolName = "chevron.down"
                config.image = UIImage(systemName: symbolName)
                config.imagePlacement = .trailing
                config.imagePadding = 5
                config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
                self?.scheduleTitleButton.configuration = config
                
                let targetAngle: CGFloat = button.isHighlighted ? .pi : 0

                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                    button.imageView?.transform = CGAffineTransform(rotationAngle: targetAngle)
                }, completion: nil)
            }
        }
        
        calendarTypeView.translatesAutoresizingMaskIntoConstraints = false
        calendarTypeButton.translatesAutoresizingMaskIntoConstraints = false
        
        scheduleTitleView.translatesAutoresizingMaskIntoConstraints = false
        scheduleTitleButton.translatesAutoresizingMaskIntoConstraints = false

        // Optional: improve intrinsic sizing behavior for the container
        calendarTypeView.setContentHuggingPriority(.required, for: .horizontal)
        calendarTypeView.setContentCompressionResistancePriority(.required, for: .horizontal)

        // Constrain label and button inside the container
        if #available(iOS 26.0, *) {
            NSLayoutConstraint.activate([
                
                calendarTypeView.heightAnchor.constraint(equalToConstant: 36),
                
                calendarTypeButton.leadingAnchor.constraint(equalTo: calendarTypeView.leadingAnchor),
                calendarTypeButton.trailingAnchor.constraint(equalTo: calendarTypeView.trailingAnchor),
                calendarTypeButton.centerYAnchor.constraint(equalTo: calendarTypeView.centerYAnchor),
                
                scheduleTitleView.heightAnchor.constraint(equalToConstant: 36),
                
                // Layout: [Label] -8- [Button] - leading/trailing padding
                scheduleTitleButton.leadingAnchor.constraint(equalTo: scheduleTitleView.leadingAnchor, constant: 8),
                scheduleTitleButton.trailingAnchor.constraint(equalTo: scheduleTitleView.trailingAnchor, constant: -8),
                scheduleTitleButton.centerYAnchor.constraint(equalTo: scheduleTitleView.centerYAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                
                calendarTypeView.heightAnchor.constraint(equalToConstant: 36),
                
                calendarTypeButton.leadingAnchor.constraint(equalTo: calendarTypeView.leadingAnchor),
                calendarTypeButton.trailingAnchor.constraint(equalTo: calendarTypeView.trailingAnchor, constant: 8),
                calendarTypeButton.centerYAnchor.constraint(equalTo: calendarTypeView.centerYAnchor),
                
                scheduleTitleView.heightAnchor.constraint(equalToConstant: 36),
                
                // Layout: [Label] -8- [Button] - leading/trailing padding
                scheduleTitleButton.leadingAnchor.constraint(equalTo: scheduleTitleView.leadingAnchor, constant: -8),
                scheduleTitleButton.trailingAnchor.constraint(equalTo: scheduleTitleView.trailingAnchor),
                scheduleTitleButton.centerYAnchor.constraint(equalTo: scheduleTitleView.centerYAnchor),
            ])
        }
        
//        switch currentViewType {
//        case .day:
//            currentVC = dayVC
//        case .week:
//            currentVC = weekVC
//        case .month:
//            currentVC = monthVC
//        }
//                                
//        addChild(currentVC)
//        view.addSubview(currentVC.view)
//        currentVC.didMove(toParent: self)
//        currentVC.view.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            currentVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -5),
//            currentVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            currentVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            currentVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//        ])
    }
    
    private func buildCalendarTypeMenu() -> UIMenu {
        // Build conditionally based on state if needed
        let dayAction = UIAction(title: "Day", image: UIImage(systemName: "sun.max"), state: currentViewType == .day ? .on : .off) { [weak self] _ in
            self?.handleSelection(.day)
        }
        let weekAction = UIAction(title: "Week", image: UIImage(systemName: "calendar"), state: currentViewType == .week ? .on : .off) { [weak self] _ in
            self?.handleSelection(.week)
        }
        let monthAction = UIAction(title: "Month", image: UIImage(systemName: "calendar.circle"), state: currentViewType == .month ? .on : .off) { [weak self] _ in
            self?.handleSelection(.month)
        }
        let yearAction = UIAction(title: "Year", image: UIImage(systemName: "calendar.badge.clock"), state: .off) { _ in
            // Placeholder action
        }
        return UIMenu(title: "Calendar View", children: [dayAction, weekAction, monthAction, yearAction])
    }
    
    private func buildScheduleViewTypeMenu(userSchedules: [Schedule], userBlends: [Blend]) -> UIMenu {
        
        var scheduleActions: [UIAction] = []
        
        for schedule in userSchedules {
            let action = UIAction(title: schedule.title, state: .off) { [weak self] _ in
                self?.changeDisplayedSchedule(to: .schedule, id: schedule.id)
            }
            scheduleActions.append(action)
        }
        
        let scheduleMenu = UIMenu(title: "Your Schedules", children: scheduleActions)
        
        var blendActions: [UIAction] = []
        
        for blend in userBlends {
            let action = UIAction(title: blend.title, state: .off) { [weak self] _ in
                self?.changeDisplayedSchedule(to: .blend, id: blend.id)
            }
            blendActions.append(action)
        }
        
        let blendMenu = UIMenu(title: "Your Blends", children: blendActions)
        
        return UIMenu(title: "Schedules", children: [scheduleMenu, blendMenu])
    }
    
    private func handleSelection(_ type: ViewType) {
        guard type != currentViewType else {
            return
        }
        currentViewType = type
        UISelectionFeedbackGenerator().selectionChanged()
        // Refresh the button’s menu to reflect new checkmark state
        calendarTypeButton.menu = buildCalendarTypeMenu()
    }
    
    // Public API to read selection (kept for compatibility; returns string)
    func getSelectedOption() -> String? {
        switch currentViewType {
        case .day: return "Day"
        case .week: return "Week"
        case .month: return "Month"
        }
    }
    
    @objc func dismissMenus() {
        if showScheduleNameEditor {
//            toggleScheduleOptions()
        }
        if showScheduleOptions {
//            toggleOptions()
        }
    }
    
    func switchViewType(type: ViewType) {
//        guard let currentVC = currentVC else { return }
            
//        currentVC.willMove(toParent: nil)
//        currentVC.view.removeFromSuperview()
//        currentVC.removeFromParent()

//        let newVC: UIViewController
        switch type {
        case .day:
            UIView.transition(with: view, duration: 0.18, options: .transitionCrossDissolve) {
                self.dayVC.view.isHidden = false
                self.weekVC.view.isHidden = true
                self.monthVC.view.isHidden = true
            }
//            newVC = dayVC
        case .week:
            UIView.transition(with: view, duration: 0.18, options: .transitionCrossDissolve) {
                self.dayVC.view.isHidden = true
                self.weekVC.view.isHidden = false
                self.monthVC.view.isHidden = true
            }
//            newVC = weekVC
        case .month:
            UIView.transition(with: view, duration: 0.18, options: .transitionCrossDissolve) {
                self.dayVC.view.isHidden = true
                self.weekVC.view.isHidden = true
                self.monthVC.view.isHidden = false
            }
//            newVC = monthVC
        }

//        addChild(newVC)
//        view.addSubview(newVC.view)
//        newVC.view.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            newVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            newVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            newVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            newVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//
//        newVC.didMove(toParent: self)
//        
//        self.currentVC = newVC
    }
    
//    @objc func toggleOptions() {
//        // Animate the button immediately on tap; the context menu will appear on long-press by default.
//        spinButtonCABasic(filterButton)
//    }
    
//    @objc func toggleScheduleOptions() {
//        
//        if showScheduleOptions && !showScheduleNameEditor {
//            toggleOptions()
//        }
//        
//        showScheduleNameEditor.toggle()
//        if showScheduleNameEditor {
//            UIView.animate(withDuration: 0.4) { [weak self] in
//                guard let self else { return }
//                self.scheduleNameButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
//            }
//        } else {
//            UIView.animate(withDuration: 0.4, animations: { [weak self] in
//                guard let self else { return }
//                self.scheduleNameButton.transform = .identity
//            })
//        }
//    }
    
//    func spinButtonCABasic(_ button: UIButton, duration: TimeInterval = 0.2) {
//        if !showScheduleOptions {
//            UIView.animate(withDuration: duration) {
//                button.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + duration / 2) {
//                button.layer.borderWidth = 0
//                button.configuration?.baseForegroundColor = UIColor(Color(hex: 0x3C372F))
//                button.configuration?.image = UIImage(systemName: "xmark")
//            }
//        } else {
//            UIView.animate(withDuration: duration) {
//                button.transform = CGAffineTransform.identity
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + duration / 2) {
//                button.layer.borderWidth = 1.25
//                button.configuration?.baseForegroundColor = UIColor(Color(hex: 0x857F78))
//                button.configuration?.image = UIImage(systemName: "line.horizontal.3")
//            }
//        }
//        showScheduleOptions.toggle()
//    }

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
    
    func changeDisplayedSchedule(to scheduleType: ScheduleType, id: String) {
        guard let scheduleViewModel = coordinator?.scheduleViewModel else { return }
        
        if let schedule = scheduleViewModel.selectedSchedule, scheduleType == .schedule {
            if schedule.id == id {
                return
            }
        }
        
        if let blend = scheduleViewModel.selectedBlend, scheduleType == .blend {
            if blend.id == id {
                return
            }
        }
        
        if scheduleType == .schedule {
            if scheduleViewModel.userSchedules.contains(where: { $0.id == id }) {
                updateScheduleNameTitle(scheduleViewModel.userSchedules.first(where: { $0.id == id })!.title)
            }
            Task {
                await scheduleViewModel.fetchNewSchedule(id: id)
            }
        } else if scheduleType == .blend {
            if scheduleViewModel.userBlends.contains(where: { $0.id == id }) {
                updateScheduleNameTitle(scheduleViewModel.userBlends.first(where: { $0.id == id })!.title)
            }
            Task {
                await scheduleViewModel.fetchBlendSchedule(id: id)
            }
        }
        UISelectionFeedbackGenerator().selectionChanged()
        
        scheduleNameBarButton.menu = buildScheduleViewTypeMenu(userSchedules: scheduleViewModel.userSchedules, userBlends: scheduleViewModel.userBlends)
    }
    
    func setupModelObservation(scheduleViewModel: ScheduleViewModel) {
        scheduleViewModel.$isLoading
            .combineLatest(scheduleViewModel.$userSchedules, scheduleViewModel.$userBlends)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading, _, _ in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            }
            .store(in: &cancellables)
        
        scheduleViewModel.$userSchedules
            .combineLatest(scheduleViewModel.$userBlends)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userSchedules, userBlends in
                if !userSchedules.isEmpty || !userBlends.isEmpty {
                    self?.scheduleTitleButton.menu = self?.buildScheduleViewTypeMenu(userSchedules: userSchedules, userBlends: userBlends)
                }
            }
            .store(in: &cancellables)
                
        scheduleViewModel.$selectedSchedule
            .combineLatest(scheduleViewModel.$selectedBlend, scheduleViewModel.$isLoading)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedSchedule, selectedBlend, isLoading in
                guard let self = self else { return }
                if isLoading {
                    self.showLoading()
                } else {
                    self.hideLoading()
                    if let selectedSchedule = selectedSchedule {
                        self.updateScheduleNameTitle(selectedSchedule.title)
                    } else if let selectedBlend = selectedBlend {
                        self.updateScheduleNameTitle(selectedBlend.title)
                    } else {
                        self.blankSchedule()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateScheduleNameTitle(_ title: String) {
        let baseFont = UIFont.preferredFont(forTextStyle: .title2)
        let monoDescriptor = baseFont.fontDescriptor.withDesign(.default) ?? baseFont.fontDescriptor
        
        let weightedDescriptor = monoDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold.rawValue
            ]
        ])
        
        let monoDynamicFont = UIFont(descriptor: weightedDescriptor, size: 0)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: monoDynamicFont,
            .foregroundColor: UIColor(Color("NavItemsColors")),
        ]
        
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        scheduleTitleButton.setAttributedTitle(attributedTitle, for: .normal)
        
        let titleItem = UIBarButtonItem(customView: scheduleTitleView)
        let calendarViewItem = UIBarButtonItem(customView: calendarTypeView)
        
        navigationItem.rightBarButtonItem = calendarViewItem
        navigationItem.leftBarButtonItem = titleItem
    }
    
    func loadInitialData(scheduleViewModel: ScheduleViewModel) {
        Task {
            await scheduleViewModel.fetchSchedule()
        }
    }
    
    private var placeholderBackground: UIView?
    private var placeholderLabel: UILabel?
    private var createScheduleButton: UIButton?
    
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
        backgroundView.backgroundColor = UIColor(Color("BackgroundColor"))
        view.addSubview(backgroundView)
        
        let label = UILabel()
        label.text = "You don’t have a schedule yet!"
        label.font = .monospacedSystemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(Color("SecondaryText"))
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        view.bringSubviewToFront(label)
        
        let button = UIButton()
        button.backgroundColor = UIColor(Color("ButtonColors"))
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor(Color("PrimaryText")).cgColor
        button.setTitle("Create Schedule", for: .normal)
        button.setTitleColor(UIColor(Color("BackgroundColor")), for: .normal)
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
        
        placeholderBackground   = backgroundView
        placeholderLabel        = label
        createScheduleButton    = button
    }
}

extension ScheduleViewController: ScheduleViewMenuDelegate {
    
    func closeMenus() {
        if self.showScheduleOptions {
//            self.toggleOptions()
        }
        if self.showScheduleNameEditor {
//            self.toggleScheduleOptions()
        }
    }
}

