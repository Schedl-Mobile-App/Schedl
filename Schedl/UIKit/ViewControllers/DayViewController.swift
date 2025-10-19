//
//  DayViewController.swift
//  Schedl
//
//  Created by David Medina on 10/6/25.
//

import UIKit
import SwiftUI
import Foundation
import Combine

struct WeekCalendarPreviewViewRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = WeekViewController(centerDay: Date())
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        TabView {
            Tab("Schedule", systemImage: "calendar") {
                NavigationStack {
                    WeekCalendarPreviewViewRepresentable()
                        .ignoresSafeArea(edges: [.bottom, .top])
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            ToolbarItem(placement: .topBarTrailing) {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                        }
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory(content: {
            Button(action: {
                
            }, label: {
                Text("David's Schedule")
                    .fontWeight(.semibold)
                    .font(.headline)
            })
        })
    }
}

class DayBorderedCellView: UIView {
    
    // We will draw these borders ourselves
    let bottomBorderWidth: CGFloat = 1.5
    let sideBorderWidth: CGFloat = 0.75
    let borderColor = UIColor.separator

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Set the background color here
        backgroundColor = UIColor(Color("BackgroundColor"))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // This is where the magic happens!
    override func draw(_ rect: CGRect) {
        super.draw(rect) // Draws the background color
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setStrokeColor(borderColor.cgColor)
        context.setLineWidth(sideBorderWidth)
        
        // Draw Left Border
        context.move(to: CGPoint(x: 0, y: 10))
        context.addLine(to: CGPoint(x: 0, y: bounds.height))
        context.strokePath()
        
        // Draw Right Border
        context.move(to: CGPoint(x: bounds.width, y: 10))
        context.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        context.strokePath()
        
        // Draw Bottom Border
        context.setLineWidth(bottomBorderWidth)
        context.move(to: CGPoint(x: 0, y: bounds.height))
        context.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        context.strokePath()
        
        
    }
}

class CollectionViewDaysHeader: UIView {
    
    static let identifier = "DayHeader"
    
    var currentDate = Date()
    
    let weekList: [Int: String] = [
        1 : "Sun",
        2 : "Mon",
        3 : "Tue",
        4 : "Wed",
        5 : "Thu",
        6 : "Fri",
        7 : "Sat"
    ]
    
    // using a stack view since all time cells will be vertically stacked on top of one another
    let stackView = UIStackView()
    let dayLabelContainer = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        // Setup stackView (your existing code)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 5
        stackView.backgroundColor = UIColor(Color("BackgroundColor"))
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func createDayLabel(dateComponent: Date) -> UIView {
        let dayComponent = Calendar.current.dateComponents([.day], from: dateComponent)
        let actualDateComponent = Calendar.current.dateComponents([.weekday], from: dateComponent)
        
        let borderedView: DayBorderedCellView = {
            let view = DayBorderedCellView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        let dateContainer = UIStackView()
        dateContainer.axis = .vertical
        dateContainer.distribution = .fillEqually
        dateContainer.alignment = .leading
        dateContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let dateLabel = UILabel()
        if Calendar.current.startOfDay(for: Date.now) == dateComponent {
            dateLabel.textColor = .red
        } else {
            dateLabel.textColor = .secondaryLabel
        }
        dateLabel.text = "\(weekList[actualDateComponent.weekday ?? 0] ?? "")"
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.monospacedSystemFont(ofSize: 13, weight: .semibold)
        dateLabel.tag = 2
        
        dateContainer.addArrangedSubview(dateLabel)
        
        let dayLabel = UILabel()
        dayLabel.text = "\(dayComponent.day ?? 0)"
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .bold)
        dayLabel.tag = 1
        
        if Calendar.current.startOfDay(for: Date.now) == dateComponent {
            dayLabel.textColor = .red
        } else {
            dayLabel.textColor = .label
        }
        
        dateContainer.addArrangedSubview(dayLabel)
        
        borderedView.addSubview(dateContainer)
        borderedView.bringSubviewToFront(dateContainer)

        NSLayoutConstraint.activate([
            dateContainer.topAnchor.constraint(equalTo: borderedView.topAnchor, constant: 10),
            dateContainer.bottomAnchor.constraint(equalTo: borderedView.bottomAnchor),
            dateContainer.leadingAnchor.constraint(equalTo: borderedView.leadingAnchor, constant: 10),
            dateContainer.trailingAnchor.constraint(equalTo: borderedView.trailingAnchor),
            
            borderedView.heightAnchor.constraint(equalToConstant: 50),
            borderedView.widthAnchor.constraint(equalToConstant: 60)
        ])
        
        return borderedView
    }
    
    func updateDayLabel(view: UIView, date: Date) {
        guard let dayLabel = view.viewWithTag(1) as? UILabel,
              let dateLabel = view.viewWithTag(2) as? UILabel else { return }
        
        let dayComponent = Calendar.current.dateComponents([.day], from: date)
        let actualDateComponent = Calendar.current.dateComponents([.weekday], from: date)
        
        dayLabel.text = "\(dayComponent.day ?? 0)"
        dateLabel.text = "\(weekList[actualDateComponent.weekday ?? 0] ?? "")"
    }
    
    func addNextDates(updatedDayList: [Date]) {
        for newDate in updatedDayList {
            // 1. Get the first view to recycle
            guard let viewToRecycle = stackView.arrangedSubviews.first else { continue }
            
            // 2. Remove it from the beginning of the stack
            stackView.removeArrangedSubview(viewToRecycle)
            
            // 3. Update its content with the new date ✨
            updateDayLabel(view: viewToRecycle, date: newDate)
            
            // 4. Add the recycled view to the end of the stack
            stackView.addArrangedSubview(viewToRecycle)
        }
    }

    func addPreviousDates(updatedDayList: [Date]) {
        for newDate in updatedDayList {
            // 1. Get the last view to recycle
            guard let viewToRecycle = stackView.arrangedSubviews.last else { continue }
            
            // 2. Remove it from the end of the stack
            stackView.removeArrangedSubview(viewToRecycle)
            
            // 3. Update its content with the new date ✨
            updateDayLabel(view: viewToRecycle, date: newDate)
            
            // 4. Insert the recycled view at the beginning of the stack
            stackView.insertArrangedSubview(viewToRecycle, at: 0)
        }
    }
    
    func setDates(dayList: [Date]) {
        
        // remove any existing labels from the stack view
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
                
        for index in dayList.indices {
            let containerView = createDayLabel(dateComponent: dayList[index])
            stackView.addArrangedSubview(containerView)
        }
    }
}

class InsetLabel: UILabel {

    var contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: -87, right: 0)

    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: contentInsets)
        super.drawText(in: insetRect)
    }

    override var intrinsicContentSize: CGSize {
        return addInsets(to: super.intrinsicContentSize)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return addInsets(to: super.sizeThatFits(size))
    }

    func addInsets(to size: CGSize) -> CGSize {
        let width = size.width + contentInsets.left + contentInsets.right
        let height = size.height + contentInsets.top + contentInsets.bottom
        return CGSize(width: width, height: height)
    }

}

class TimeLabel: UIView {
    private let label: UILabel = {
        let label = InsetLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 12),
        ])
    }
    
    var text: String? {
        get { label.text }
        set { label.text = newValue }
    }
}

class CollectionViewTimesColumn: UIView {
    
    static let identifier = "TimeColumn"
    
    // using a stack view since all time cells will be vertically stacked on top of one another
    let stackView = UIStackView()
    
    // we've defined the frame dimensions in our view controller
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    // necessary initializer for class of type UICollectionReusableView
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
            stackView.axis = .vertical
            // ✨ CHANGE 1: Allow individual view heights instead of forcing them to be equal.
            stackView.distribution = .fill
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.backgroundColor = UIColor(Color("BackgroundColor"))
            addSubview(stackView)
            
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
            
            setupTimeLabels()
        }
        
        private func setupTimeLabels() {
            stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            // This should match the height of your collection view cells (e.g., 100)
            let hourViewHeight: CGFloat = 100.0
            
            let hoursList = [
                "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM", "10 AM", "11 AM", "12 PM",
                "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM", ""
            ]
            
            for hour in hoursList {
                let label = TimeLabel()
                label.text = hour
                
                // ✨ CHANGE 2: Give each label an explicit height.
                // This is where you take control.
                label.heightAnchor.constraint(equalToConstant: hourViewHeight).isActive = true
                
                stackView.addArrangedSubview(label)
            }
        }
}

class WeekViewController: UIViewController, VCCoordinatorProtocol {
    
    var coordinator: CalendarYearView.Coordinator?
    
    var centerDay: Date
    
    lazy var visibleDate: Date = centerDay {
        didSet {
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: visibleDate)
            let monthIndex = dateComponents.month
            let year = dateComponents.year
            
            let monthName = Calendar.current.monthSymbols[monthIndex! - 1]
            
            dateLabel.text = "\(monthName) \(year!)"
        }
    }
    
    private var currentYOffset: CGFloat = 0.0
    
    lazy var displayedYear = Calendar.current.component(.year, from: centerDay)
    lazy var displayedMonth = Calendar.current.monthSymbols[Calendar.current.component(.month, from: centerDay) - 1]
    
    lazy var dates: [Date] = {
        let numberOfDays = 180
        return (-numberOfDays...numberOfDays).map { index in
            Calendar.current.date(byAdding: .day, value: index, to: centerDay)!
        }
    }()
    
    let calendarTypeButton = UIButton()
    var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search Events"
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()
    
    var dateLabel: UILabel!
    
    var collectionView: UICollectionView!
    
    var dayHeaderScrollView: UIScrollView!
    var dayHeaderStackView: CollectionViewDaysHeader!
    
    var timeColumnScrollView: UIScrollView!
    var timeColumnStackView: CollectionViewTimesColumn!
    
    var createEventButtonWidthConstraint: NSLayoutConstraint?
    var createEventButtonHeightConstraint: NSLayoutConstraint?
    
    let buttonColors: ButtonColors = [ButtonColors.palette1, ButtonColors.palette2, ButtonColors.palette3, ButtonColors.palette4].randomElement()!
        
    var isExpanded = true
    
    let createEventButton = UIButton()
    
    let createBlendButton = UIButton()
    let createBlendLabel = UILabel()
    
    let createScheduleEventButton = UIButton()
    let createScheduleEventLabel = UILabel()
    
    let createScheduleButton = UIButton()
    let createScheduleLabel = UILabel()
    
    private var isHandlingScroll = false
    private var previousContentOffsetX: CGFloat = 0
    private var previousContentOffsetY: CGFloat = 0
    
    private var hasScrolledToInitialPosition = false
    
    private var hasCalculatedInitialPosition = false
    private var topInset: CGFloat = 0
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(centerDay: Date) {
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: centerDay)
        let date = Calendar.current.date(from: dateComponents)!
        self.centerDay = date
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.tabBarController?.setTabBarHidden(false, animated: true)
        
        Task {
            await coordinator?.vm.fetchSchedule()
        }
        
        observePublishers()
        
        setupUI()
        
        collectionView.register(HourCellView.self, forCellWithReuseIdentifier: HourCellView.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Only perform this scroll the very first time the layout is set
        if !hasScrolledToInitialPosition {
            scrollToCurrentDay(false)
            hasScrolledToInitialPosition = true
            
//            centerDatePosition = collectionView.contentOffset.y
        }
    }
    
    private func scrollToCurrentDay(_ animated: Bool) {
        // the section index for the current year is in the middle
        let daySection = dates.count / 2
        
        let normalizedDate = Calendar.current.startOfDay(for: Date())
        let seconds = Date().timeIntervalSince(normalizedDate)
        
        let rowIndex = Int(seconds / 3600)
        
        // scroll to the current day
        collectionView.scrollToItem(at: IndexPath(row: rowIndex, section: daySection), at: .left, animated: animated)
        
        // scroll to the current time
        collectionView.scrollToItem(at: IndexPath(row: rowIndex, section: daySection), at: .top, animated: animated)
    }
    
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
        
        dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: visibleDate)
        let monthIndex = dateComponents.month
        let year = dateComponents.year
        
        let monthName = Calendar.current.monthSymbols[monthIndex! - 1]
        
        // 1. Get the standard font for the .largeTitle style.
        let baseFont = UIFont.preferredFont(forTextStyle: .largeTitle)

        // 2. Create a bold version of the font's descriptor.
        guard let boldDescriptor = baseFont.fontDescriptor.withSymbolicTraits(.traitBold) else {
            fatalError("Could not create a bold font descriptor.")
        }

        // 3. Create the final bold font. Using size 0 preserves the Dynamic Type size.
        let boldLargeTitleFont = UIFont(descriptor: boldDescriptor, size: 0)

        // 4. Apply the new font to your attributes dictionary.
        let attributes: [NSAttributedString.Key: Any] = [
            .font: boldLargeTitleFont,
        ]
        dateLabel.attributedText = NSAttributedString(string: "\(monthName) \(year!)", attributes: attributes)
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        
        let itemWidth: CGFloat = 60
        let itemHeight: CGFloat = 100
                
        let numberOfTimeIntervals: CGFloat = 24
        
        let groupWidth = itemWidth
        let groupHeight = numberOfTimeIntervals * itemHeight
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { [weak self] (sectionIndex, environment) -> NSCollectionLayoutSection in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .absolute(itemHeight))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(groupWidth), heightDimension: .absolute(groupHeight))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            guard let self = self else { return section }
            
            let date = self.dates[sectionIndex]
            
            guard let vm = self.coordinator?.vm, let events = vm.events[date] else { return section }
            
            var supplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem] = []
            
            for (index, event) in events.enumerated() {
                // Calculate the frame based on the event's start and end times
                let yPosition = self.pointFor(time: event.event.startTime)
                let height = self.pointFor(time: event.event.endTime) - yPosition
                
                let uniqueElementKind = "\(EventView.identifier)-\(index)"
                
                let eventSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth-2), heightDimension: .absolute(height))
                
                // Use an anchor to position the item absolutely
                let eventAnchor = NSCollectionLayoutAnchor(edges: [.top], absoluteOffset: CGPoint(x: 0, y: yPosition))
                let eventSupplementaryItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: eventSize, elementKind: uniqueElementKind, containerAnchor: eventAnchor)
                
                supplementaryItems.append(eventSupplementaryItem)
            }
            
            section.boundarySupplementaryItems = supplementaryItems
            
            return section
        }, configuration: configuration)
                
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = true
        collectionView.decelerationRate = .fast
        collectionView.isDirectionalLockEnabled = true
        
        for i in 0..<(dates.count * 20) {
            collectionView.register(
                EventView.self,
                forSupplementaryViewOfKind: "\(EventView.identifier)-\(i)",
                withReuseIdentifier: EventView.identifier
            )
        }
        
        dayHeaderScrollView = UIScrollView()
        dayHeaderScrollView.isUserInteractionEnabled = false
        dayHeaderScrollView.decelerationRate = .fast
        dayHeaderScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        dayHeaderStackView = CollectionViewDaysHeader()
        dayHeaderStackView.setDates(dayList: dates)
        dayHeaderStackView.translatesAutoresizingMaskIntoConstraints = false
        
        dayHeaderScrollView.addSubview(dayHeaderStackView)

        timeColumnScrollView = UIScrollView()
        timeColumnScrollView.isUserInteractionEnabled = false
        timeColumnScrollView.decelerationRate = .fast
        timeColumnScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        timeColumnStackView = CollectionViewTimesColumn()
        timeColumnStackView.translatesAutoresizingMaskIntoConstraints = false
        
        timeColumnScrollView.addSubview(timeColumnStackView)
        
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
        createBlendLabel.textColor = .label
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
        createScheduleLabel.textColor = .label
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
        createScheduleEventLabel.textColor = .label
        createScheduleEventLabel.isHidden = true
        createScheduleEventLabel.alpha = 0
        
        view.addSubview(collectionView)
        view.addSubview(dateLabel)
        view.addSubview(timeColumnScrollView)
        view.addSubview(dayHeaderScrollView)
        
        view.addSubview(createEventButton)
        view.addSubview(createBlendButton)
        view.addSubview(createBlendLabel)
        view.addSubview(createScheduleButton)
        view.addSubview(createScheduleLabel)
        view.addSubview(createScheduleEventButton)
        view.addSubview(createScheduleEventLabel)
        
        let widthConstraint = createEventButton.widthAnchor.constraint(equalToConstant: 60)
        let heightConstraint = createEventButton.heightAnchor.constraint(equalToConstant: 60)
        createEventButtonWidthConstraint = widthConstraint
        createEventButtonHeightConstraint = heightConstraint
        
        NSLayoutConstraint.activate([
            
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            dayHeaderScrollView.leadingAnchor.constraint(equalTo: timeColumnScrollView.trailingAnchor),
            dayHeaderScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dayHeaderScrollView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor),
            dayHeaderScrollView.heightAnchor.constraint(equalToConstant: 50),
            
            timeColumnScrollView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 50),
            timeColumnScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timeColumnScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            timeColumnScrollView.widthAnchor.constraint(equalToConstant: 50),
            
            collectionView.leadingAnchor.constraint(equalTo: timeColumnScrollView.trailingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: dayHeaderScrollView.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            createEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createEventButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            widthConstraint,
            heightConstraint,
            
            // Center createBlendButton on the main button
            createBlendButton.centerXAnchor.constraint(equalTo: createEventButton.centerXAnchor),
            createBlendButton.centerYAnchor.constraint(equalTo: createEventButton.centerYAnchor),
            createBlendButton.widthAnchor.constraint(equalToConstant: 50),
            createBlendButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Position its label
            createBlendLabel.topAnchor.constraint(equalTo: createBlendButton.bottomAnchor, constant: 2),
            createBlendLabel.centerXAnchor.constraint(equalTo: createBlendButton.centerXAnchor),
            
            // Center createScheduleButton on the main button
            createScheduleButton.centerXAnchor.constraint(equalTo: createEventButton.centerXAnchor),
            createScheduleButton.centerYAnchor.constraint(equalTo: createEventButton.centerYAnchor),
            createScheduleButton.widthAnchor.constraint(equalToConstant: 50),
            createScheduleButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Position its label
            createScheduleLabel.topAnchor.constraint(equalTo: createScheduleButton.bottomAnchor, constant: 2),
            createScheduleLabel.centerXAnchor.constraint(equalTo: createScheduleButton.centerXAnchor),
            
            // Center createScheduleEventButton on the main button
            createScheduleEventButton.centerXAnchor.constraint(equalTo: createEventButton.centerXAnchor),
            createScheduleEventButton.centerYAnchor.constraint(equalTo: createEventButton.centerYAnchor),
            createScheduleEventButton.widthAnchor.constraint(equalToConstant: 50),
            createScheduleEventButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Position its label
            createScheduleEventLabel.topAnchor.constraint(equalTo: createScheduleEventButton.bottomAnchor, constant: 2),
            createScheduleEventLabel.centerXAnchor.constraint(equalTo: createScheduleEventButton.centerXAnchor),
        ])
    }
    
    private func observePublishers() {
        coordinator?.vm.$events
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func pointFor(time: Int) -> CGFloat {
        let height: CGFloat = (Double(time) / 60.0)
        
        // Convert time to a point value (100 points per hour)
        return height * 100
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
        
        hostingController.preferredTransition = .flipHorizontal
        
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
    
    var modifiedCells = Set<UICollectionViewCell>()
    
    deinit {
        modifiedCells.removeAll()
//        cancellables.removeAll()
    }
}

extension WeekViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dates.count
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
            eventView.eventDetailsDelegate = self
            
            let date = self.dates[indexPath.section]
            let events = self.coordinator?.vm.events[date] ?? []
                        
            // The indexPath.item still correctly corresponds to the index in the events array
            let event = events[indexPath.item]
            eventView.configure(with: event)
            
            return eventView
        }
        
        // Handle other kinds of supplementary views if you have them
        fatalError("Unhandled supplementary view kind: \(kind)")
    }
}

extension WeekViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Prevent recursive scroll handling
        guard !isHandlingScroll, scrollView == collectionView else { return }
        
        isHandlingScroll = true
        
        let visibleCells = collectionView.indexPathsForVisibleItems
        let firstVisibleCellPath = visibleCells.first
        
        if let firstVisibleCellPath {
            let date = self.dates[firstVisibleCellPath.section]
            
            if self.visibleDate != date {
                self.visibleDate = date
            }
        }
        
//        // The user wants to scroll on the X axis
//        if scrollView.contentOffset.x > positionScroll.x || scrollView.contentOffset.x < positionScroll.x {
//            // Reset the Y position of the scrollView to what it was before scrolling started
//            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: positionScroll.y)
//        } else {
//            // The user wants to scroll on the Y axis
//            // Reset the X position of the scrollView to what it was before scrolling started
//            scrollView.contentOffset = CGPoint(x: positionScroll.x, y: scrollView.contentOffset.y)
//        }
        
        // Sync horizontal scrolling for day header
        if scrollView.contentOffset.x != previousContentOffsetX {
            dayHeaderScrollView.contentOffset.x = scrollView.contentOffset.x
            previousContentOffsetX = scrollView.contentOffset.x
        }

        // Sync vertical scrolling for time column
        if scrollView.contentOffset.y != previousContentOffsetY {
            timeColumnScrollView.contentOffset.y = scrollView.contentOffset.y
            previousContentOffsetY = scrollView.contentOffset.y
        }
        
        // Handle stretching cells at boundaries
        handleBoundaryCellStretching(scrollView)
        
        isHandlingScroll = false
    }
    
    private func handleBoundaryCellStretching(_ scrollView: UIScrollView) {
        
        let minScrollPosition = scrollView.contentOffset.y
        
        let maxScrollPosition = scrollView.contentOffset.y + view.bounds.height
        
        // check whether the scrollPosition has exceeded the start of the scroll view or the past the end
        guard (maxScrollPosition > scrollView.contentSize.height || minScrollPosition < 0) else {
            resetModifiedCells()
            return
        }
        
        let topOffset = -minScrollPosition
        let bottomOffset = maxScrollPosition - scrollView.contentSize.height
        
        let visibleCells = collectionView.indexPathsForVisibleItems
        let topVisibleCells = visibleCells.filter {
            $0.item % 24 == 0
        }
        
        let bottomVisibleCells = visibleCells.filter {
            ($0.item + 1) % 24 == 0
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
                frame.size.height = (cell.layer.value(forKey: "normalHeight") as? CGFloat ?? 100) + topOffset
                
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
                frame.size.height = (cell.layer.value(forKey: "normalHeight") as? CGFloat ?? 100) + bottomOffset
                
                cell.frame = frame
            }
        }
    }
    
    func resetModifiedCells() {
        for cell in modifiedCells {
            // Retrieve the original frame values you stored
            if let originalY = cell.layer.value(forKey: "normal") as? CGFloat,
               let originalHeight = cell.layer.value(forKey: "normalHeight") as? CGFloat {
                
                var frame = cell.frame
                frame.origin.y = originalY
                frame.size.height = originalHeight
                cell.frame = frame
            }
        }
        modifiedCells.removeAll()
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

protocol WeekCalendarViewDelegate: AnyObject {
    func showEventDetails(for event: EventOccurrence, and user: User, from view: UIView)
}

extension WeekViewController: WeekCalendarViewDelegate {
    func showEventDetails(for event: EventOccurrence, and user: User, from view: UIView) {
        
        guard let vm = coordinator?.vm else { return }
        
        let eventDetailsView = FullEventDetailsView(event: event, currentUser: vm.currentUser)
        
        let hostingController = UIHostingController(rootView: eventDetailsView)
        
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
        
        navigationController?.tabBarController?.setTabBarHidden(true, animated: true)
        navigationController?.pushViewController(hostingController, animated: true)
    }
}

class BorderedCellView: UIView {
    
    let topBorderHeight: CGFloat = 1.5
    let sideBorderWidth: CGFloat = 0.75
    let borderColor = UIColor.separator

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

class EventView: UICollectionReusableView {
    // MARK: - Properties
    static let identifier = "EventView"

    // --- Data & Delegates ---
    var event: EventOccurrence?
    var coordinator: CalendarYearView.Coordinator?
    weak var eventDetailsDelegate: WeekCalendarViewDelegate?

    // --- UI Elements ---
    private let glassContainer = UIVisualEffectView()
    private let eventButton = UIButton(type: .custom)
    private let titleLabel = UILabel()
    private let startTimeLabel = UILabel()
    private let endTimeLabel = UILabel()
    private let shortenedTimeLabel = UILabel()

    // --- Styling Properties ---
    private var shadowLayer: CAShapeLayer!
    private let cornerRadius: CGFloat = 8.0
    
    // To store constraint constants that need to change
    private var titleTopConstraint: NSLayoutConstraint!
    private var startTimeTopConstraint: NSLayoutConstraint!
    private var endTimeTopConstraint: NSLayoutConstraint!

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupProperties()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    func configure(with event: EventOccurrence) {
        self.event = event
        
        // 1. Set text content
        titleLabel.text = event.event.title
        let startTimeText = "\(Date.convertHourAndMinuteToDate(time: event.event.startTime).formatted(date: .omitted, time: .shortened))-"
        let endTimeText = "\(Date.convertHourAndMinuteToDate(time: event.event.endTime).formatted(date: .omitted, time: .shortened))"
        startTimeLabel.text = startTimeText
        endTimeLabel.text = endTimeText
        shortenedTimeLabel.text = startTimeText + endTimeText
        
        // 2. Update colors for the new event data and current theme
        updateColors()
        
        // 3. Adjust dynamic layout elements based on the view's final frame height
        adjustLayoutForHeight(frame.height)
    }

    // MARK: - Layout & Appearance
    override func layoutSubviews() {
        super.layoutSubviews()
        // This is the correct place to create/update frame-dependent layers
        updateShadow()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Ensure colors are updated when switching between light/dark mode
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColors()
        }
    }

    private func setupHierarchy() {
        addSubview(glassContainer)
        glassContainer.contentView.addSubview(eventButton)
        glassContainer.contentView.addSubview(titleLabel)
        glassContainer.contentView.addSubview(startTimeLabel)
        glassContainer.contentView.addSubview(endTimeLabel)
        glassContainer.contentView.addSubview(shortenedTimeLabel)
    }

    private func setupProperties() {
        // Glass Container
        glassContainer.translatesAutoresizingMaskIntoConstraints = false
        glassContainer.layer.cornerRadius = cornerRadius
        glassContainer.layer.masksToBounds = true
        if #available(iOS 26.0, *) {
            glassContainer.effect = UIGlassEffect(style: .regular)
        } else {
            // Fallback on earlier versions
        }        
        // Event Button (for interaction)
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.background.backgroundColor = .clear
        eventButton.configuration = buttonConfig
        eventButton.translatesAutoresizingMaskIntoConstraints = false
        eventButton.addTarget(self, action: #selector(showEventDetails), for: .touchUpInside)

        // Title Label
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor(Color(hex: 0xf7f4f2))
        titleLabel.font = UIFont.systemFont(ofSize: 10, weight: .heavy)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Time Labels (setup is similar for all)
        [startTimeLabel, endTimeLabel, shortenedTimeLabel].forEach { label in
            label.textAlignment = .left
            label.textColor = UIColor(Color(hex: 0xf7f4f2))
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        startTimeLabel.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        endTimeLabel.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        shortenedTimeLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        shortenedTimeLabel.adjustsFontSizeToFitWidth = true
    }
    
    private func setupConstraints() {
        // Store dynamic constraints to modify them later
        titleTopConstraint = titleLabel.topAnchor.constraint(equalTo: glassContainer.topAnchor, constant: 5)
        startTimeTopConstraint = startTimeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3)
        endTimeTopConstraint = endTimeLabel.topAnchor.constraint(equalTo: startTimeLabel.bottomAnchor, constant: -1)
        
        NSLayoutConstraint.activate([
            // Glass Container fills the entire view
            glassContainer.topAnchor.constraint(equalTo: topAnchor),
            glassContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            glassContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // Button fills the container
            eventButton.topAnchor.constraint(equalTo: glassContainer.topAnchor),
            eventButton.bottomAnchor.constraint(equalTo: glassContainer.bottomAnchor),
            eventButton.leadingAnchor.constraint(equalTo: glassContainer.leadingAnchor),
            eventButton.trailingAnchor.constraint(equalTo: glassContainer.trailingAnchor),
            
            // Title Label
            titleLabel.leadingAnchor.constraint(equalTo: glassContainer.leadingAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: glassContainer.trailingAnchor, constant: -2),
            titleTopConstraint,
            
            // Start Time
            startTimeLabel.leadingAnchor.constraint(equalTo: glassContainer.leadingAnchor, constant: 2),
            startTimeLabel.trailingAnchor.constraint(equalTo: glassContainer.trailingAnchor, constant: -2),
            startTimeTopConstraint,
            
            // End Time
            endTimeLabel.leadingAnchor.constraint(equalTo: glassContainer.leadingAnchor, constant: 2),
            endTimeLabel.trailingAnchor.constraint(equalTo: glassContainer.trailingAnchor, constant: -2),
            endTimeTopConstraint,
            
            // Shortened Time (for small cells)
            shortenedTimeLabel.leadingAnchor.constraint(equalTo: glassContainer.leadingAnchor, constant: 2),
            shortenedTimeLabel.trailingAnchor.constraint(equalTo: glassContainer.trailingAnchor, constant: -2),
            shortenedTimeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -2)
        ])
    }
    
    // MARK: - Private Logic
    private func updateColors() {
        guard let event = event, let hex = Int(event.event.color, radix: 16) else { return }
        
        let baseColor = UIColor(Color(hex: hex))
        let adjustedColor: UIColor
        
        if traitCollection.userInterfaceStyle == .dark {
            adjustedColor = baseColor.withBrightnessAdjusted(by: 0.675)
        } else {
            adjustedColor = baseColor.withBrightnessAdjusted(by: 0.875)
        }
        
        glassContainer.backgroundColor = adjustedColor
    }
    
    private func adjustLayoutForHeight(_ height: CGFloat) {
        titleLabel.numberOfLines = calculateMaxLines(for: height, fontWeight: .heavy)
        
        let showFullTime = height > 40
        startTimeLabel.isHidden = !showFullTime
        endTimeLabel.isHidden = !showFullTime
        shortenedTimeLabel.isHidden = showFullTime
        
        // Adjust spacing based on height
        titleTopConstraint.constant = showFullTime ? 5 : 2
        startTimeTopConstraint.constant = height < 75 ? 1 : 3
        endTimeTopConstraint.constant = height <= 75 ? -3 : -1
    }
    
    private func updateShadow() {
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            // Important: Insert below the glassContainer's layer
            layer.insertSublayer(shadowLayer, at: 0)
        }
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOpacity = 0.20
        shadowLayer.shadowOffset = CGSize(width: 0, height: 4.0)
        shadowLayer.shadowRadius = 3.0
    }

    private func calculateMaxLines(for height: CGFloat, fontSize: CGFloat = 10, fontWeight: UIFont.Weight) -> Int {
        let lineHeight = UIFont.systemFont(ofSize: fontSize, weight: fontWeight).lineHeight
        let availableHeight = height - 4 // Basic padding adjustment
        
        // Custom logic from original file
        if Int(availableHeight) < 50 {
            return 2
        } else {
            return max(1, Int(availableHeight / lineHeight))
        }
    }

    @objc private func showEventDetails() {
        guard let event = event, let vm = coordinator?.vm else { return }
        eventDetailsDelegate?.showEventDetails(for: event, and: vm.currentUser, from: self)
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
