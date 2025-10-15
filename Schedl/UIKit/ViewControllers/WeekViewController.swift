//
//  WeekViewController.swift
//  Schedl
//
//  Created by David Medina on 2/20/25.
//

import UIKit
import SwiftUI
import Combine

struct WeekCalendarPreviewViewRepresentable: UIViewControllerRepresentable {
    
    var centerDay: Date
    
    init(centerDay: Date) {
        self.centerDay = centerDay
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = WeekViewController(centerDay: centerDay)
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}

#Preview {
    let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    let centerDay = Calendar.current.date(from: dateComponents) ?? Date()
    
    WeekCalendarPreviewViewRepresentable(centerDay: centerDay)
}

//#Preview {
//    
//    let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
//    let centerDay = Calendar.current.date(from: dateComponents)!
//    
////    NavigationStack {
//        WeekCalendarPreviewViewRepresentable(centerDay: centerDay)
//            .ignoresSafeArea(edges: [.bottom, .top])
////            .toolbar {
////                ToolbarItem(placement: .topBarTrailing) {
////                    Button(action: {
////                        
////                    }, label: {
////                        Image(systemName: "magnifyingglass")
////                            .font(.system(size: 18))
////                            .fontWeight(.semibold)
////                            .foregroundStyle(Color("NavItemsColors"))
////                    })
////                }
////                
////                ToolbarItem(placement: .topBarTrailing) {
////                    Menu {
////                    } label: {
////                        Image(systemName: "ellipsis")
////                            .font(.system(size: 18))
////                            .fontWeight(.semibold)
////                            .foregroundStyle(Color("NavItemsColors"))
////                    }
////                }
////            }
////    }
//}

protocol InnerCellScrollDelegate: AnyObject {
    func innerCellDidScroll(to offset: CGPoint, from cell: UICollectionViewCell)
}

protocol WeekCalendarViewDelegate: AnyObject {
    func showEventDetails(for event: EventOccurrence, and user: User, from view: UIView)
}

class WeekViewController: UIViewController, VCCoordinatorProtocol {
        
    var coordinator: CalendarYearView.Coordinator?
    
    private var hasUserScrolled: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var previousContentOffsetX: CGFloat = 0
    private var previousContentOffsetY: CGFloat = 0
    
    let calendarTypeButton = UIButton()
    var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search Events"
        searchController.searchBar.sizeToFit()
        return searchController
    }()
        
    var centerDay: Date
    
    private var currentYOffset: CGFloat = 0.0
    
    lazy var displayedYear = Calendar.current.component(.year, from: centerDay)
    lazy var displayedMonth = Calendar.current.monthSymbols[Calendar.current.component(.month, from: centerDay) - 1]
    
    lazy var dates: [Date] = {
        let numberOfDays = 180
        return (-numberOfDays...numberOfDays).map { index in
            Calendar.current.date(byAdding: .day, value: index, to: centerDay)!
        }
    }()
    
    var createEventButtonWidthConstraint: NSLayoutConstraint?
    var createEventButtonHeightConstraint: NSLayoutConstraint?
    
    var positionScroll: CGPoint = .zero
    let buttonColors: ButtonColors = [ButtonColors.palette1, ButtonColors.palette2, ButtonColors.palette3, ButtonColors.palette4].randomElement()!
    
    var collectionView: UICollectionView!
    
    var isExpanded = true
    
    let createEventButton = UIButton()
    
    let createBlendButton = UIButton()
    let createBlendLabel = UILabel()
    
    let createScheduleEventButton = UIButton()
    let createScheduleEventLabel = UILabel()
    
    let createScheduleButton = UIButton()
    let createScheduleLabel = UILabel()
    
    private var isHandlingScroll = false
    
    init(centerDay: Date) {
        self.centerDay = centerDay
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setupViewModelObservation()
        
        view.backgroundColor = UIColor(Color("BackgroundColor"))
        
        setupUI()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(DayColumnView.self, forCellWithReuseIdentifier: DayColumnView.identifier)
//        collectionView.register(
//            WeekHeaderView.self,
//            forSupplementaryViewOfKind: WeekHeaderView.identifier,
//            withReuseIdentifier: WeekHeaderView.identifier
//        )
        collectionView.register(
            WeekdayCellView.self,
            forSupplementaryViewOfKind: WeekdayCellView.identifier,
            withReuseIdentifier: WeekdayCellView.identifier
        )
//        collectionView.register(
//            TimeColumnView.self,
//            forSupplementaryViewOfKind: TimeColumnView.identifier,
//            withReuseIdentifier: TimeColumnView.identifier
//        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showCreateEventButton(createEventButton)
        
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        
//        
//        navigationController?.setToolbarHidden(false, animated: true)
//    }
    
    //    private func createCalendarTypeMenu() -> UIMenu {
    //
    //    }
        
    @objc
    private func showSearchField() {
        present(searchController, animated: true, completion: nil)
    }
    
    private func setupUI() {
        
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "ellipsis")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold, scale: .default)
        
        calendarTypeButton.configuration = config
        calendarTypeButton.showsMenuAsPrimaryAction = true
        
        let searchBarItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(showSearchField))
        let calendarTypeItem = UIBarButtonItem(customView: calendarTypeButton)
        
        navigationItem.rightBarButtonItems = [calendarTypeItem, searchBarItem]
        
//        let boundaryItemSize = NSCollectionLayoutSize(
//            widthDimension: .absolute(60),
//            heightDimension: .fractionalHeight(1.0)
//        )
//        let boundaryHeader = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: boundaryItemSize,
//            elementKind: TimeColumnView.identifier,
//            alignment: .topLeading
//        )
//        boundaryHeader.pinToVisibleBounds = true
//        boundaryHeader.zIndex = 40
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
//        configuration.boundarySupplementaryItems = [boundaryHeader]

        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            
            let numberOfTimeIntervals: CGFloat = 24
            let itemWidth: CGFloat = 60
            let itemHeight: CGFloat = 100
            
            // An item that fills the entire group
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // A group that is the full width and height of the collection view's visible area
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .absolute(itemWidth),
                heightDimension: .fractionalHeight(1.0)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            // --- ADD THIS BLOCK ---
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .absolute(60),
                heightDimension: .absolute(50)
            )

            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: WeekdayCellView.identifier,
                alignment: .top
            )
            sectionHeader.pinToVisibleBounds = true
            sectionHeader.zIndex = 20
            
            section.boundarySupplementaryItems = [sectionHeader]
            
            return section
        }, configuration: configuration)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isDirectionalLockEnabled = true
        collectionView.bouncesVertically = false
        
        if #available(iOS 26.0, *) {
            createEventButton.configuration = .prominentGlass()
            createBlendButton.configuration = .prominentGlass()
            createScheduleButton.configuration = .prominentGlass()
            createScheduleEventButton.configuration = .prominentGlass()
        } else {
            createEventButton.configuration = .filled()
            createBlendButton.configuration = .filled()
            createScheduleButton.configuration = .filled()
            createScheduleEventButton.configuration = .filled()
        }
        createEventButton.configuration?.cornerStyle = .capsule
        createEventButton.configuration?.baseBackgroundColor = buttonColors.backgroundColor
        createEventButton.configuration?.image = UIImage(systemName: "plus")
        createEventButton.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        createEventButton.configuration?.baseForegroundColor = buttonColors.foregroundColor
        createEventButton.translatesAutoresizingMaskIntoConstraints = false
        createEventButton.addTarget(self, action: #selector(showCreateOptions), for: .touchUpInside)
        
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
        createBlendLabel.textColor = .primaryText
        createBlendLabel.isHidden = true
        createBlendLabel.alpha = 0
        
        
        createScheduleButton.configuration?.cornerStyle = .capsule
        createScheduleButton.configuration?.baseBackgroundColor = buttonColors.backgroundColor
        createScheduleButton.configuration?.image = UIImage(systemName: "calendar.badge.plus")
        createScheduleButton.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        createScheduleButton.configuration?.baseForegroundColor = buttonColors.foregroundColor
        createScheduleButton.translatesAutoresizingMaskIntoConstraints = false
        createScheduleButton.addTarget(self, action: #selector(showCreateSchedule), for: .touchUpInside)
        createScheduleButton.isHidden = true
        createScheduleButton.alpha = 0
        
        createScheduleLabel.text = "Create Schedule"
        createScheduleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        createScheduleLabel.translatesAutoresizingMaskIntoConstraints = false
        createScheduleLabel.textColor = .primaryText
        createScheduleLabel.isHidden = true
        createScheduleLabel.alpha = 0
        
        
        createScheduleEventButton.configuration?.cornerStyle = .capsule
        createScheduleEventButton.configuration?.baseBackgroundColor = buttonColors.backgroundColor
        createScheduleEventButton.configuration?.image = UIImage(systemName: "calendar.day.timeline.left")
        createScheduleEventButton.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        createScheduleEventButton.configuration?.baseForegroundColor = buttonColors.foregroundColor
        createScheduleEventButton.translatesAutoresizingMaskIntoConstraints = false
        createScheduleEventButton.addTarget(self, action: #selector(showCreateEvent), for: .touchUpInside)
        createScheduleEventButton.isHidden = true
        createScheduleEventButton.alpha = 0
        
        createScheduleEventLabel.text = "Create Event"
        createScheduleEventLabel.font = .systemFont(ofSize: 12, weight: .bold)
        createScheduleEventLabel.translatesAutoresizingMaskIntoConstraints = false
        createScheduleEventLabel.textColor = .primaryText
        createScheduleEventLabel.isHidden = true
        createScheduleEventLabel.alpha = 0
        
        view.addSubview(collectionView)
//        view.addSubview(createEventButton)
//        view.addSubview(createBlendButton)
//        view.addSubview(createBlendLabel)
//        view.addSubview(createScheduleButton)
//        view.addSubview(createScheduleLabel)
//        view.addSubview(createScheduleEventButton)
//        view.addSubview(createScheduleEventLabel)
        
        // constraints for our collection view
        let widthConstraint = createEventButton.widthAnchor.constraint(equalToConstant: 60)
        let heightConstraint = createEventButton.heightAnchor.constraint(equalToConstant: 60)
        createEventButtonWidthConstraint = widthConstraint
        createEventButtonHeightConstraint = heightConstraint
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
//            createEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            createEventButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
//            widthConstraint,
//            heightConstraint,
//            
//            // Center createBlendButton on the main button
//            createBlendButton.centerXAnchor.constraint(equalTo: createEventButton.centerXAnchor),
//            createBlendButton.centerYAnchor.constraint(equalTo: createEventButton.centerYAnchor),
//            createBlendButton.widthAnchor.constraint(equalToConstant: 50),
//            createBlendButton.heightAnchor.constraint(equalToConstant: 50),
//            
//            // Position its label
//            createBlendLabel.topAnchor.constraint(equalTo: createBlendButton.bottomAnchor, constant: 2),
//            createBlendLabel.centerXAnchor.constraint(equalTo: createBlendButton.centerXAnchor),
//            
//            // Center createScheduleButton on the main button
//            createScheduleButton.centerXAnchor.constraint(equalTo: createEventButton.centerXAnchor),
//            createScheduleButton.centerYAnchor.constraint(equalTo: createEventButton.centerYAnchor),
//            createScheduleButton.widthAnchor.constraint(equalToConstant: 50),
//            createScheduleButton.heightAnchor.constraint(equalToConstant: 50),
//            
//            // Position its label
//            createScheduleLabel.topAnchor.constraint(equalTo: createScheduleButton.bottomAnchor, constant: 2),
//            createScheduleLabel.centerXAnchor.constraint(equalTo: createScheduleButton.centerXAnchor),
//            
//            // Center createScheduleEventButton on the main button
//            createScheduleEventButton.centerXAnchor.constraint(equalTo: createEventButton.centerXAnchor),
//            createScheduleEventButton.centerYAnchor.constraint(equalTo: createEventButton.centerYAnchor),
//            createScheduleEventButton.widthAnchor.constraint(equalToConstant: 50),
//            createScheduleEventButton.heightAnchor.constraint(equalToConstant: 50),
//            
//            // Position its label
//            createScheduleEventLabel.topAnchor.constraint(equalTo: createScheduleEventButton.bottomAnchor, constant: 2),
//            createScheduleEventLabel.centerXAnchor.constraint(equalTo: createScheduleEventButton.centerXAnchor),
        ])
    }
    
    private func setupViewModelObservation() {
        coordinator?.vm.$scheduleEvents
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newEvents in
                guard let self = self else { return }
            }
            .store(in: &cancellables)
    }
    
    @objc func showEventSearchMenu() {
//        guard coordinator?.vm != nil else { return }
        hasUserScrolled = true
    }
    
    func showCreateEventButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.5, animations: {
            button.alpha = 1
            button.isHidden = false
        })
    }
    
    func hideCreateEventButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.5, animations: {
            button.alpha = 0
        }) { (finished) in
            button.isHidden = finished
        }
    }
    
    @objc func showCreateOptions() {
        self.isExpanded.toggle()
        UISelectionFeedbackGenerator().selectionChanged()
        hasUserScrolled = true
        if !isExpanded {
            self.navigationController?.tabBarController?.setTabBarHidden(true, animated: true)
        } else {
            self.navigationController?.tabBarController?.setTabBarHidden(false, animated: true)
        }
        
        let radius: CGFloat = 112.5
        let angle1 = 90.0  * .pi / 180.0 // 90 degrees (Up)
        let angle2 = 135.0 * .pi / 180.0 // 135 degrees (Diagonal)
        let angle3 = 180.0 * .pi / 180.0 // 180 degrees (Left)

        let secondaryAlpha: CGFloat = isExpanded ? 0 : 1

        // Calculate the transform for each button
        // Note: We negate the 'y' value because positive 'y' is down in CGAffineTransform
        let blendTransform = isExpanded ? .identity : CGAffineTransform(
            translationX: radius * cos(angle1),
            y: -radius * sin(angle1)
        )

        let eventTransform = isExpanded ? .identity : CGAffineTransform(
            translationX: radius * cos(angle2),
            y: -radius * sin(angle2)
        )

        let scheduleTransform = isExpanded ? .identity : CGAffineTransform(
            translationX: radius * cos(angle3),
            y: -radius * sin(angle3)
        )
        
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
            
            // Animate Blend button and label (move up)
            self.createScheduleButton.transform = scheduleTransform
            self.createScheduleButton.alpha = secondaryAlpha
            self.createScheduleButton.isHidden = false
            self.createScheduleLabel.transform = scheduleTransform
            self.createScheduleLabel.alpha = secondaryAlpha
            self.createScheduleLabel.isHidden = false

            // Animate Schedule Event button and label (move left)
            self.createScheduleEventButton.transform = eventTransform
            self.createScheduleEventButton.alpha = secondaryAlpha
            self.createScheduleEventButton.isHidden = false
            self.createScheduleEventLabel.transform = eventTransform
            self.createScheduleEventLabel.alpha = secondaryAlpha
            self.createScheduleEventLabel.isHidden = false
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            if isExpanded {
                self.createBlendButton.isHidden = true
                self.createBlendLabel.isHidden = true
                self.createScheduleButton.isHidden = true
                self.createScheduleLabel.isHidden = true
                self.createScheduleEventButton.isHidden = true
                self.createScheduleEventLabel.isHidden = true
            }
        })
    }
    
    @objc
    func showCreateEvent(_ sender: Any) {
        if let sender = sender as? UILongPressGestureRecognizer {
            guard sender.state == .began else { return }
        } else {
            showCreateOptions()
        }
        
        guard let vm = coordinator?.vm,
              let schedule = coordinator?.vm.selectedSchedule else { return }
        
        let hostingController = UIHostingController(rootView: CreateEventView(currentUser: vm.currentUser, currentScheduleId: schedule.id))
        
        navigationController?.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(hostingController, animated: true)
            
//        coordinator?.router.push(page: .createEvent(currentUser: vm.currentUser, scheduleId: schedule.id))
    }
    
    @objc func showCreateBlend() {
        guard let vm = coordinator?.vm,
              let schedule = coordinator?.vm.selectedSchedule else { return }
        
//        coordinator?.router.push(page: .createEvent(currentUser: vm.currentUser, scheduleId: schedule.id))
        
        showCreateOptions()
    }
    
    @objc func showCreateSchedule() {
        guard let vm = coordinator?.vm,
              let schedule = coordinator?.vm.selectedSchedule else { return }
        
//        coordinator?.router.push(page: .createEvent(currentUser: vm.currentUser, scheduleId: schedule.id))
        
        showCreateOptions()
    }
    
//    enum LoadingState {
//        case idle
//        case loadingPrevious
//        case loadingNext
//    }
//
//    var state: LoadingState = .idle
    
//    private func loadPreviousDateInterval() {
//        guard state == .idle else { return }
//        state = .loadingPrevious
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
//        let totalItems = dayList.count * numberOfTimeIntervals
//        let itemsToDelete = datesToAdd * numberOfTimeIntervals
//        
//        let indexPathsToDelete = (totalItems-itemsToDelete..<totalItems).map { IndexPath(row: $0, section: 0) }
//        let indexPathsToAdd = (0..<itemsToDelete).map { IndexPath(row: $0, section: 0) }
//        
//        UIView.performWithoutAnimation {
//            collectionView.performBatchUpdates({
//                // Update the data source with new days
//                dayList.removeLast(datesToAdd)
//                dayList.insert(contentsOf: newDays.reversed(), at: 0)
//                
//                currentDate = dayList[dayList.count/2]
//                
//                collectionView.deleteItems(at: indexPathsToDelete)
//                collectionView.insertItems(at: indexPathsToAdd)
//            }, completion: { [weak self] _ in
//                guard let self = self else { return }
//                self.state = .idle
//            })
//            
//            collectionView.setContentOffset(newOffset, animated: false)
//            dayHeader.addPreviousDates(updatedDayList: newDays)
//            updateEventsOverlay()
//        }
//    }
//    
//    private func loadNextDateInterval() {
//        guard state == .idle else { return }
//        state = .loadingNext
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
//        let totalItems = dayList.count * numberOfTimeIntervals
//        let itemsToDelete = datesToAdd * numberOfTimeIntervals
//        
//        let indexPathsToDelete = (0..<itemsToDelete).map { IndexPath(row: $0, section: 0) }
//        let indexPathsToAdd = ((totalItems-itemsToDelete)..<totalItems).map { IndexPath(row: $0, section: 0) }
//        
//        UIView.performWithoutAnimation {
//            collectionView.performBatchUpdates({
//                // Update the data source with new days
//                dayList.removeFirst(datesToAdd)
//                dayList.append(contentsOf: newDays)
//                
//                currentDate = dayList[dayList.count/2]
//                
//                collectionView.deleteItems(at: indexPathsToDelete)
//                collectionView.insertItems(at: indexPathsToAdd)
//            }, completion: { [weak self] _ in
//                guard let self = self else { return }
//                self.state = .idle
//            })
//            
//            collectionView.setContentOffset(newOffset, animated: false)
//            dayHeader.addNextDates(updatedDayList: newDays)
//            updateEventsOverlay()
//        }
//    }
    
    var modifiedCells = Set<UICollectionViewCell>()
    
    deinit {
        modifiedCells.removeAll()
        cancellables.removeAll()
    }
}

extension WeekViewController: UICollectionViewDelegate, InnerCellScrollDelegate {
    
    
    
    // MARK: - InnerCellScrollDelegate
    
    func innerCellDidScroll(to offset: CGPoint, from originatorCell: UICollectionViewCell) {
        
        // 2. Update the stored offset.
        currentYOffset = offset.y
        
        for cell in collectionView.visibleCells {
            // Make sure we don't update the cell that started the scroll event.
            // This prevents a jittery infinite loop.
            guard cell != originatorCell else { continue }
            if let customCell = cell as? DayColumnView {
                customCell.collectionView.setContentOffset(offset, animated: false)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Prevent recursive scroll handling
//        guard !isHandlingScroll, scrollView === collectionView else { return }
//        
//        isHandlingScroll = true
//        
//        if !isExpanded {
//            showCreateOptions()
//        }
//        
//        handleBoundaryCellStretching(scrollView)
//        
//        isHandlingScroll = false
    }
    
    private func handleBoundaryCellStretching(_ scrollView: UIScrollView) {
        
        // Calculate the maximum scroll position (without adding tolerance yet)
        
        
       
    }

    func resetModifiedCells() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            for cell in self.modifiedCells {
                if let indexPath = self.collectionView.indexPath(for: cell) {
                    // Force layout update for specific cells
                    print(indexPath)
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
            self.modifiedCells.removeAll()
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        positionScroll = scrollView.contentOffset
        hideCreateEventButton(createEventButton)
                
        if !hasUserScrolled {
            hasUserScrolled = true
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        showCreateEventButton(createEventButton)
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

//extension WeekViewController: UICollectionViewDataSourcePrefetching {
//    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//        // calculate the total number of items in the collection view
//        let totalItems = dayList.count * numberOfTimeIntervals
//        
//        //
//        let endIndex = indexPaths.max(by: { $0.item < $1.item })?.item
//        let startIndex = indexPaths.min(by: { $0.item < $1.item })?.item
//        
//        let daysBeforeThreshold = 7
//        let threshold = numberOfTimeIntervals * daysBeforeThreshold
//        
//        if endIndex ?? totalItems >= (totalItems - threshold) {
//            loadNextDateInterval()
//        } else if startIndex ?? 0 <= threshold {
//            loadPreviousDateInterval()
//        }
//    }
//}

extension WeekViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DayColumnView.identifier, for: indexPath) as! DayColumnView
        
        cell.scrollDelegate = self
        cell.eventDetailsDelegate = self
        cell.coordinator = self.coordinator
        
        let section = indexPath.section
        let date = dates[section]
        
        let events = MockEventFactory.createEvents(1, for: date, with: "1")
        
        cell.configure(with: date, for: events)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case WeekdayCellView.identifier:
            let supplementaryItem = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: WeekdayCellView.identifier, for: indexPath) as! WeekdayCellView
                        
            let date = dates[indexPath.section]
            supplementaryItem.configure(with: date)
            
            return supplementaryItem
//        case TimeColumnView.identifier:
//            let supplementaryItem = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TimeColumnView.identifier, for: indexPath) as! TimeColumnView
//            
//            return supplementaryItem
        default:
            fatalError("Unhandled supplementary view kind: \(kind)")
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Safely cast to your custom cell class
        guard let dayColumnCell = cell as? DayColumnView else { return }
        
        // Set the content offset here.
        let syncedOffset = CGPoint(x: .zero, y: currentYOffset)
        dayColumnCell.collectionView.setContentOffset(syncedOffset, animated: false)
    }
}

extension WeekViewController: WeekCalendarViewDelegate {
    func showEventDetails(for event: EventOccurrence, and user: User, from view: UIView) {
        let hostingController = UIHostingController(rootView: FullEventDetailsView(event: event, currentUser: user))
        
        hostingController.preferredTransition = .zoom(sourceViewProvider: { context in
            // Use the context instead of capturing to avoid needing to make a weak reference.
//            let monthViewController = context.zoomedViewController as! MonthViewController
            // Fetch this instead of capturing in case the item shown by the destination view can change while the destination view is visible.
//            let item = monthViewController.item
//            // Look up the index path in case the items in the collection view can change.
//            guard let indexPath = self.dataSource.indexPath(for: item) else {
//                return nil
//            }
            // Always fetch the cell again because even if the data never changes, cell reuse might occur. E.g if the device rotates.
            return view
        })
                
//        navigationController?.tabBarController?.bottomAccessory
        navigationController?.pushViewController(hostingController, animated: true)
    }
}

class BorderedCellView: UIView {
    
    let topBorderHeight: CGFloat = 1.0
    let sideBorderWidth: CGFloat = 0.5
    let borderColor = UIColor.primaryText

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(Color("BackgroundColor"))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect) // Draws the background color
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setStrokeColor(borderColor.cgColor)
        context.setLineWidth(sideBorderWidth)
        
        // Draw Left Border
        context.move(to: CGPoint(x: 0, y: 0))
        context.addLine(to: CGPoint(x: 0, y: bounds.height))
        context.strokePath()
        
        // Draw Right Border
        context.move(to: CGPoint(x: bounds.width, y: 0))
        context.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        context.strokePath()
        
        // Draw Top Border (with its own width)
        context.setLineWidth(topBorderHeight)
        context.move(to: CGPoint(x: 0, y: 0))
        context.addLine(to: CGPoint(x: bounds.width, y: 0))
        context.strokePath()
    }
}

class DayColumnView: UICollectionViewCell {
    static let identifier = "DayColumnView"
    
    weak var scrollDelegate: InnerCellScrollDelegate?
    weak var eventDetailsDelegate: WeekCalendarViewDelegate?
    
    var coordinator: CalendarYearView.Coordinator?
    
    var collectionView: UICollectionView!
    var date: Date?
    var events: [Event] = []
    
    private lazy var borderedView: BorderedCellView = {
        let view = BorderedCellView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(HourCellView.self, forCellWithReuseIdentifier: HourCellView.identifier)
        for i in 0..<50 {
            collectionView.register(
                EventView.self,
                forSupplementaryViewOfKind: "\(EventView.identifier)-\(i)",
                withReuseIdentifier: EventView.identifier
            )
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(2400))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            var supplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem] = []
            
            for (index, event) in self.events.enumerated() {
                // Calculate the frame based on the event's start and end times
                let yPosition = self.pointFor(time: event.startTime)
                let height = self.pointFor(time: event.endTime) - yPosition
                
                let uniqueElementKind = "\(EventView.identifier)-\(index)"
                
                let eventSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height))
                
                // Use an anchor to position the item absolutely
                let eventAnchor = NSCollectionLayoutAnchor(edges: [.top], absoluteOffset: CGPoint(x: 0, y: yPosition))
                let eventSupplementaryItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: eventSize, elementKind: uniqueElementKind, containerAnchor: eventAnchor)
                
                supplementaryItems.append(eventSupplementaryItem)
            }
            
            section.boundarySupplementaryItems = supplementaryItems
            
            return section
        }
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.decelerationRate = .fast
        
//        collectionView.bouncesVertically = false
        
        contentView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // Add this helper method to DayColumnView
    private func pointFor(time: Int) -> CGFloat {
        let height: CGFloat = (Double(time) / 60.0)
        
        // Convert time to a point value (100 points per hour)
        return height * 100
    }
    
    func configure(with date: Date, for events: [Event]) {
        self.date = date
        self.events = events
        collectionView.reloadData()
    }
}

extension DayColumnView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        24
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourCellView.identifier, for: indexPath) as! HourCellView
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        // Check if the kind is one of our unique event kinds
        if kind.hasPrefix(EventView.identifier) {
            let eventView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: EventView.identifier, for: indexPath) as! EventView
            
            eventView.coordinator = self.coordinator
            eventView.eventDetailsDelegate = eventDetailsDelegate
            
            // The indexPath.item still correctly corresponds to the index in the events array
            let event = events[indexPath.item]
            eventView.configure(with: event)
            
            return eventView
        }
        
        // Handle other kinds of supplementary views if you have them
        fatalError("Unhandled supplementary view kind: \(kind)")
    }
}

extension DayColumnView: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Only broadcast the scroll offset change if the user's
        // finger is actively touching and dragging the screen.
        if scrollView.isDragging {
            scrollDelegate?.innerCellDidScroll(to: scrollView.contentOffset, from: self)
        }
                
        // 3. Iterate over all *other* visible cells and update their offset.

        //
        //            let maxScrollY = collectionView.contentSize.height - collectionView.bounds.height
        //
        //            // Check for boundary conditions with proper tolerance
        //            let isAtTopBoundary = collectionView.contentOffset.y < 0
        //            let isAtBottomBoundary = maxScrollY > 0 && collectionView.contentOffset.y > maxScrollY + 5
        //
        //            if !isAtTopBoundary && !isAtBottomBoundary {
        //                resetModifiedCells()
        //                return
        //            }
        //
        //            if isAtTopBoundary || isAtBottomBoundary {
        //                // Calculate actual offsets
        //                let topOffset = isAtTopBoundary ? -collectionView.contentOffset.y : 0
        //                let bottomOffset = isAtBottomBoundary ? collectionView.contentOffset.y - maxScrollY : 0
        //
        //                let visibleCells = collectionView.indexPathsForVisibleItems
        //
        //                // Handle top cells stretching
        //                //                for indexPath in visibleCells {
        //                //                    if let cell = collectionView.cellForItem(at: indexPath) {
        //                if !modifiedCells.contains(cell) {
        //                    cell.layer.setValue(cell.frame.origin.y, forKey: "normal")
        //                    cell.layer.setValue(cell.frame.size.height, forKey: "normalHeight")
        //                    modifiedCells.insert(cell)
        //                }
        //
        //                let itemHeight = CGFloat(100 * 24)
        //
        //                var frame = cell.frame
        //
        //                if topOffset < 0 {
        //                    frame.origin.y = (cell.layer.value(forKey: "normal") as? CGFloat ?? frame.origin.y) - topOffset
        //                    frame.size.height = (cell.layer.value(forKey: "normalHeight") as? CGFloat ?? itemHeight) + topOffset
        //                } else if bottomOffset > 0 {
        //                    frame.origin.y = (cell.layer.value(forKey: "normal") as? CGFloat ?? frame.origin.y)
        //                    frame.size.height = (cell.layer.value(forKey: "normalHeight") as? CGFloat ?? itemHeight) + bottomOffset
        //                }
        //
        //                cell.frame = frame
        //                //                    }
        //                //                }
        //            }32
    }
}

class EventView: UICollectionReusableView {
    static let identifier = "EventView"
    
    var coordinator: CalendarYearView.Coordinator?
    weak var eventDetailsDelegate: WeekCalendarViewDelegate?
    
    private let titleLabel = UILabel()
    
    var event: Event?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBlue
        layer.cornerRadius = 8
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showEventDetails))
        addGestureRecognizer(tapGesture)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with event: Event) {
        self.event = event
        titleLabel.text = event.title
    }
    
    @objc
    private func showEventDetails() {
        guard let event = event, let vm = coordinator?.vm else { return }
        
        let eventOccurence = EventOccurrence(recurringDate: event.startDate, event: event)
        
        eventDetailsDelegate?.showEventDetails(for: eventOccurence, and: vm.currentUser, from: self)
                
//        coordinator?.router.push(page: .eventDetails(currentUser: vm.currentUser, event: EventOccurrence(recurringDate: event.startDate, event: event)))
    }
}

class HourCellView: UICollectionViewCell {
    
    static let identifier = "HourCellView"
        
    private lazy var borderedView: BorderedCellView = {
        let view = BorderedCellView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
        contentView.addSubview(borderedView)
        
        NSLayoutConstraint.activate([
            borderedView.topAnchor.constraint(equalTo: contentView.topAnchor),
            borderedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            borderedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            borderedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

class WeekHeaderView: UICollectionReusableView {
    
    static let identifier = "WeekHeaderView"
    
    var collectionView: UICollectionView!
    var dates: [Date] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        
        collectionView.register(WeekdayCellView.self, forCellWithReuseIdentifier: WeekdayCellView.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, environmnet) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(60), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            return section
        }, configuration: configuration)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func configure(with dates: [Date]) {
        self.dates = dates
        collectionView.reloadData()
    }
}

extension WeekHeaderView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeekdayCellView.identifier, for: indexPath) as! WeekdayCellView
        
        let index = indexPath.row
        let date = dates[index]
        
        cell.configure(with: date)
        
        return cell
    }
}

extension WeekHeaderView: UICollectionViewDelegate {
    
}

class WeekdayCellView: UICollectionViewCell {
    
    static let identifier = "WeekdayCellView"
    
    let borderedView: DayBorderedCellView = {
        let view = DayBorderedCellView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let weekdayLabel = UILabel()
    let dayLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        weekdayLabel.textColor = .label
        weekdayLabel.translatesAutoresizingMaskIntoConstraints = false
        weekdayLabel.font = UIFont.monospacedSystemFont(ofSize: 13, weight: .semibold)
                
        dayLabel.textColor = .secondaryLabel
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .heavy)
        
        borderedView.addSubview(weekdayLabel)
        borderedView.addSubview(dayLabel)
        
        contentView.addSubview(borderedView)
        
        NSLayoutConstraint.activate([
            borderedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            borderedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            borderedView.topAnchor.constraint(equalTo: contentView.topAnchor),
            borderedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            weekdayLabel.leadingAnchor.constraint(equalTo: borderedView.leadingAnchor, constant: 10),
            weekdayLabel.trailingAnchor.constraint(equalTo: borderedView.trailingAnchor),
            weekdayLabel.topAnchor.constraint(equalTo: borderedView.topAnchor, constant: 10),
            
            dayLabel.topAnchor.constraint(equalTo: weekdayLabel.bottomAnchor, constant: 2),
            dayLabel.leadingAnchor.constraint(equalTo: borderedView.leadingAnchor, constant: 10),
        ])
    }
    
    func configure(with date: Date) {
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .weekday], from: date)
        guard let day = dateComponents.day, let weekday = dateComponents.weekday else { return }
        
        weekdayLabel.text = Calendar.current.shortWeekdaySymbols[weekday - 1]
                
        dayLabel.text = "\(day)"
    }
}

class TimeColumnView: UICollectionReusableView {
    
    static let identifier = "TimeColumnView"
    
    let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.borderColor = UIColor.clear.cgColor
        stackView.backgroundColor = UIColor(Color("BackgroundColor"))
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Create time labels for each hour
        setupTimeLabels()
    }
    
    private func setupTimeLabels() {
        // Remove any existing labels
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let hoursList = [
            "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM", "10 AM", "11 AM", "12 PM",
            "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM", ""
        ]
        
        // Add a label for each hour (0-23)
        for hour in hoursList {
            let label = TimeLabel()
            label.text = hour
            stackView.addArrangedSubview(label)
        }
    }
    
}

