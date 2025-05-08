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
}


class ScheduleViewController: UIViewController {
    
    var coordinator: ScheduleView.Coordinator?
    
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
    
    var currentDate = Date()
    
    lazy var numberOfTimeIntervals: Int = 24
    lazy var numberOfDays: Int = 60
    lazy var itemWidth: CGFloat = 75
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
        let endINdex = numberOfDays / 2
        
        if (currentDate == centerDate) {
            for index in startIndex..<endINdex {
                dayList.append(Calendar.current.date(byAdding: .day, value: index, to: centerDate) ?? Date())
            }
        }
    }
    
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
        return scrollView
    }()
    
    let spinner = UIActivityIndicatorView(style: .large)
    func showLoading() {
        view.addSubview(spinner)
        spinner.center = view.center
        spinner.startAnimating()
    }
    
    func hideLoading() {
      spinner.stopAnimating()
        spinner.hidesWhenStopped = true
      spinner.removeFromSuperview()
        spinner.isHidden = true
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
        headerContainerView.isHidden           = false
        displayedDateContainerView.isHidden    = false
        dayHeaderScrollView.isHidden           = false
        timeColumnScrollView.isHidden          = false
        collectionView.isHidden                = false
        eventContainerScrollView.isHidden      = false
        overlayView.isHidden                   = false
        createEventButton.isHidden             = false
        
        // 4️⃣ Update the title/header
        scheduleLabel.text                     = schedule.title
        displayedMonthLabel.text               = displayedMonth
        displayedYearLabel.text                = "\(displayedYear)"
        
        // 5️⃣ Populate your events
        updateEventsOverlay()
    }

      /// Call this when `userSchedule == nil`
    func blankSchedule() {
        hideLoading()
        
        // hide calendar views
        headerContainerView.isHidden           = true
        displayedDateContainerView.isHidden    = true
        dayHeaderScrollView.isHidden           = true
        timeColumnScrollView.isHidden          = true
        collectionView.isHidden                = true
        eventContainerScrollView.isHidden      = true
        overlayView.isHidden                   = true
        createEventButton.isHidden             = true
        
        // show placeholder
        let label = UILabel()
        label.text = "You don’t have a schedule yet."
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let button = UIButton(type: .system)
        button.setTitle("Create Schedule", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.addTarget(self, action: #selector(didTapCreateSchedule), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        // keep strong refs so we can remove them later
        placeholderLabel        = label
        createScheduleButton    = button
    }
    
    // your action to kick off creation
    @objc private func didTapCreateSchedule() {
        if let scheduleViewModel = coordinator?.scheduleViewModel {
            Task {
                await scheduleViewModel.createSchedule(title: "\(scheduleViewModel.currentUser.displayName)'s Schedule")
            }
        }
    }
    
    let eventContainer = EventCellsContainer()
    
    let sidebarButton = UIButton()
    let scheduleLabel = UILabel()
    let headerContainerView = UIView()
    
    let overlayView = UIView()
    
    let displayedMonthLabel = UILabel()
    let displayedYearLabel = UILabel()
    let searchButton = UIButton()
    let displayedDateContainerView = UIView()
    
    let exampleEvent = UIView()
    
    let createEventButton = UIButton()
    
    let dayHeader = CollectionViewDaysHeader()
    let timeColumn = CollectionViewTimesColumn()
    
    private lazy var dayHeaderScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = false // We'll control this programmatically
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentSize = CGSize(width: horizontalGroupWidth, height: 60)
        return scrollView
    }()

    private lazy var timeColumnScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = false // We'll control this programmatically
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentSize = CGSize(width: 44, height: singleDayGroupHeight)
        return scrollView
    }()
    
    private var isHandlingScroll = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "DarkBackground")
        edgesForExtendedLayout = .all
        
        view.addSubview(headerContainerView)
        view.addSubview(displayedDateContainerView)
        
        displayedDateContainerView.addSubview(displayedMonthLabel)
        displayedDateContainerView.addSubview(displayedYearLabel)
        
        collectionView.backgroundColor = UIColor(named: "DarkBackground")
        
        // add the collection view to root view
        view.addSubview(collectionView)
        
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = UIColor(named: "DarkBackground")
        
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 20)
        
        searchButton.configuration = .borderless()
        searchButton.configuration?.image = UIImage(systemName: "magnifyingglass")
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        searchButton.addTarget(self, action: #selector(toggleSidebar), for: .touchUpInside)
        searchButton.configuration?.baseForegroundColor = UIColor(named: "PrimaryTextColor")
        
        sidebarButton.configuration = .borderless()
        sidebarButton.configuration?.image = UIImage(systemName: "line.horizontal.3")
        sidebarButton.translatesAutoresizingMaskIntoConstraints = false
        sidebarButton.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        sidebarButton.addTarget(self, action: #selector(toggleSidebar), for: .touchUpInside)
        sidebarButton.configuration?.baseForegroundColor = UIColor(named: "PrimaryTextColor")
        
        scheduleLabel.text = "Nil"
        scheduleLabel.font = .systemFont(ofSize: 24, weight: .medium)
        scheduleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerContainerView.addSubview(sidebarButton)
        headerContainerView.addSubview(scheduleLabel)
        headerContainerView.addSubview(searchButton)
                
        displayedDateContainerView.translatesAutoresizingMaskIntoConstraints = false
        displayedDateContainerView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 3)
        
        displayedMonthLabel.text = displayedMonth
        displayedMonthLabel.font = .systemFont(ofSize: 30, weight: .bold)
        displayedMonthLabel.translatesAutoresizingMaskIntoConstraints = false
        displayedMonthLabel.textAlignment = .right
        displayedMonthLabel.textColor = UIColor(named: "PrimaryTextColor")
        
        displayedDateContainerView.addSubview(displayedMonthLabel)
        displayedDateContainerView.addSubview(displayedYearLabel)
        
        displayedYearLabel.text = "\(displayedYear)"
        displayedYearLabel.font = .systemFont(ofSize: 30, weight: .medium)
        displayedYearLabel.translatesAutoresizingMaskIntoConstraints = false
        
        timeColumn.translatesAutoresizingMaskIntoConstraints = false
        dayHeader.translatesAutoresizingMaskIntoConstraints = false
        
        createEventButton.configuration = .borderless()
        createEventButton.configuration?.image = UIImage(systemName: "plus")
        createEventButton.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        createEventButton.configuration?.baseForegroundColor = .systemTeal
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
        
        eventContainerScrollView.addSubview(eventContainer)
        
        view.addSubview(eventContainerScrollView)
        
        // constraints for our collection view
        NSLayoutConstraint.activate([
            headerContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            sidebarButton.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            sidebarButton.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            sidebarButton.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            
            scheduleLabel.leadingAnchor.constraint(equalTo: sidebarButton.trailingAnchor),
            scheduleLabel.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            scheduleLabel.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            
            displayedDateContainerView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: 15),
            displayedDateContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            displayedDateContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            displayedMonthLabel.topAnchor.constraint(equalTo: displayedDateContainerView.topAnchor),
            displayedMonthLabel.leadingAnchor.constraint(equalTo: displayedDateContainerView.layoutMarginsGuide.leadingAnchor),
            displayedMonthLabel.bottomAnchor.constraint(equalTo: displayedDateContainerView.bottomAnchor),
            
            displayedYearLabel.topAnchor.constraint(equalTo: displayedDateContainerView.topAnchor),
            displayedYearLabel.leadingAnchor.constraint(equalTo: displayedMonthLabel.trailingAnchor, constant: 5),
            displayedYearLabel.bottomAnchor.constraint(equalTo: displayedDateContainerView.bottomAnchor),
            
            searchButton.trailingAnchor.constraint(equalTo: displayedDateContainerView.layoutMarginsGuide.trailingAnchor),
            searchButton.topAnchor.constraint(equalTo: displayedDateContainerView.topAnchor),
            searchButton.bottomAnchor.constraint(equalTo: displayedDateContainerView.bottomAnchor),
            
            dayHeaderScrollView.topAnchor.constraint(equalTo: displayedDateContainerView.bottomAnchor, constant: 5),
            dayHeaderScrollView.leadingAnchor.constraint(equalTo: overlayView.trailingAnchor),
            dayHeaderScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dayHeaderScrollView.heightAnchor.constraint(equalToConstant: 60),
           
            // Time column scroll view
            timeColumnScrollView.topAnchor.constraint(equalTo: overlayView.bottomAnchor),
            timeColumnScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timeColumnScrollView.widthAnchor.constraint(equalToConstant: 48),
            timeColumnScrollView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            
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
            collectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            
            eventContainerScrollView.topAnchor.constraint(equalTo: dayHeaderScrollView.bottomAnchor),
            eventContainerScrollView.leadingAnchor.constraint(equalTo: timeColumnScrollView.trailingAnchor),
            eventContainerScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            eventContainerScrollView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),

            eventContainer.topAnchor.constraint(equalTo: eventContainerScrollView.bottomAnchor),
            eventContainer.leadingAnchor.constraint(equalTo: eventContainerScrollView.trailingAnchor),
            eventContainer.widthAnchor.constraint(equalToConstant: horizontalGroupWidth),
            eventContainer.heightAnchor.constraint(equalToConstant: horizontalGroupHeight),
            
            overlayView.topAnchor.constraint(equalTo: displayedDateContainerView.bottomAnchor, constant: 5),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.widthAnchor.constraint(equalToConstant: 48),
            overlayView.heightAnchor.constraint(equalToConstant: 60),
            
            createEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            createEventButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            createEventButton.widthAnchor.constraint(equalToConstant: 75),
            createEventButton.heightAnchor.constraint(equalToConstant: 100),
        ])
        
        setDisplayedDates(centerDate: currentDate)
        dayHeader.setDates(dayList: dayList)
        
        // Access the view model through the coordinator
        if let scheduleViewModel = coordinator?.scheduleViewModel {
            Task {
                setupViewModelObservation(viewModel: scheduleViewModel)
                await scheduleViewModel.fetchSchedule()
                await scheduleViewModel.fetchEvents()
                if let schedule = scheduleViewModel.userSchedule {
                    print("I have fetched a schedule. Schedule id is: \(schedule.id)")
                    scheduleLabel.text = schedule.title
                }
            }
        }
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
    
    private func updateEventsOverlay() {
        if let scheduleViewModel = coordinator?.scheduleViewModel {
            eventContainer.populateEventCells(rootVC: self, scheduleViewModel: scheduleViewModel, events: scheduleViewModel.scheduleEvents, centerDate: currentDate, calendarInterval: numberOfDays)
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
            } else {
                self?.hideLoading()
                self?.blankSchedule()
            }
          }
          .store(in: &cancellables)
        
        //        viewModel.$isLoading
        //            .receive(on: RunLoop.main)
        //            .sink { [weak self] isLoading in
        //                // Show/hide loading indicator based on loading state
        //                if isLoading {
        //                    self?.activityIndicator.startAnimating()
        //                } else {
        //                    self?.activityIndicator.stopAnimating()
        //                }
        //            }
        //            .store(in: &cancellables)
        //
        //        viewModel.$error
        //            .receive(on: RunLoop.main)
        //            .compactMap { $0 } // Only proceed with non-nil errors
        //            .sink { [weak self] error in
        //                // Show error alert when an error occurs
        //                self?.showErrorAlert(message: error.localizedDescription)
        //            }
        //            .store(in: &cancellables)
    }
    
    @objc func toggleSidebar() {
        if let scheduleViewModel = coordinator?.scheduleViewModel {
            let hostingController = UIHostingController(
                rootView: SidebarView()
                    .environmentObject(scheduleViewModel)
            )
            
            hostingController.modalPresentationStyle = .overFullScreen
            present(hostingController, animated: true)
        }
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
    
    @objc func showCreateEvent() {
        if let scheduleViewModel = coordinator?.scheduleViewModel {
            // wrap our SwiftUI view in a UIHostingController so that we can display it here in our VC
            // inject our viewModel explicitly as an environment object
            let hostingController = UIHostingController(
                rootView: CreateEventView()
                    .environmentObject(scheduleViewModel)
            )
            
            hostingController.modalPresentationStyle = .fullScreen
            
            // will present it as a full screen page rather than trying to implement some voodoo method
            // to push our view onto the navigation stack defined in our root view from this VC (possibly hard)
            present(hostingController, animated: true)
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
        let itemWidth: CGFloat = 75
        
        // initial horizontal offset so that the current day is the first day displayed
        let xOffset = CGFloat(currentDayIndex) * itemWidth
        
        collectionView.setContentOffset(CGPoint(x: xOffset, y: safeYOffset), animated: false)
        
        UIView.performWithoutAnimation {
            dayHeader.frame.origin.x += xOffset
            timeColumn.frame.origin.y += safeYOffset
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
            self.snapCellPosition()
        }
        
        isLoadingPreviousDates = false
    }
    
    private func loadNextDateInterval() {
        guard !isLoadingNextDates else { return }
        isLoadingNextDates = true
        
        // Set a flag to temporarily ignore the previous date loading trigger
        shouldIgnorePreviousTrigger = true
        
        let currentOffset = collectionView.contentOffset
        let newOffset = CGPoint(x: currentOffset.x - CGFloat(datesToAdd-1) * itemWidth, y: currentOffset.y)
        
        // Get the last date in current range
        let lastDate = dayList.last ?? Date()
        
        // Create new days to add
        var newDays: [Date] = []
        for i in 1..<datesToAdd {
            if let newDate = Calendar.current.date(byAdding: .day, value: i, to: lastDate) {
                newDays.append(newDate)
            }
        }
        
        // since we've created the new 30 days, we now remove 30 from the beginning of dayList
        dayList.removeFirst(datesToAdd-1)
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
            self.snapCellPosition()
            
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
        let tolerance: CGFloat = 15
        
        // Calculate the maximum scroll position (without adding tolerance yet)
        let maxScrollY = collectionView.contentSize.height - collectionView.bounds.height
        
        // Check for boundary conditions with proper tolerance
        let isAtTopBoundary = collectionView.contentOffset.y < 0
        let isAtBottomBoundary = maxScrollY > 0 && collectionView.contentOffset.y > maxScrollY + tolerance
        
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
                print("I'm here")
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
        } else {
            resetModifiedCells()
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
        hideCreateEventButton()
        
        if !hasUserScrolled {
            hasUserScrolled = true
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            resetModifiedCells()
            snapCellPosition()
        }
        showCreateEventButton()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView) {
        resetModifiedCells()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapCellPosition()
        resetModifiedCells()
    }
    
    func snapCellPosition() {
        let itemWidth: CGFloat = 75
        
        // Get the total offset from the left edge
        let totalOffset = collectionView.contentOffset.x
        
        // Calculate which day we're closest to, accounting for the time column
        let estimatedIndex = round(totalOffset / itemWidth)
        
        // Ensure the index is within bounds (0 to 59 for your 60 days)
        let safeIndex = max(0, min(Int(estimatedIndex), numberOfDays-1))
        
        // Calculate the precise final position
        let finalXOffset = (CGFloat(safeIndex) * itemWidth)
        
        // Maintain the current y offset
        let currentYOffset = collectionView.contentOffset.y
        
        collectionView.setContentOffset(CGPoint(x: finalXOffset, y: currentYOffset), animated: true)
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

protocol SchedulrRootViewwController: UIViewController {
    var displayedMonth: String { get set }
}

