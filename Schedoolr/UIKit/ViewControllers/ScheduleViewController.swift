//
//  ScheduleViewController.swift
//  Schedoolr
//
//  Created by David Medina on 2/20/25.
//

import UIKit
import SwiftUI
import Combine

class ScheduleViewController: UIViewController {
    
    var coordinator: ScheduleView.Coordinator?
    
    private var scrollDebounceTimer: Timer?
    
    private var hasUserScrolled: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    var monthsList: [String] = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    
    let weekList: [Int: String] = [
        1 : "Sun",
        2 : "Mon",
        3 : "Tue",
        4 : "Wed",
        5 : "Thu",
        6 : "Fri",
        7 : "Sat"
    ]
    
    // Store the previous horizontal offset
    private var previousContentOffsetX: CGFloat = 0
    
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
    lazy var datesToAdd: Int = numberOfDays / 2
    
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
        
        collectionView.register(CollectionViewDaysHeader.self, forSupplementaryViewOfKind: "DayHeader", withReuseIdentifier: "DayHeader")
        collectionView.register(CollectionViewTimesColumn.self, forSupplementaryViewOfKind: "TimeColumn", withReuseIdentifier: "TimeColumn")
        
        //        older method of cell registration which is handled in the initialization of our collection view
        //        view.register(EventCell.self, forCellWithReuseIdentifier: "EventCell")
        
        collectionView.isDirectionalLockEnabled = true
        collectionView.bounces = false
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "DarkBackground")
        edgesForExtendedLayout = .all
        
        view.addSubview(headerContainerView)
        view.addSubview(displayedDateContainerView)
        
        displayedDateContainerView.addSubview(displayedMonthLabel)
        displayedDateContainerView.addSubview(displayedYearLabel)
        
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
        displayedMonthLabel.textColor = UIColor(red: 202, green: 177, blue: 210, alpha: 1)
        
        displayedDateContainerView.addSubview(displayedMonthLabel)
        displayedDateContainerView.addSubview(displayedYearLabel)
        
        displayedYearLabel.text = "\(displayedYear)"
        displayedYearLabel.font = .systemFont(ofSize: 30, weight: .medium)
        displayedYearLabel.translatesAutoresizingMaskIntoConstraints = false
        
        createEventButton.configuration = .borderless()
        createEventButton.configuration?.image = UIImage(systemName: "plus")
        createEventButton.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        createEventButton.configuration?.baseForegroundColor = .systemTeal
        createEventButton.translatesAutoresizingMaskIntoConstraints = false
        createEventButton.addTarget(self, action: #selector(showCreateEvent), for: .touchUpInside)
        
        view.addSubview(createEventButton)
        
        view.addSubview(overlayView)
        
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
            
            
            collectionView.topAnchor.constraint(equalTo: displayedDateContainerView.bottomAnchor, constant: 5),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            
            overlayView.topAnchor.constraint(equalTo: displayedDateContainerView.bottomAnchor, constant: 5),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.widthAnchor.constraint(equalToConstant: 44),
            overlayView.heightAnchor.constraint(equalToConstant: 60),
            
            createEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            createEventButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            createEventButton.widthAnchor.constraint(equalToConstant: 75),
            createEventButton.heightAnchor.constraint(equalToConstant: 100),
        ])
        
        setDisplayedDates(centerDate: currentDate)
        
        // Access the view model through the coordinator
        if let viewModel = coordinator?.viewModel {
            if let user = coordinator?.authService.currentUser {
                let scheduleId = user.schedules[0]
                Task {
                    await viewModel.fetchSchedule(id: scheduleId)
                    setupViewModelObservation(viewModel: viewModel)
                    print("I have fetched a schedule. Schedule id is: \(viewModel.schedule?.title ?? "No schedule")")
                    scheduleLabel.text = viewModel.schedule?.title
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
        if let eventsOverlay = EventCellsContainer.instance,
           let viewModel = coordinator?.viewModel,
           let events = coordinator?.viewModel.events {
            eventsOverlay.populateEventCells(rootVC: self, viewModel: viewModel, events: events, centerDate: currentDate, calendarInterval: numberOfDays)
        }
    }
    
    private func setupViewModelObservation(viewModel: ScheduleViewModel) {
        // Using Combine for reactive updates
        viewModel.$events
            .receive(on: RunLoop.main)
            .sink { [weak self] newEvents in
                // Update UI when the scheduleItems changes
                self?.updateEventsOverlay()
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
        if let viewModel = coordinator?.viewModel {
            let hostingController = UIHostingController(
                rootView: SidebarView()
                    .environmentObject(viewModel)
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
        if let viewModel = coordinator?.viewModel {
            // wrap our SwiftUI view in a UIHostingController so that we can display it here in our VC
            // inject our viewModel explicitly as an environment object
            let hostingController = UIHostingController(
                rootView: CreateEventView()
                    .environmentObject(viewModel)
            )
            
            hostingController.modalPresentationStyle = .fullScreen
            
            // will present it as a full screen page rather than trying to implement some voodoo method
            // to push our view onto the navigation stack defined in our root view from this VC (possibly hard)
            present(hostingController, animated: true)
        }
    }
    
    //    @objc func showEventDetails() {
    //        let hostingController = UIHostingController(rootView: EventDetailsView())
    //    }
    
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
        let xOffset = CGFloat(currentDayIndex) * itemWidth - 40
        
        collectionView.setContentOffset(CGPoint(x: xOffset, y: safeYOffset), animated: false)
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
        
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .absolute(horizontalGroupWidth),
                                                      heightDimension: .absolute(60))
        
        let dayHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize,
                                                                    elementKind: "DayHeader",
                                                                    alignment: .top)
        
        dayHeader.pinToVisibleBounds = true
        dayHeader.zIndex = 999
        
        let timeColumnSize = NSCollectionLayoutSize(widthDimension: .absolute(44),
                                                    heightDimension: .absolute(singleDayGroupHeight))
        
        let timeColumn = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: timeColumnSize,
                                                                     elementKind: "TimeColumn",
                                                                     alignment: .leading)
        timeColumn.pinToVisibleBounds = true
        timeColumn.zIndex = 999
        
        let eventsOverlay = NSCollectionLayoutDecorationItem.background(elementKind: "EventsOverlay")
        eventsOverlay.contentInsets = NSDirectionalEdgeInsets(top: 60, leading: 0, bottom: 0, trailing: 0)
        eventsOverlay.zIndex = 10  // Above cells but below supplementary items
        
        section.decorationItems = [eventsOverlay]
        section.boundarySupplementaryItems = [timeColumn, dayHeader]
        
        let layout = CustomCompositionalLayout(section: section, scrollableWidth: horizontalGroupWidth)
        layout.register(EventCellsContainer.self, forDecorationViewOfKind: "EventsOverlay")
        
        return layout
    }
    
    func updateVisibleMonthTitle() {
        
        // Calculate current visible day index
        let timeColumnWidth: CGFloat = 44
        let itemWidth: CGFloat = 75
        
        // Get content offset adjusted for time column
        let adjustedOffset = collectionView.contentOffset.x - timeColumnWidth
        
        // Calculate visible day index
        let visibleDayIndex = Int(round(adjustedOffset / itemWidth))
        let safeDayIndex = max(0, min(visibleDayIndex, numberOfDays-1))
        
        // Make sure we have enough days in our list
        guard safeDayIndex < dayList.count else { return }
        
        // Get date from our computed index
        let visibleDate = dayList[safeDayIndex]
        
        // Extract month and year
        let calendar = Calendar.current
        let month = calendar.component(.month, from: visibleDate) - 1 // Months are 1-based, array is 0-based
        let year = calendar.component(.year, from: visibleDate)
        
        // Only update if changed
        let newMonth = monthsList[month]
        let newYear = year
        
        if newMonth != displayedMonthLabel.text || String(newYear) != displayedYearLabel.text {
            // Update our properties
            self.displayedMonth = newMonth
            self.displayedYear = newYear
            
            self.displayedMonthLabel.text = displayedMonth
            self.displayedYearLabel.text = "\(displayedYear)"
        }
    }
    
    var shouldIgnorePreviousTrigger = false
    var isLoadingNextDates = false
    var isLoadingPreviousDates = false
    
    private func loadPreviousDateInterval() {
        guard !isLoadingPreviousDates else { return }
        isLoadingPreviousDates = true
        
        // IMPORTANT: Save current contentOffset before making any changes
        let currentOffset = collectionView.contentOffset
        
        // Get the first date in current range
        let firstDate = dayList.first ?? Date()
        
        // Add another 30 days
        var newDays: [Date] = []
        
        for i in 1...datesToAdd {
            if let newDate = Calendar.current.date(byAdding: .day, value: -i, to: firstDate) {
                newDays.append(newDate)
            }
        }
        
        newDays = newDays.reversed()
        
        for i in 0...(numberOfDays - datesToAdd - 1) {
            newDays.append(dayList[i])
        }
        
        // Update the data source with new days
        dayList = newDays
        
        currentDate = firstDate
        
        // Important: First reload data, then update layout
        collectionView.reloadData()
        
        // Create a new layout with updated dimensions
        let newLayout = self.layout()
        
        // Apply the new layout without animation
        collectionView.setCollectionViewLayout(newLayout, animated: false, completion: { [weak self] completed in
            // Adjust content offset to account for removed days
            var adjustedOffset = currentOffset
            adjustedOffset.x += (self?.singleDayGroupWidth ?? 0) * Double(self?.datesToAdd ?? 0)
            
            self?.updateEventsOverlay()
            
            // RESTORE the adjusted content offset after layout update
            self?.collectionView.contentOffset = adjustedOffset
            self?.isLoadingPreviousDates = false
        })
    }
    
    private func loadNextDateInterval() {
        guard !isLoadingNextDates else { return }
        isLoadingNextDates = true
        
        // Set a flag to temporarily ignore the previous date loading trigger
        shouldIgnorePreviousTrigger = true
        
        // IMPORTANT: Save current contentOffset before making any changes
        let currentOffset = collectionView.contentOffset
        
        // Get the last date in current range
        let lastDate = dayList.last ?? Date()
        
        // Add another 30 days
        var newDays: [Date] = []
        for i in 1...datesToAdd {
            if let newDate = Calendar.current.date(byAdding: .day, value: i, to: lastDate) {
                newDays.append(newDate)
            }
        }
        
        dayList.removeFirst(datesToAdd)
        
        // Update the data source with new days
        dayList.append(contentsOf: newDays)
        
        currentDate = lastDate
        
        // Important: First reload data, then update layout
        collectionView.reloadData()
        
        // Create a new layout with updated dimensions
        let newLayout = self.layout()
        
        // Apply the new layout without animation
        collectionView.setCollectionViewLayout(newLayout, animated: false, completion: { [weak self] completed in
            // Adjust content offset to account for removed days
            var adjustedOffset = currentOffset
            adjustedOffset.x -= (self?.singleDayGroupWidth ?? 0) * Double(self?.datesToAdd ?? 0)

            self?.updateEventsOverlay()
            
            // RESTORE the adjusted content offset after layout update
            self?.collectionView.contentOffset = adjustedOffset
            self?.isLoadingNextDates = false
            
            // Add a small delay before allowing previous triggers again
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self?.shouldIgnorePreviousTrigger = false
            }
        })
    }
}

extension ScheduleViewController: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // check if the user has scrolled in the horizontal direction to trigger the block
        if collectionView.contentOffset.x != previousContentOffsetX {
            // cancel previous timers
            scrollDebounceTimer?.invalidate()
            
            // creates a timer that will call the function after 0.1 seconds of delay of the function not being called
            // (0.1s of no horizontal scrolling)
            scrollDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
                self?.updateVisibleMonthTitle()
            }
            previousContentOffsetX = collectionView.contentOffset.x
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideCreateEventButton()
        
        if !hasUserScrolled {
            hasUserScrolled = true
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            snapCellPosition()
        }
        showCreateEventButton()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapCellPosition()
    }
    
    func snapCellPosition() {
        collectionView.stopScrollingAndZooming()
        
        let timeColumnWidth: CGFloat = 44
        let itemWidth: CGFloat = 75
        
        // Get the total offset from the left edge
        let totalOffset = collectionView.contentOffset.x
        
        // Calculate which day we're closest to, accounting for the time column
        let adjustedOffset = totalOffset - timeColumnWidth
        let estimatedIndex = round(adjustedOffset / itemWidth)
        
        // Ensure the index is within bounds (0 to 59 for your 60 days)
        let safeIndex = max(0, min(Int(estimatedIndex), numberOfDays-1))
        
        // Calculate the precise final position
        // Add a small adjustment factor (e.g., 1-2 points) if needed to fine-tune alignment
        let finalXOffset = (CGFloat(safeIndex) * itemWidth) + timeColumnWidth-12
        
        // Maintain the current y offset
        let currentYOffset = collectionView.contentOffset.y
        
        collectionView.setContentOffset(CGPoint(x: finalXOffset, y: currentYOffset), animated: true)
    }
}

extension ScheduleViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let totalItems = numberOfDays * numberOfTimeIntervals
        
        let endIndex = indexPaths.max(by: { $0.item < $1.item })?.item
        let startIndex = indexPaths.min(by: { $0.item < $1.item })?.item
        
        let daysBeforeThreshold = 12
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
        return 24 * numberOfDays
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == "TimeColumn" {
            let timeView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TimeColumn", for: indexPath) as! CollectionViewTimesColumn
            return timeView
        } else if kind == "DayHeader" {
            let dayView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DayHeader", for: indexPath) as! CollectionViewDaysHeader
            dayView.setDates(dayList: dayList, weekList: weekList)
            return dayView
        }
        
        return UICollectionReusableView()
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

class CustomCompositionalLayout: UICollectionViewCompositionalLayout {
    var scrollableWidth: CGFloat
    
    init(section: NSCollectionLayoutSection, scrollableWidth: CGFloat) {
        self.scrollableWidth = scrollableWidth
        super.init(section: section)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // this function is called every time the collection view asks for it's registered attributes
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        // search through our defined attributes which include the collection view's cells, supplementary items, and decoration items
        for attribute in attributes {
            // the whole idea of this custom class was to manipulate the decoration item to "match" the width of our collection view
            // even though technically the EventsOverlay has a width the size of the visible screen, we force it to think
            // that it has a width the size of the collection view so that we can actually overlay our events throughout the collection view
            if attribute.representedElementKind == "EventsOverlay" {
                var frame = attribute.frame
                frame.size.width = scrollableWidth
                attribute.frame = frame
            }
        }
        
        return attributes
    }
}
