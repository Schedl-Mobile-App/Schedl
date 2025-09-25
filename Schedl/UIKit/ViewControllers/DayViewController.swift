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
    
    private var shouldReloadOnAppear = true
    
    private var scrollDebounceTimer: Timer?
    
    private var hasUserScrolled: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    var monthsList: [String] = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    
    // Store the previous horizontal offset
    private var previousContentOffsetX: CGFloat = 0
    private var previousContentOffsetY: CGFloat = 0
        
    var currentDate = Calendar.current.startOfDay(for: Date())
    
    lazy var numberOfTimeIntervals: Int = 24
    lazy var numberOfDays: Int = 31
    lazy var itemHeight: CGFloat = 100
    lazy var singleDayGroupHeight: CGFloat = Double(itemHeight) * Double(numberOfTimeIntervals)
    lazy var horizontalGroupHeight: CGFloat = singleDayGroupHeight
    
    lazy var displayedYear = Calendar.current.component(.year, from: currentDate)
    lazy var displayedMonth = monthsList[Calendar.current.component(.month, from: currentDate)-1]
    lazy var datesToAdd: Int = 15
    
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
    var createEventButtonWidthConstraint: NSLayoutConstraint?
    var createEventButtonHeightConstraint: NSLayoutConstraint?
    
    var positionScroll: CGPoint = .zero
    let buttonColors: ButtonColors = [ButtonColors.palette1, ButtonColors.palette2, ButtonColors.palette3, ButtonColors.palette4].randomElement()!
    
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
        
        // tells the collection view that our view controller will handle it's delegated methods
        collectionView.delegate = self
        
//        collectionView.prefetchDataSource = self
        
        return collectionView
    }()
    
    let cellRegistration = UICollectionView.CellRegistration<CollectionViewCell, Int> { cell, indexPath, item in
        cell.setupView()
    }
    
    
//    lazy var eventContainerScrollView: PassthroughView  = {
//        let scrollView = PassthroughView()
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.backgroundColor = .clear
//        scrollView.isScrollEnabled = false
//        scrollView.showsHorizontalScrollIndicator = false
//        scrollView.showsVerticalScrollIndicator = false
//        scrollView.contentSize = CGSize(width: horizontalGroupWidth, height: singleDayGroupHeight)
//        scrollView.delegate = self
//        return scrollView
//    }()
    
//    let eventContainer = EventCellsContainer()
    
    var isExpanded: Bool = true
                
    let overlayView = UIView()
    
    let displayedMonthLabel = UILabel()
    let displayedYearLabel = UILabel()
    let searchButton = UIButton()
        
    let exampleEvent = UIView()
    
    let createEventButton = UIButton()
    
    let createBlendButton = UIButton()
    let createBlendLabel = UILabel()
    
    let createScheduleEventButton = UIButton()
    let createScheduleEventLabel = UILabel()
    
//    let dayHeader = CollectionViewDaysHeader()
    let timeColumn = CollectionViewTimesColumn()
    
//    let dayHeaderScrollView: UIScrollView = {
//        let scrollView = UIScrollView()
//        scrollView.showsHorizontalScrollIndicator = false
//        scrollView.isScrollEnabled = false // We'll control this programmatically
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.contentSize = CGSize(width: CGFloat(60*61), height: 60)
//        return scrollView
//    }()

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
                
        setupViewModelObservation()
                
        view.backgroundColor = UIColor(Color(hex: 0xf7f4f2))
                    
        view.addSubview(displayedMonthLabel)
        view.addSubview(displayedYearLabel)
        
//        collectionView.register(
//            .self,
//            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//            withReuseIdentifier: "MyHeaderView"
//        )
        
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
        searchButton.configuration?.baseForegroundColor = UIColor(Color(hex: 0x857F78))
        
        view.addSubview(searchButton)
                        
        displayedMonthLabel.text = displayedMonth
        
        displayedMonthLabel.font = .systemFont(ofSize: 28, weight: .bold)
        displayedMonthLabel.translatesAutoresizingMaskIntoConstraints = false
        displayedMonthLabel.textAlignment = .right
        displayedMonthLabel.textColor = UIColor(Color(hex: 0x544F47))
        
        displayedYearLabel.text = "\(displayedYear)"
        displayedYearLabel.font = .systemFont(ofSize: 26, weight: .bold)
        displayedYearLabel.translatesAutoresizingMaskIntoConstraints = false
        displayedYearLabel.textColor = UIColor(Color(hex: 0x544F47))
        
        timeColumn.translatesAutoresizingMaskIntoConstraints = false
//        dayHeader.translatesAutoresizingMaskIntoConstraints = false
        
        createEventButton.configuration = .filled()
        createEventButton.configuration?.cornerStyle = .capsule
        createEventButton.configuration?.baseBackgroundColor = buttonColors.backgroundColor
        createEventButton.configuration?.image = UIImage(systemName: "plus")
        createEventButton.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        createEventButton.configuration?.baseForegroundColor = buttonColors.foregroundColor
        createEventButton.translatesAutoresizingMaskIntoConstraints = false
        createEventButton.addTarget(self, action: #selector(showCreateOptions), for: .touchUpInside)
        
        createBlendButton.configuration = .filled()
        createBlendButton.configuration?.cornerStyle = .capsule
        createBlendButton.configuration?.baseBackgroundColor = buttonColors.backgroundColor
        createBlendButton.configuration?.image = UIImage(systemName: "person.2.badge.plus")
        createBlendButton.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        createBlendButton.configuration?.baseForegroundColor = buttonColors.foregroundColor
        createBlendButton.translatesAutoresizingMaskIntoConstraints = false
        createBlendButton.addTarget(self, action: #selector(showCreateBlend), for: .touchUpInside)
        createBlendButton.isHidden = true
        createBlendButton.alpha = 0
        
        createBlendLabel.text = "Create Blend"
        createBlendLabel.font = .systemFont(ofSize: 12, weight: .bold)
        createBlendLabel.translatesAutoresizingMaskIntoConstraints = false
        createBlendLabel.textColor = UIColor(Color(hex: 0x544F47))
        createBlendLabel.isHidden = true
        createBlendLabel.alpha = 0
        
        createScheduleEventButton.configuration = .filled()
        createScheduleEventButton.configuration?.cornerStyle = .capsule
        createScheduleEventButton.configuration?.baseBackgroundColor = buttonColors.backgroundColor
        createScheduleEventButton.configuration?.image = UIImage(systemName: "calendar.badge.plus")
        createScheduleEventButton.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        createScheduleEventButton.configuration?.baseForegroundColor = buttonColors.foregroundColor
        createScheduleEventButton.translatesAutoresizingMaskIntoConstraints = false
        createScheduleEventButton.addTarget(self, action: #selector(showCreateEvent), for: .touchUpInside)
        createScheduleEventButton.isHidden = true
        createScheduleEventButton.alpha = 0
        
        
        createScheduleEventLabel.text = "Create Event"
        createScheduleEventLabel.font = .systemFont(ofSize: 12, weight: .bold)
        createScheduleEventLabel.translatesAutoresizingMaskIntoConstraints = false
        createScheduleEventLabel.textColor = UIColor(Color(hex: 0x544F47))
        createScheduleEventLabel.isHidden = true
        createScheduleEventLabel.alpha = 0
        
        
        // Add the scroll views first
//        view.addSubview(dayHeaderScrollView)
        view.addSubview(timeColumnScrollView)
        
        // Add headers to scroll views
//        dayHeaderScrollView.addSubview(dayHeader)
        timeColumnScrollView.addSubview(timeColumn)
        view.addSubview(overlayView)
        
//        eventContainer.translatesAutoresizingMaskIntoConstraints = false
//        
//        eventContainer.onTap = { [weak self] event in
//            self?.shouldReloadOnAppear = false
//            self?.showEventDetails(event: event)
//        }
        
//        eventContainerScrollView.addSubview(eventContainer)
        
//        view.addSubview(eventContainerScrollView)
        
        view.addSubview(createEventButton)
        view.addSubview(createBlendButton)
        view.addSubview(createBlendLabel)
        view.addSubview(createScheduleEventButton)
        view.addSubview(createScheduleEventLabel)
        
        // constraints for our collection view
        let widthConstraint = createEventButton.widthAnchor.constraint(equalToConstant: 60)
        let heightConstraint = createEventButton.heightAnchor.constraint(equalToConstant: 60)
        createEventButtonWidthConstraint = widthConstraint
        createEventButtonHeightConstraint = heightConstraint
        
        // constraints for our collection view
        NSLayoutConstraint.activate([
            displayedMonthLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            displayedMonthLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            displayedYearLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            displayedYearLabel.leadingAnchor.constraint(equalTo: displayedMonthLabel.trailingAnchor, constant: 3),
            displayedYearLabel.bottomAnchor.constraint(equalTo: displayedMonthLabel.bottomAnchor),
            
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchButton.bottomAnchor.constraint(equalTo: displayedMonthLabel.bottomAnchor),
            
            overlayView.topAnchor.constraint(equalTo: displayedMonthLabel.layoutMarginsGuide.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.widthAnchor.constraint(equalToConstant: 48),
            overlayView.heightAnchor.constraint(equalToConstant: 60),
            
//            dayHeaderScrollView.topAnchor.constraint(equalTo: displayedMonthLabel.bottomAnchor),
//            dayHeaderScrollView.leadingAnchor.constraint(equalTo: overlayView.trailingAnchor),
//            dayHeaderScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            dayHeaderScrollView.heightAnchor.constraint(equalToConstant: 60),
           
            // Time column scroll view
            timeColumnScrollView.topAnchor.constraint(equalTo: overlayView.bottomAnchor),
            timeColumnScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timeColumnScrollView.widthAnchor.constraint(equalToConstant: 48),
            timeColumnScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
//            // Headers inside scroll views (position at 0,0)
//            dayHeader.topAnchor.constraint(equalTo: dayHeaderScrollView.contentLayoutGuide.topAnchor),
//            dayHeader.leadingAnchor.constraint(equalTo: dayHeaderScrollView.contentLayoutGuide.leadingAnchor),
//            dayHeader.widthAnchor.constraint(equalToConstant: horizontalGroupWidth),
//            dayHeader.heightAnchor.constraint(equalToConstant: 60),
            
            timeColumn.topAnchor.constraint(equalTo: timeColumnScrollView.contentLayoutGuide.topAnchor),
            timeColumn.leadingAnchor.constraint(equalTo: timeColumnScrollView.contentLayoutGuide.leadingAnchor),
            timeColumn.widthAnchor.constraint(equalToConstant: 48),
            timeColumn.heightAnchor.constraint(equalToConstant: singleDayGroupHeight),
            
            collectionView.topAnchor.constraint(equalTo: timeColumnScrollView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: timeColumnScrollView.trailingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
//            eventContainerScrollView.topAnchor.constraint(equalTo: dayHeaderScrollView.bottomAnchor),
//            eventContainerScrollView.leadingAnchor.constraint(equalTo: timeColumnScrollView.trailingAnchor),
//            eventContainerScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            eventContainerScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//
//            eventContainer.topAnchor.constraint(equalTo: eventContainerScrollView.bottomAnchor),
//            eventContainer.leadingAnchor.constraint(equalTo: eventContainerScrollView.trailingAnchor),
//            eventContainer.widthAnchor.constraint(equalToConstant: horizontalGroupWidth),
//            eventContainer.heightAnchor.constraint(equalToConstant: horizontalGroupHeight),
            
            createEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createEventButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            widthConstraint,
            heightConstraint,
            
            createBlendButton.bottomAnchor.constraint(equalTo: createBlendLabel.topAnchor, constant: -5),
            createBlendButton.centerXAnchor.constraint(equalTo: createBlendLabel.centerXAnchor),
            createBlendButton.widthAnchor.constraint(equalToConstant: 50),
            createBlendButton.heightAnchor.constraint(equalToConstant: 50),
            
            createBlendLabel.bottomAnchor.constraint(equalTo: createEventButton.topAnchor),
            createBlendLabel.centerXAnchor.constraint(equalTo: createEventButton.centerXAnchor),
            
            createScheduleEventButton.trailingAnchor.constraint(equalTo: createEventButton.leadingAnchor),
            createScheduleEventButton.centerYAnchor.constraint(equalTo: createEventButton.centerYAnchor),
            createScheduleEventButton.widthAnchor.constraint(equalToConstant: 50),
            createScheduleEventButton.heightAnchor.constraint(equalToConstant: 50),
            
            createScheduleEventLabel.topAnchor.constraint(equalTo: createScheduleEventButton.bottomAnchor, constant: 5),
            createScheduleEventLabel.centerXAnchor.constraint(equalTo: createScheduleEventButton.centerXAnchor),
        ])
        
        setDisplayedDates(centerDate: currentDate)
//        dayHeader.setDates(dayList: dayList)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if hasUserScrolled {
            return
        } else {
//            updateEventsOverlay()
            scrollToCurrentPosition()
        }
    }
    
//    private func updateEventsOverlay() {
//        if let scheduleViewModel = coordinator?.scheduleViewModel {
//            eventContainer.populateEventCells(rootVC: self, scheduleViewModel: scheduleViewModel, events: scheduleViewModel.scheduleEvents, centerDate: currentDate, calendarInterval: numberOfDays)
//        }
//    }
    
    private func setupViewModelObservation() {
        // keep in mind that the fetching of events is handled within this VC's root controller so all we need to do here is watch for changes to the vm's published value
//        coordinator?.scheduleViewModel.$scheduleEvents
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] newEvents in
////                self?.updateEventsOverlay()
//                print("Being called here in view model observation")
//            }
//            .store(in: &cancellables)
    }
    
    @objc
    func showEventSearchMenu() {
        guard let scheduleViewModel = coordinator?.scheduleViewModel else { return }
        
        let eventSearchSheet = EventSearchView(currentUser: scheduleViewModel.currentUser, scheduleEvents: scheduleViewModel.scheduleEvents)
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
    
    @objc func showCreateOptions() {
        self.isExpanded.toggle()
        
        if !isExpanded {
            self.navigationController?.tabBarController?.setTabBarHidden(true, animated: true)
        } else {
            self.navigationController?.tabBarController?.setTabBarHidden(false, animated: true)
        }
        
        let blendOffset: CGFloat = -20 // Move up
        let scheduleOffset: CGFloat = -25 // Move left
        let secondaryAlpha: CGFloat = isExpanded ? 0 : 1
        let blendTransform = isExpanded ? .identity : CGAffineTransform(translationX: -5, y: blendOffset)
        let scheduleTransform = isExpanded ? .identity : CGAffineTransform(translationX: scheduleOffset, y: 0)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseInOut], animations: {
            // Animate main button rotation and size
            self.createEventButton.transform = self.isExpanded ? .identity : CGAffineTransform(rotationAngle: CGFloat.pi/4)
            self.createEventButton.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: self.isExpanded ? 24 : 18, weight: .medium)
            self.createEventButtonWidthConstraint?.constant = self.isExpanded ? 60 : 45
            self.createEventButtonHeightConstraint?.constant = self.isExpanded ? 60 : 45
            self.view.layoutIfNeeded()

            // Animate Blend button and label (move up)
            self.createBlendButton.transform = blendTransform
            self.createBlendButton.alpha = secondaryAlpha
            self.createBlendButton.isHidden = false
            self.createBlendLabel.transform = blendTransform
            self.createBlendLabel.alpha = secondaryAlpha
            self.createBlendLabel.isHidden = false

            // Animate Schedule Event button and label (move left)
            self.createScheduleEventButton.transform = scheduleTransform
            self.createScheduleEventButton.alpha = secondaryAlpha
            self.createScheduleEventButton.isHidden = false
            self.createScheduleEventLabel.transform = scheduleTransform
            self.createScheduleEventLabel.alpha = secondaryAlpha
            self.createScheduleEventLabel.isHidden = false
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            if isExpanded {
                self.createBlendButton.isHidden = true
                self.createBlendLabel.isHidden = true
                self.createScheduleEventButton.isHidden = true
                self.createScheduleEventLabel.isHidden = true
            }
        })
    }
    
    @objc
    func showCreateEvent() {
        
        if let scheduleViewModel = coordinator?.scheduleViewModel, let tabBarState = coordinator?.tabBarState  {
            
            guard let schedule = scheduleViewModel.selectedSchedule else { return }
            
//            self.createEventButton.alpha = 0
//            self.createEventButton.isHidden = true
            
            // since event details view expects a Binding type, and we can't explicity
            // use the $ binding syntax within a view controller, we can create a
            // binding type manually
            
            tabBarState.hideTabbar = true
                        
            // wrap our SwiftUI view in a UIHostingController so that we can display it here in our VC
            // inject our viewModel explicitly as an environment object
            let hostingController = UIHostingController(
                rootView: CreateEventView(currentUser: scheduleViewModel.currentUser, currentScheduleId: schedule.id)
            )
            
            let title = UILabel()
            title.text = "Create Event"
            let preferredFont = UIFont.preferredFont(forTextStyle: .title3)
            title.font = UIFont.monospacedSystemFont(ofSize: preferredFont.pointSize, weight: .bold)
            
            hostingController.navigationItem.titleView = title
            hostingController.navigationController?.tabBarController?.setTabBarHidden(true, animated: false)
            hostingController.navigationController?.isToolbarHidden = false
            hostingController.navigationController?.hidesBarsOnSwipe = true
            navigationController?.pushViewController(hostingController, animated: true)
            
            showCreateOptions()
        }
    }
    
    @objc func showCreateBlend() {
        if let scheduleViewModel = coordinator?.scheduleViewModel, let tabBarState = coordinator?.tabBarState {
            
//            self.createEventButton.alpha = 0
//            self.createEventButton.isHidden = true
            
            // since event details view expects a Binding type, and we can't explicity
            // use the $ binding syntax within a view controller, we can create a
            // binding type manually
            
            tabBarState.hideTabbar = true
                        
            // wrap our SwiftUI view in a UIHostingController so that we can display it here in our VC
            // inject our viewModel explicitly as an environment object
            let hostingController = UIHostingController(
                rootView: CreateBlendView(currentUser: scheduleViewModel.currentUser)
            )
            
            let title = UILabel()
            title.text = "Create Blend"
            let preferredFont = UIFont.preferredFont(forTextStyle: .title3)
            title.font = UIFont.monospacedSystemFont(ofSize: preferredFont.pointSize, weight: .bold)
            
            hostingController.navigationItem.titleView = title
            hostingController.navigationController?.tabBarController?.setTabBarHidden(true, animated: false)
            hostingController.navigationController?.isToolbarHidden = false
            hostingController.navigationController?.hidesBarsOnSwipe = true
            navigationController?.pushViewController(hostingController, animated: true)
            
            showCreateOptions()
        }
    }
    
    func showEventDetails(event: RecurringEvents) {
        if let scheduleViewModel = coordinator?.scheduleViewModel,
           let tabBarState = coordinator?.tabBarState {
            
            guard let schedule = scheduleViewModel.selectedSchedule else { return }
            
            tabBarState.hideTabbar = true
                        
            
        }
    }
    
    // handles the initial scrolling to the current time to give the user an animated experience
    func scrollToCurrentPosition() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date.now)
        
        // Calculate vertical position based on current time
        let itemHeight: CGFloat = 100
        let desiredYOffset = max(0, CGFloat(hour) * itemHeight - 100)
        let maxHeight = Int(itemHeight) * numberOfTimeIntervals
        
        // Calculate the maximum possible y-offset to prevent scrolling too far
        let maxYOffset = CGFloat(maxHeight) - collectionView.frame.height
        
        // Ensure we don't scroll beyond content boundaries
        let safeYOffset = min(desiredYOffset, maxYOffset)
        
        let centerXDay = numberOfDays / 2
        
        positionScroll = CGPoint(x: 0, y: safeYOffset)
        collectionView.scrollToItem(at: IndexPath(item: centerXDay * numberOfTimeIntervals, section: 0), at: .centeredVertically, animated: false)
        
        collectionView.setContentOffset(CGPoint(x: 0.75, y: safeYOffset), animated: false)
//        dayHeaderScrollView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: false)
        timeColumnScrollView.setContentOffset(CGPoint(x: 0, y: safeYOffset), animated: false)
    }
    
    func layout() -> UICollectionViewCompositionalLayout {
        
        // Event Item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .absolute(100))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Vertical Group for a single day
        let singleDayGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                        heightDimension: .absolute(24*100))
        
        let singleDayGroup = NSCollectionLayoutGroup.vertical(layoutSize: singleDayGroupSize,
                                                              subitems: [item])
        
        // Horizontal Group to hold all of the vertical Groups defined above
        let horizontalGroupContainerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                  heightDimension: .absolute(24*100))
        
        let horizontalGroupContainer = NSCollectionLayoutGroup.horizontal(layoutSize: horizontalGroupContainerSize,
                                                                          subitems: [singleDayGroup])
        
        let dayHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        let section = NSCollectionLayoutSection(group: horizontalGroupContainer)
        section.boundarySupplementaryItems = [dayHeader]
        section.orthogonalScrollingBehavior = .groupPaging
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    var shouldIgnorePreviousTrigger = false
    var isLoadingNextDates = false
    var isLoadingPreviousDates = false
    
//    private func loadPreviousDateInterval() {
//        guard !isLoadingPreviousDates else { return }
//        isLoadingPreviousDates = true
//        
//        let currentOffset = collectionView.contentOffset
//        let newOffset = CGPoint(x: currentOffset.x + CGFloat(datesToAdd) * itemWidth, y: currentOffset.y)
//        
//        // Get the first date in current range
//        let firstDate = dayList.first ?? Date()
//        
//        // Add another 30 days
//        var newDays: [Date] = []
//        
//        for i in 1...datesToAdd {
//            if let newDate = Calendar.current.date(byAdding: .day, value: -i, to: firstDate) {
//                newDays.append(newDate)
//            }
//        }
//        
//        // Update the data source with new days
//        dayList.removeLast(datesToAdd)
//        dayList.insert(contentsOf: newDays.reversed(), at: 0)
//        
//        currentDate = firstDate
//                
//        UIView.performWithoutAnimation {
//            collectionView.reloadSections(IndexSet(integer: 0))
//            collectionView.setContentOffset(newOffset, animated: false)
//            dayHeader.addPreviousDates(updatedDayList: newDays)
//            updateEventsOverlay()
//        }
//        
//        isLoadingPreviousDates = false
//    }
//    
//    private func loadNextDateInterval() {
//        guard !isLoadingNextDates else { return }
//        isLoadingNextDates = true
//        
//        // Set a flag to temporarily ignore the previous date loading trigger
//        shouldIgnorePreviousTrigger = true
//        
//        let currentOffset = collectionView.contentOffset
//        let newOffset = CGPoint(x: currentOffset.x - CGFloat(datesToAdd) * itemWidth, y: currentOffset.y)
//        
//        // Get the last date in current range
//        let lastDate = dayList.last ?? Date()
//        
//        // Create new days to add
//        var newDays: [Date] = []
//        for i in 1...datesToAdd {
//            if let newDate = Calendar.current.date(byAdding: .day, value: i, to: lastDate) {
//                newDays.append(newDate)
//            }
//        }
//        
//        // since we've created the new 30 days, we now remove 30 from the beginning of dayList
//        dayList.removeFirst(datesToAdd)
//        dayList.append(contentsOf: newDays)
//        
//        // set the currentDate as the previously saved last date since this is our new 'middle' reference date
//        currentDate = lastDate
//        
//        // necessary to ensure that all of these updates happen without animation to provide the smoothest transition
//        UIView.performWithoutAnimation {
//            // since we reload the section, the offset from this will make our prefetching delegate
//            // call to loadPreviousDateInterval, so we must set ignoring trigger as such
//            shouldIgnorePreviousTrigger = true
//            collectionView.reloadSections(IndexSet(integer: 0))
//            collectionView.setContentOffset(newOffset, animated: false)
//            dayHeader.addNextDates(updatedDayList: newDays)
//            updateEventsOverlay()
//            
//            // before we set it back to false, we set a slight delay in case the new offset does not execute before our
//            // prefetch delegate is called upon
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                self.shouldIgnorePreviousTrigger = false
//            }
//        }
//        
//        isLoadingNextDates = false
//    }
    
    var modifiedCells = Set<UICollectionViewCell>()
    
    deinit {
        modifiedCells.removeAll()
        cancellables.removeAll()
    }
}

extension DayViewController: UICollectionViewDelegate {
    
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
    
//        let dayIndex = Int(scrollView.contentOffset.x / singleDayGroupWidth)
//        
//        if dayIndex >= 0 && dayIndex < dayList.count {
//            let visibleDate = dayList[dayIndex]
//            
//            let month = Calendar.current.component(.month, from: visibleDate) - 1
//            let year = Calendar.current.component(.year, from: visibleDate)
//            
//                    let newMonth = monthsList[month]
//            if newMonth != displayedMonthLabel.text {
//                displayedMonthLabel.text = newMonth
//                displayedYearLabel.text = "\(year)"
//            }
//        }
//                
//        // Sync horizontal scrolling for day header
//        if scrollView.contentOffset.x != previousContentOffsetX {
//            dayHeaderScrollView.contentOffset.x = scrollView.contentOffset.x
//            eventContainerScrollView.contentOffset.x = scrollView.contentOffset.x
//            previousContentOffsetX = scrollView.contentOffset.x
//        }
        
        // Sync vertical scrolling for time column
        if scrollView.contentOffset.y != previousContentOffsetY {
            timeColumnScrollView.contentOffset.y = scrollView.contentOffset.y
//            eventContainerScrollView.contentOffset.y = scrollView.contentOffset.y
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
        let isAtBottomBoundary = maxScrollY > 0 && collectionView.contentOffset.y > maxScrollY + 5
        
        if !isAtTopBoundary && !isAtBottomBoundary {
            resetModifiedCells()
            return
        }
        
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            for cell in self.modifiedCells {
                if let indexPath = self.collectionView.indexPath(for: cell) {
                    // Force layout update for specific cells
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
            self.modifiedCells.removeAll()
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        positionScroll = scrollView.contentOffset
        hideCreateEventButton()
        if !isExpanded {
            showCreateOptions()
        }
        
        if !hasUserScrolled {
            hasUserScrolled = true
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        showCreateEventButton()
    }
    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
//                                   withVelocity velocity: CGPoint,
//                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        let itemWidth: CGFloat = 60
//        let proposedX   = targetContentOffset.pointee.x
//        let page        = round(proposedX / itemWidth)
//        targetContentOffset.pointee.x =  + 0.50
//    }
}

//extension DayViewController: UICollectionViewDataSourcePrefetching {
////    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
////        // calculate the total number of items in the collection view
////        let totalItems = numberOfDays * numberOfTimeIntervals
////        
////        //
////        let endIndex = indexPaths.max(by: { $0.item < $1.item })?.item
////        let startIndex = indexPaths.min(by: { $0.item < $1.item })?.item
////        
////        let daysBeforeThreshold = 7
////        let threshold = numberOfTimeIntervals * daysBeforeThreshold
////        
////        if endIndex ?? totalItems >= (totalItems - threshold) && !isLoadingNextDates {
////            loadNextDateInterval()
////        } else if startIndex ?? 0 <= threshold && !isLoadingPreviousDates && !shouldIgnorePreviousTrigger {
////            loadPreviousDateInterval()
////        }
////    }
//}

extension DayViewController: UICollectionViewDataSource {

    // only need one section for the entire page
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // 24 represents the number of hours in a day => number of cells needed since an item represents a single hour
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfTimeIntervals * 31
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

