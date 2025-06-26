//
//  ScheduleViewController.swift
//  Schedoolr
//
//  Created by David Medina on 2/20/25.
//

import UIKit
import SwiftUI
import Combine

class PassthroughView: UIScrollView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }

    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl {
    return true
        }
        return super.touchesShouldCancel(in: view)
    }
}


class ScheduleViewController: UIViewController {
    
    var coordinator: ScheduleView.Coordinator?
    private var shouldReloadOnAppear = true
    
    private var scrollDebounceTimer: Timer?
    
    private var hasUserScrolled: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var showScheduleOptions = false
    
    var monthsList: [String] = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    
    // Store the previous horizontal offset
    private var previousContentOffsetX: CGFloat = 0
    private var previousContentOffsetY: CGFloat = 0
    
    var currentDate = Calendar.current.startOfDay(for: Date())
    
    lazy var numberOfTimeIntervals: Int = 24
    lazy var numberOfDays: Int = 61
    lazy var itemWidth: CGFloat = 60
    lazy var itemHeight: CGFloat = 100
    lazy var singleDayGroupWidth: CGFloat = itemWidth
    lazy var singleDayGroupHeight: CGFloat = Double(itemHeight) * Double(numberOfTimeIntervals)
    lazy var horizontalGroupWidth: CGFloat = singleDayGroupWidth * Double(numberOfDays)
    lazy var horizontalGroupHeight: CGFloat = singleDayGroupHeight
    
    lazy var displayedYear = Calendar.current.component(.year, from: currentDate)
    lazy var displayedMonth = monthsList[Calendar.current.component(.month, from: currentDate)-1]
    lazy var datesToAdd: Int = 30
    
    var dayList: [Date] = []
    
    func setDisplayedDates(centerDate: Date) {
        
        let startIndex = -numberOfDays / 2
        let endIndex = numberOfDays / 2
        
        if (currentDate == centerDate) {
            for index in startIndex...endIndex {
                dayList.append(Calendar.current.date(byAdding: .day, value: index, to: centerDate) ?? Date())
            }
        }
    }
    
    var positionScroll: CGPoint = .zero
    
    // using the lazy keyword allows us to safely access member methods within our class => layout function
    lazy var collectionView: UICollectionView = {
        let layout = self.layout()
        
        // creates our collection view with an initial frame of size 0 since we will define the constraints in viewDidLoad
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        //        older method of cell registration which is handled in the initialization of our collection view
        //        view.register(EventCell.self, forCellWithReuseIdentifier: "EventCell")
        
        collectionView.isDirectionalLockEnabled = true
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        // needed since our view controller sets the data source for our collection view
        collectionView.dataSource = self
        
        // tells the collection view that our view controller will handle it's delegation methods
        collectionView.delegate = self
        
        collectionView.prefetchDataSource = self
        
        return collectionView
    }()
    
    let cellRegistration = UICollectionView.CellRegistration<CollectionViewCell, Int> { cell, indexPath, item in
        cell.configureUI()
    }
    
    lazy var eventContainerScrollView: PassthroughView  = {
        let scrollView = PassthroughView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.isScrollEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentSize = CGSize(width: horizontalGroupWidth, height: singleDayGroupHeight)
        scrollView.delegate = self
        return scrollView
    }()
    
    private var loadingHostingController: UIHostingController<ScheduleLoadingView>?

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
        }
    }
    
    private var placeholderLabel: UILabel?
    private var createScheduleButton: UIButton?

    // … all your other properties …

    func showSchedule(_ schedule: Schedule) {
        // 1️⃣ Stop & remove the spinner
        hideLoading()
        
        // 2️⃣ Tear down the “no schedule” UI if present
        placeholderLabel?.removeFromSuperview()
        createScheduleButton?.removeFromSuperview()
        
        // 3️⃣ Un-hide your calendar UI (you added these in viewDidLoad)
        filterButton.isHidden                  = false
        searchButton.isHidden                  = false
        displayedMonthLabel.isHidden           = false
        displayedYearLabel.isHidden            = false
        dayHeaderScrollView.isHidden           = false
        timeColumnScrollView.isHidden          = false
        collectionView.isHidden                = false
        eventContainerScrollView.isHidden      = false
        overlayView.isHidden                   = false
        createEventButton.isHidden             = false
        
        displayedMonthLabel.text               = displayedMonth
        displayedYearLabel.text                = "\(displayedYear)"
        
        scheduleNameLabel.text =  "\(schedule.title)"
        
        view.layoutIfNeeded()
            
            // Make sure the header/time views are in place
            dayHeader.frame = CGRect(origin: .zero,
                                     size: CGSize(width: horizontalGroupWidth, height: 60))
            timeColumn.frame = CGRect(origin: .zero,
                                      size: CGSize(width: 44, height: singleDayGroupHeight))
            
            if dayHeader.superview == nil {
                dayHeaderScrollView.addSubview(dayHeader)
            }
            if timeColumn.superview == nil {
                timeColumnScrollView.addSubview(timeColumn)
            }
            
            // Seed the offsets once
            dayHeaderScrollView.contentOffset.x = collectionView.contentOffset.x
            timeColumnScrollView.contentOffset.y = collectionView.contentOffset.y
            
            // If your headers need population calls, do them now:
            dayHeader.setDates(dayList: dayList)
            // 5️⃣ Populate your events
            updateEventsOverlay()
    }

      /// Call this when `userSchedule == nil`
    func blankSchedule() {
        hideLoading()
        
        // hide calendar views
        filterButton.isHidden                  = true
        searchButton.isHidden                  = true
        displayedMonthLabel.isHidden           = true
        displayedYearLabel.isHidden            = true
        dayHeaderScrollView.isHidden           = true
        timeColumnScrollView.isHidden          = true
        collectionView.isHidden                = true
        eventContainerScrollView.isHidden      = true
        overlayView.isHidden                   = true
        createEventButton.isHidden             = true
        
        // show placeholder
        let label = UILabel()
        label.text = "You don’t have a schedule yet!"
        label.font = .monospacedSystemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(Color(hex: 0x666666))
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
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
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 150),
            button.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        // keep strong refs so we can remove them later
        placeholderLabel        = label
        createScheduleButton    = button
    }
    
    // your action to kick off creation
    @objc private func didTapCreateSchedule() {
        if let scheduleViewModel = coordinator?.scheduleViewModel {
            Task {
                let firstName = scheduleViewModel.currentUser.displayName.split(separator: " ").first ?? ""
                await scheduleViewModel.createSchedule(title: "\(firstName)'s Schedule")
            }
        }
    }
    
    let eventContainer = EventCellsContainer()
        
    let headerView = UIView()
        
    let overlayView = UIView()
    
    let filterButton = UIButton()
    
    let scheduleNameLabel = UILabel()
    
    let displayedMonthLabel = UILabel()
    let displayedYearLabel = UILabel()
    let searchButton = UIButton()
    
    let scheduleViewOptions = ScheduleViewOptions()
    
    let exampleEvent = UIView()
    
    let createEventButton = UIButton()
    
    let dayHeader = CollectionViewDaysHeader()
    let timeColumn = CollectionViewTimesColumn()
    
    let dayHeaderScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = false // We'll control this programmatically
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentSize = CGSize(width: CGFloat(60*61), height: 60)
        return scrollView
    }()

    let timeColumnScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = false // We'll control this programmatically
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentSize = CGSize(width: 44, height: CGFloat(100*24))
        return scrollView
    }()
    
    private var isHandlingScroll = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showLoading()
        
        if let scheduleViewModel = coordinator?.scheduleViewModel {
            setupViewModelObservation(viewModel: scheduleViewModel)
            loadInitialData()
        }
        
        view.backgroundColor = UIColor(Color(hex: 0xf7f4f2))
        
        view.addSubview(headerView)
            
        view.addSubview(displayedMonthLabel)
        view.addSubview(displayedYearLabel)
        
        collectionView.backgroundColor = UIColor(Color(hex: 0xf7f4f2))
        
        // add the collection view to root view
        view.addSubview(collectionView)
        
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = UIColor(Color(hex: 0xf7f4f2))
        
        searchButton.configuration = .borderless()
        searchButton.configuration?.image = UIImage(systemName: "magnifyingglass")
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        searchButton.addTarget(self, action: #selector(showEventSearchMenu), for: .touchUpInside)
        searchButton.configuration?.baseForegroundColor = UIColor(Color(hex: 0x666666))
        
        filterButton.configuration = .filled()
        filterButton.configuration?.baseBackgroundColor = UIColor(Color(hex: 0xf7f4f2))
        filterButton.layer.borderWidth = 1.25
        filterButton.layer.borderColor = UIColor(Color(hex: 0x333333)).cgColor
        filterButton.layer.cornerRadius = 10
        filterButton.configuration?.image = UIImage(systemName: "line.horizontal.3")
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        filterButton.addTarget(self, action: #selector(toggleSidebar), for: .touchUpInside)
        filterButton.configuration?.baseForegroundColor = UIColor(Color(hex: 0x666666))
        
        scheduleNameLabel.font = .monospacedSystemFont(ofSize: 17, weight: .bold)
        scheduleNameLabel.translatesAutoresizingMaskIntoConstraints = false
        scheduleNameLabel.textAlignment = .left
        scheduleNameLabel.textColor = UIColor(Color(hex: 0x333333))
        
        view.addSubview(filterButton)
        view.addSubview(searchButton)
        
        view.addSubview(scheduleNameLabel)
                
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        displayedMonthLabel.text = displayedMonth
        
        displayedMonthLabel.font = .systemFont(ofSize: 28, weight: .bold)
        displayedMonthLabel.translatesAutoresizingMaskIntoConstraints = false
        displayedMonthLabel.textAlignment = .right
        displayedMonthLabel.textColor = UIColor(Color(hex: 0x333333))
        
        displayedYearLabel.text = "\(displayedYear)"
        displayedYearLabel.font = .systemFont(ofSize: 28, weight: .semibold)
        displayedYearLabel.translatesAutoresizingMaskIntoConstraints = false
        displayedYearLabel.textColor = UIColor(Color(hex: 0x666666))
        
        timeColumn.translatesAutoresizingMaskIntoConstraints = false
        dayHeader.translatesAutoresizingMaskIntoConstraints = false
        
        createEventButton.configuration = .filled()
        createEventButton.configuration?.cornerStyle = .capsule
        createEventButton.configuration?.baseBackgroundColor = UIColor(Color(hex: 0xE5E5EA))
        createEventButton.configuration?.image?.withTintColor(UIColor(Color(hex: 0x6E6E73)))
        createEventButton.configuration?.image = UIImage(systemName: "plus")
        createEventButton.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        createEventButton.configuration?.baseForegroundColor = UIColor(Color(hex: 0x6E6E73))
        createEventButton.translatesAutoresizingMaskIntoConstraints = false
        createEventButton.addTarget(self, action: #selector(showCreateEvent), for: .touchUpInside)
        
        view.addSubview(createEventButton)
        // Add the scroll views first
        view.addSubview(dayHeaderScrollView)
        view.addSubview(timeColumnScrollView)
        
        // Add headers to scroll views
        dayHeaderScrollView.addSubview(dayHeader)
        timeColumnScrollView.addSubview(timeColumn)
        view.addSubview(overlayView)
        
        eventContainer.translatesAutoresizingMaskIntoConstraints = false
        
        eventContainer.onTap = { [weak self] event in
            self?.shouldReloadOnAppear = false
            self?.showEventDetails(event: event)
        }
        
        eventContainerScrollView.addSubview(eventContainer)
        
        view.addSubview(eventContainerScrollView)
        
        view.bringSubviewToFront(createEventButton)
        
        scheduleViewOptions.isHidden = true
        
        view.addSubview(scheduleViewOptions)
        view.bringSubviewToFront(scheduleViewOptions)
        
        // constraints for our collection view
        NSLayoutConstraint.activate([
            
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            filterButton.leadingAnchor.constraint(equalTo: headerView.layoutMarginsGuide.leadingAnchor),
            filterButton.topAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.topAnchor, constant: 5),
            filterButton.widthAnchor.constraint(equalToConstant: 30),
            filterButton.heightAnchor.constraint(equalToConstant: 30),
            filterButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            scheduleNameLabel.leadingAnchor.constraint(equalTo: filterButton.trailingAnchor, constant: 10),
            scheduleNameLabel.centerYAnchor.constraint(equalTo: filterButton.centerYAnchor),
            
            displayedMonthLabel.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 10),
            displayedMonthLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            displayedYearLabel.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 10),
            displayedYearLabel.leadingAnchor.constraint(equalTo: displayedMonthLabel.trailingAnchor, constant: 3),
            
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchButton.centerYAnchor.constraint(equalTo: displayedMonthLabel.centerYAnchor),
            
            dayHeaderScrollView.topAnchor.constraint(equalTo: displayedMonthLabel.bottomAnchor, constant: 5),
            dayHeaderScrollView.leadingAnchor.constraint(equalTo: overlayView.trailingAnchor),
            dayHeaderScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dayHeaderScrollView.heightAnchor.constraint(equalToConstant: 60),
           
            // Time column scroll view
            timeColumnScrollView.topAnchor.constraint(equalTo: overlayView.bottomAnchor),
            timeColumnScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timeColumnScrollView.widthAnchor.constraint(equalToConstant: 48),
            timeColumnScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Headers inside scroll views (position at 0,0)
            dayHeader.topAnchor.constraint(equalTo: dayHeaderScrollView.contentLayoutGuide.topAnchor),
            dayHeader.leadingAnchor.constraint(equalTo: dayHeaderScrollView.contentLayoutGuide.leadingAnchor),
            dayHeader.widthAnchor.constraint(equalToConstant: horizontalGroupWidth),
            dayHeader.heightAnchor.constraint(equalToConstant: 60),
            
            timeColumn.topAnchor.constraint(equalTo: timeColumnScrollView.contentLayoutGuide.topAnchor),
            timeColumn.leadingAnchor.constraint(equalTo: timeColumnScrollView.contentLayoutGuide.leadingAnchor),
            timeColumn.widthAnchor.constraint(equalToConstant: 48),
            timeColumn.heightAnchor.constraint(equalToConstant: singleDayGroupHeight),
            
            collectionView.topAnchor.constraint(equalTo: dayHeaderScrollView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: timeColumnScrollView.trailingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            eventContainerScrollView.topAnchor.constraint(equalTo: dayHeaderScrollView.bottomAnchor),
            eventContainerScrollView.leadingAnchor.constraint(equalTo: timeColumnScrollView.trailingAnchor),
            eventContainerScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            eventContainerScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            eventContainer.topAnchor.constraint(equalTo: eventContainerScrollView.bottomAnchor),
            eventContainer.leadingAnchor.constraint(equalTo: eventContainerScrollView.trailingAnchor),
            eventContainer.widthAnchor.constraint(equalToConstant: horizontalGroupWidth),
            eventContainer.heightAnchor.constraint(equalToConstant: horizontalGroupHeight),
            
            overlayView.topAnchor.constraint(equalTo: displayedMonthLabel.bottomAnchor, constant: 5),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.widthAnchor.constraint(equalToConstant: 48),
            overlayView.heightAnchor.constraint(equalToConstant: 60),
            
            createEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            createEventButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            createEventButton.widthAnchor.constraint(equalToConstant: 60),
            createEventButton.heightAnchor.constraint(equalToConstant: 60),
            
            scheduleViewOptions.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 5),
            scheduleViewOptions.leadingAnchor.constraint(equalTo: headerView.layoutMarginsGuide.leadingAnchor),
            scheduleViewOptions.widthAnchor.constraint(equalToConstant: 150),
            scheduleViewOptions.heightAnchor.constraint(equalToConstant: 175),
        ])
        
        setDisplayedDates(centerDate: currentDate)
        dayHeader.setDates(dayList: dayList)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if hasUserScrolled {
            return
        } else {
            scrollToCurrentPosition()
            updateEventsOverlay()
        }
    }
    
    func loadInitialData() {
        guard let scheduleViewModel = coordinator?.scheduleViewModel else { return }
                
        Task {
            await scheduleViewModel.fetchSchedule()
        }
    }
    
    private func updateEventsOverlay() {
        if let scheduleViewModel = coordinator?.scheduleViewModel {
            eventContainer.populateEventCells(rootVC: self, scheduleViewModel: scheduleViewModel, events: scheduleViewModel.scheduleEvents, centerDate: currentDate, calendarInterval: numberOfDays)
        }
    }
    
    func spinButtonCABasic(_ button: UIButton, duration: TimeInterval = 0.4) {
        // add perspective
        var p = CATransform3DIdentity; p.m34 = -1/500
        button.superview?.layer.sublayerTransform = p

        // rotation animation
        let rotation = CABasicAnimation(keyPath: "transform.rotation.y")
        rotation.fromValue = 0
        rotation.toValue = 1 * Double.pi
        rotation.duration = duration
        rotation.isRemovedOnCompletion = false
        rotation.fillMode = .forwards
        button.layer.add(rotation, forKey: "spin")

        // swap image halfway
        DispatchQueue.main.asyncAfter(deadline: .now() + duration/2) {
            button.layer.borderWidth = button.layer.borderWidth == 0 ? 1 : 0
            button.configuration?.image = button.configuration?.image == UIImage(systemName: "xmark") ? UIImage(systemName: "line.horizontal.3") : UIImage(systemName: "xmark")
        }
    }
    
    private func setupViewModelObservation(viewModel: ScheduleViewModel) {
        // Using Combine for reactive updates
        viewModel.$scheduleEvents
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newEvents in
                // Update UI when the scheduleItems changes
                self?.updateEventsOverlay()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                if loading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$userSchedule
            .receive(on: DispatchQueue.main)
            .sink { [weak self] maybeSchedule in
                if let schedule = maybeSchedule {
                    self?.showSchedule(schedule)
                } else if maybeSchedule == nil && !viewModel.isLoading {
                    self?.blankSchedule()
                }
            }
          .store(in: &cancellables)
    }
    
    @objc func toggleSidebar() {
        spinButtonCABasic(filterButton)
        showScheduleOptions.toggle()
        
        if showScheduleOptions {
            UIView.animate(withDuration: 0.4, animations: {
                self.scheduleViewOptions.alpha = 1
                self.scheduleViewOptions.isHidden = false
            })
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                self.scheduleViewOptions.alpha = 0
            }) { (finished) in
                self.scheduleViewOptions.isHidden = finished
            }
        }
    }
    
//    if let sheet = hostingController.sheetPresentationController {
//            sheet.detents = [
//                .custom { context in
//                    return 300 // Custom height
//                },
//                .medium(),
//                .large()
//            ]
//            sheet.selectedDetentIdentifier = .medium
//            sheet.prefersGrabberVisible = true
//        }
//        
//        present(hostingController, animated: true)
    
    @objc
    func showEventSearchMenu() {
        let eventSearchSheet = EventSearchView()
        
        let eventSearchSheetViewController = UIHostingController(rootView: eventSearchSheet)
        
        if let sheet = eventSearchSheetViewController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        
        present(eventSearchSheetViewController, animated: true, completion: nil)
    }
    
    func showCreateEventButton() {
        UIView.animate(withDuration: 0.5, animations: {
            self.createEventButton.alpha = 1
            self.createEventButton.isHidden = false
        })
    }
    
    func hideCreateEventButton() {
        UIView.animate(withDuration: 0.5, animations: {
            self.createEventButton.alpha = 0
        }) { (finished) in
            self.createEventButton.isHidden = finished
        }
    }
    
    @objc
    func showCreateEvent() {
        
        if let scheduleViewModel = coordinator?.scheduleViewModel {
            // wrap our SwiftUI view in a UIHostingController so that we can display it here in our VC
            // inject our viewModel explicitly as an environment object
            let hostingController = UIHostingController(
                rootView: CreateEventView(scheduleViewModel: scheduleViewModel)
            )
            
            navigationController?.pushViewController(hostingController, animated: true)
        }
    }
    
    func showEventDetails(event: RecurringEvents) {
        if let scheduleViewModel = coordinator?.scheduleViewModel {
            
            // since event details view expects a Binding type, and we can't explicity
            // use the $ binding syntax within a view controller, we can create a
            // binding type manually
            let shouldReloadDataBinding = Binding<Bool>(
                get: { scheduleViewModel.shouldReloadData },
                set: { newValue in
                    scheduleViewModel.shouldReloadData = newValue
                }
            )
            
            // wrap our SwiftUI view in a UIHostingController so that we can display it here in our VC
            // inject our viewModel explicitly as an environment object
            let hostingController = UIHostingController(
                rootView: EventDetailsView(event: event, currentUser: scheduleViewModel.currentUser, shouldReloadData: shouldReloadDataBinding)
            )
            
            navigationController?.pushViewController(hostingController, animated: true)
        }
    }
    
    // handles the initial scrolling to the current time to give the user an animated experience
    func scrollToCurrentPosition() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        
        // Calculate vertical position based on current time
        let itemHeight: CGFloat = 100
        let desiredYOffset = max(0, CGFloat(hour) * itemHeight - 100)
        
        // Calculate the maximum possible y-offset to prevent scrolling too far
        let maxYOffset = collectionView.contentSize.height - collectionView.frame.height
        
        // Ensure we don't scroll beyond content boundaries
        let safeYOffset = min(desiredYOffset, maxYOffset > 0 ? maxYOffset : 0)
        
        // Get current day index relative to our 60-day range (-30 to +29)
        let currentDayIndex = numberOfDays / 2 // Middle of our 60-day range (today)
        let itemWidth: CGFloat = 60
        
        // initial horizontal offset so that the current day is the first day displayed
        let xOffset = CGFloat(currentDayIndex) * itemWidth + 0.50
        
        collectionView.setContentOffset(CGPoint(x: xOffset, y: safeYOffset), animated: false)
        
        UIView.performWithoutAnimation {
            dayHeaderScrollView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: false)
            timeColumnScrollView.setContentOffset(CGPoint(x: 0, y: safeYOffset), animated: false)
        }
    }
    
    func layout() -> UICollectionViewCompositionalLayout {
        
        // Event Item
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth),
                                              heightDimension: .absolute(itemHeight))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Vertical Group for a single day
        let singleDayGroupSize = NSCollectionLayoutSize(widthDimension: .absolute(singleDayGroupWidth),
                                                        heightDimension: .absolute(singleDayGroupHeight))
        
        let singleDayGroup = NSCollectionLayoutGroup.vertical(layoutSize: singleDayGroupSize,
                                                              subitems: [item])
        
        // Horizontal Group to hold all of the vertical Groups defined above
        let horizontalGroupContainerSize = NSCollectionLayoutSize(widthDimension: .absolute(horizontalGroupWidth),
                                                                  heightDimension: .absolute(horizontalGroupHeight))
        
        let horizontalGroupContainer = NSCollectionLayoutGroup.horizontal(layoutSize: horizontalGroupContainerSize,
                                                                          subitems: [singleDayGroup])
        
        
        let section = NSCollectionLayoutSection(group: horizontalGroupContainer)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    var shouldIgnorePreviousTrigger = false
    var isLoadingNextDates = false
    var isLoadingPreviousDates = false
    
    private func loadPreviousDateInterval() {
        guard !isLoadingPreviousDates else { return }
        isLoadingPreviousDates = true
        
        let currentOffset = collectionView.contentOffset
        let newOffset = CGPoint(x: currentOffset.x + CGFloat(datesToAdd) * itemWidth, y: currentOffset.y)
        
        // Get the first date in current range
        let firstDate = dayList.first ?? Date()
        
        // Add another 30 days
        var newDays: [Date] = []
        
        for i in 1...datesToAdd {
            if let newDate = Calendar.current.date(byAdding: .day, value: -i, to: firstDate) {
                newDays.append(newDate)
            }
        }
        
        // Update the data source with new days
        dayList.removeLast(datesToAdd)
        dayList.insert(contentsOf: newDays.reversed(), at: 0)
        
        currentDate = firstDate
        
        UIView.performWithoutAnimation {
            resetModifiedCells()
            collectionView.reloadSections(IndexSet(integer: 0))
            collectionView.setContentOffset(newOffset, animated: false)
            updateEventsOverlay()
            dayHeader.addPreviousDates(updatedDayList: newDays)
        }
        
        isLoadingPreviousDates = false
    }
    
    private func loadNextDateInterval() {
        guard !isLoadingNextDates else { return }
        isLoadingNextDates = true
        
        // Set a flag to temporarily ignore the previous date loading trigger
        shouldIgnorePreviousTrigger = true
        
        let currentOffset = collectionView.contentOffset
        let newOffset = CGPoint(x: currentOffset.x - CGFloat(datesToAdd) * itemWidth, y: currentOffset.y)
        
        // Get the last date in current range
        let lastDate = dayList.last ?? Date()
        
        // Create new days to add
        var newDays: [Date] = []
        for i in 1...datesToAdd {
            if let newDate = Calendar.current.date(byAdding: .day, value: i, to: lastDate) {
                newDays.append(newDate)
            }
        }
        
        // since we've created the new 30 days, we now remove 30 from the beginning of dayList
        dayList.removeFirst(datesToAdd)
        dayList.append(contentsOf: newDays)
        
        // set the currentDate as the previously saved last date since this is our new 'middle' reference date
        currentDate = lastDate
        
        // necessary to ensure that all of these updates happen without animation to provide the smoothest transition
        UIView.performWithoutAnimation {
            resetModifiedCells()
            // since we reload the section, the offset from this will make our prefetching delegate
            // call to loadPreviousDateInterval, so we must set ignoring trigger as such
            shouldIgnorePreviousTrigger = true
            collectionView.reloadSections(IndexSet(integer: 0))
            collectionView.setContentOffset(newOffset, animated: false)
            dayHeader.addNextDates(updatedDayList: newDays)
            updateEventsOverlay()
            
            // before we set it back to false, we set a slight delay in case the new offset does not execute before our
            // prefetch delegate is called upon
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.shouldIgnorePreviousTrigger = false
            }
        }
        
        isLoadingNextDates = false
    }
    
    var modifiedCells = Set<UICollectionViewCell>()
    
    deinit {
        modifiedCells.removeAll()
        cancellables.removeAll()
    }
}

extension ScheduleViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Prevent recursive scroll handling
        guard !isHandlingScroll, scrollView === collectionView else { return }
        
        isHandlingScroll = true
        
        // The user wants to scroll on the X axis
        if scrollView.contentOffset.x > positionScroll.x || scrollView.contentOffset.x < positionScroll.x {
            // Reset the Y position of the scrollView to what it was before scrolling started
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: positionScroll.y)
        } else {
            // The user wants to scroll on the Y axis
            // Reset the X position of the scrollView to what it was before scrolling started
            scrollView.contentOffset = CGPoint(x: positionScroll.x, y: scrollView.contentOffset.y)
        }
    
        let dayIndex = Int(scrollView.contentOffset.x / singleDayGroupWidth)
        
        if dayIndex >= 0 && dayIndex < dayList.count {
            let visibleDate = dayList[dayIndex]
            
            let month = Calendar.current.component(.month, from: visibleDate) - 1
            let year = Calendar.current.component(.year, from: visibleDate)
            
            let newMonth = monthsList[month]
            if newMonth != displayedMonthLabel.text {
                displayedMonthLabel.text = newMonth
                displayedYearLabel.text = "\(year)"
            }
        }
                
        // Sync horizontal scrolling for day header
        if scrollView.contentOffset.x != previousContentOffsetX {
            dayHeaderScrollView.contentOffset.x = scrollView.contentOffset.x
            eventContainerScrollView.contentOffset.x = scrollView.contentOffset.x
            previousContentOffsetX = scrollView.contentOffset.x
        }
        
        // Sync vertical scrolling for time column
        if scrollView.contentOffset.y != previousContentOffsetY {
            timeColumnScrollView.contentOffset.y = scrollView.contentOffset.y
            eventContainerScrollView.contentOffset.y = scrollView.contentOffset.y
            previousContentOffsetY = scrollView.contentOffset.y
        }
        
        // Handle stretching cells at boundaries
        handleBoundaryCellStretching(scrollView)
        
        isHandlingScroll = false
    }
    
    private func handleBoundaryCellStretching(_ scrollView: UIScrollView) {
        
        // Calculate the maximum scroll position (without adding tolerance yet)
        let maxScrollY = collectionView.contentSize.height - collectionView.bounds.height
        
        // Check for boundary conditions with proper tolerance
        let isAtTopBoundary = collectionView.contentOffset.y < 0
        let isAtBottomBoundary = maxScrollY > 0 && collectionView.contentOffset.y > maxScrollY
        
        if isAtTopBoundary || isAtBottomBoundary {
            // Calculate actual offsets
            let topOffset = isAtTopBoundary ? -collectionView.contentOffset.y : 0
            let bottomOffset = isAtBottomBoundary ? collectionView.contentOffset.y - maxScrollY : 0
            
            let visibleCells = collectionView.indexPathsForVisibleItems
            let topVisibleCells = visibleCells.filter {
                $0.item % numberOfTimeIntervals == 0
            }
            
            let bottomVisibleCells = visibleCells.filter {
                ($0.item + 1) % numberOfTimeIntervals == 0
            }
            
            // Handle top cells stretching
            for indexPath in topVisibleCells {
                if let cell = collectionView.cellForItem(at: indexPath) {
                    if !modifiedCells.contains(cell) {
                        cell.layer.setValue(cell.frame.origin.y, forKey: "normal")
                        cell.layer.setValue(cell.frame.size.height, forKey: "normalHeight")
                        modifiedCells.insert(cell)
                    }
                    
                    var frame = cell.frame
                    frame.origin.y = (cell.layer.value(forKey: "normal") as? CGFloat ?? frame.origin.y) - topOffset
                    frame.size.height = (cell.layer.value(forKey: "normalHeight") as? CGFloat ?? itemHeight) + topOffset
                    
                    cell.frame = frame
                }
            }
            
            // Handle bottom cells stretching
            for indexPath in bottomVisibleCells {
                if let cell = collectionView.cellForItem(at: indexPath) {
                    if !modifiedCells.contains(cell) {
                        cell.layer.setValue(cell.frame.origin.y, forKey: "normal")
                        cell.layer.setValue(cell.frame.size.height, forKey: "normalHeight")
                        modifiedCells.insert(cell)
                    }
                    
                    var frame = cell.frame
                    frame.origin.y = (cell.layer.value(forKey: "normal") as? CGFloat ?? frame.origin.y)
                    frame.size.height = (cell.layer.value(forKey: "normalHeight") as? CGFloat ?? itemHeight) + bottomOffset
                    
                    cell.frame = frame
                }
            }
        }
    }

    func resetModifiedCells() {
        // Create a copy to avoid mutation during iteration
        let cellsToReset = modifiedCells
        
        for cell in cellsToReset {
            // Only modify cells that are still in the view hierarchy
            if cell.superview != nil {
                if let originalPosition = cell.layer.value(forKey: "normal") as? CGFloat,
                   let originalHeight = cell.layer.value(forKey: "normalHeight") as? CGFloat {
                    var frame = cell.frame
                    frame.origin.y = originalPosition
                    frame.size.height = originalHeight
                    cell.frame = frame
                    
                    // Clear stored values
                    cell.layer.setValue(nil, forKey: "normal")
                    cell.layer.setValue(nil, forKey: "normalHeight")
                }
            }
        }
        modifiedCells.removeAll()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        positionScroll = scrollView.contentOffset
        hideCreateEventButton()
        
        if !hasUserScrolled {
            hasUserScrolled = true
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        showCreateEventButton()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let itemWidth: CGFloat = 60
        let proposedX   = targetContentOffset.pointee.x
        let page        = round(proposedX / itemWidth)
        targetContentOffset.pointee.x = page * itemWidth + 0.50
    }
}

extension ScheduleViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // calculate the total number of items in the collection view
        let totalItems = numberOfDays * numberOfTimeIntervals
        
        // 
        let endIndex = indexPaths.max(by: { $0.item < $1.item })?.item
        let startIndex = indexPaths.min(by: { $0.item < $1.item })?.item
        
        let daysBeforeThreshold = 7
        let threshold = numberOfTimeIntervals * daysBeforeThreshold
        
        if endIndex ?? totalItems >= (totalItems - threshold) && !isLoadingNextDates {
            loadNextDateInterval()
        } else if startIndex ?? 0 <= threshold && !isLoadingPreviousDates && !shouldIgnorePreviousTrigger {
            loadPreviousDateInterval()
        }
    }
}

extension ScheduleViewController: UICollectionViewDataSource {

    // only need one section for the entire page
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // 24 represents the number of hours in a day => number of cells needed since an item represents a single hour
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfTimeIntervals * numberOfDays
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        older method where the registration is dequeued, and then configured by force unwrapping the CollectionViewCell type
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCell.identifier, for: indexPath) as! EventCell
//        cell.configureUI(with: "Event \(indexPath.item)")
//        return cell

//      modern method where the dequeued and configured automatically from the cell registration in our collection view initialization
        return collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath,
            item: indexPath.item
        )
    }
}

extension UICollectionView {

    func indexPathsForFullyVisibleItems() -> [IndexPath] {
        
        let visibleIndexPaths = indexPathsForVisibleItems
        var indexPaths: [IndexPath] = []
        
        for cell in visibleIndexPaths {
            if cell.item % 24 == 0 || (cell.item % 23 == 0 && cell.item != 0) {
                indexPaths.append(cell)
            }
        }
        
        return indexPaths
    }
}

