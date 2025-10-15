//
//  MonthViewControlelr.swift
//  Schedl
//
//  Created by David Medina on 6/29/25.
//

import UIKit
import SwiftUI
import Combine

struct MonthCalendarPreviewViewRepresentable: UIViewControllerRepresentable {
    
    var centerMonth: Date
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = MonthViewController(centerMonth: centerMonth)
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}

#Preview {
    
    let dateComponents = Calendar.current.dateComponents([.year, .month], from: Date())
    let centerMonth = Calendar.current.date(from: dateComponents)!
    
    NavigationStack {
        MonthCalendarPreviewViewRepresentable(centerMonth: centerMonth)
            .ignoresSafeArea()
    }
}

//enum CalendarTypeOptions: CaseIterable {
//    case month
//    case week
//}

class MonthViewController: UIViewController, VCCoordinatorProtocol {
    
    var coordinator: CalendarYearView.Coordinator?
    
    var collectionView: UICollectionView!
    
    let calendarTypeButton = UIButton()
    var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search Events"
        return searchController
    }()
    
    private var hasScrolledToInitialPosition = false
    
    private var cancellables: Set<AnyCancellable> = []
    private var centerDatePosition: CGFloat = 0
    
    var centerMonth: Date
    
    lazy var dates: [Date] = {
        let numberOfMonths = 12
        let numberOfYears = 2
        return (-(numberOfMonths * numberOfYears)...(numberOfMonths * numberOfYears)).map { index in
            Calendar.current.date(byAdding: .month, value: index, to: centerMonth)!
        }
    }()
    
    var displayedMonth: Int = 0 {
        didSet {
            let supplementaryItems = collectionView.visibleSupplementaryViews(ofKind: "GlobalMonthHeaderView")
            if let globalHeader = supplementaryItems.first as? GlobalMonthHeaderView {
                globalHeader.configure(with: displayedMonth)
            }
        }
    }
    
    var displayMonthSection: Int = 0 {
        didSet {
            let month = dates[displayMonthSection]
            let monthComponent = Calendar.current.component(.month, from: month)
            displayedMonth = monthComponent
        }
    }
    
    init(centerMonth: Date) {
        let monthComponent = Calendar.current.dateComponents([.month], from: centerMonth)
        self.centerMonth = Calendar.current.date(from: monthComponent)!
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        view.backgroundColor = .systemBackground
                
        setupUI()
        setupPublishers()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(DayCellView.self, forCellWithReuseIdentifier: DayCellView.identifier)
        collectionView.register(MonthHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MonthHeaderView.identifier)
        collectionView.register(
            GlobalMonthHeaderView.self,
            forSupplementaryViewOfKind: "GlobalMonthHeaderView",
            withReuseIdentifier: GlobalMonthHeaderView.reuseIdentifier
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Only perform this scroll the very first time the layout is set
        if !hasScrolledToInitialPosition {
            scrollToCurrentMonth(false)
            hasScrolledToInitialPosition = true
            
            centerDatePosition = collectionView.contentOffset.y
        }
    }
    
    private func scrollToCurrentMonth(_ animated: Bool) {
        // the section index for the current year is in the middle
        let monthSection = dates.count / 2 - 1
        
        collectionView.scrollToItem(at: IndexPath(row: 0, section: monthSection), at: .top, animated: animated)
    }
    
    private func setupPublishers() {
        coordinator?.vm.$scrollToCurrentPosition
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                if newValue {
                    self?.scrollToCurrentMonth(true)
                    self?.coordinator?.vm.scrollToCurrentPosition = false
                }
            }
            .store(in: &cancellables)
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
        
        let boundaryItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let boundaryHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: boundaryItemSize,
            elementKind: "GlobalMonthHeaderView",
            alignment: .top
        )
        boundaryHeader.pinToVisibleBounds = true
        boundaryHeader.zIndex = 1024
        
        // 2. Create a configuration for the entire layout
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.boundarySupplementaryItems = [boundaryHeader]
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: {(sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 7), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
                        
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                        
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 45
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(44)
            )
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [sectionHeader]
            
            return section
            
        }, configuration: configuration)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
                
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension MonthViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let month = dates[section]
        let monthDates = month.datesInSameMonth()
        
        var count = monthDates.count
        
        let firstDay = monthDates.first!
        let firstDayComponent = Calendar.current.component(.weekday, from: firstDay)
        if firstDayComponent > 1 {
            count += firstDayComponent - 1
        }
        
        let lastDay = monthDates.last!
        let lastDayComponent = Calendar.current.component(.weekday, from: lastDay)
        if (lastDayComponent < 7) {
            count += 7 - lastDayComponent
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DayCellView.identifier, for: indexPath) as! DayCellView
        
            let monthDate = dates[indexPath.section]
            let monthDates = monthDate.datesInSameMonth()
            guard let firstDayOfMonth = monthDates.first else {
                // This month has no days, hide the cell
                cell.isHidden = true
                return cell
            }
            
            // 2. Calculate the number of days and the starting offset
            let numberOfDaysInMonth = monthDates.count
            let startingOffset = Calendar.current.component(.weekday, from: firstDayOfMonth) - 1
            
            // 3. Check if the current item is a placeholder or a real day
            if indexPath.item >= startingOffset && indexPath.item < (startingOffset + numberOfDaysInMonth) {
                // This is a REAL day
                cell.isHidden = false
                
                // Calculate which day of the month this is
                let dayIndex = indexPath.item - startingOffset
                
                // Get the specific date for this cell
                let dateForCell = monthDates[dayIndex]
                
                cell.configure(date: dateForCell)
                
            } else {
                // This is a PLACEHOLDER cell (from the previous or next month)
                cell.isHidden = true
            }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case "GlobalMonthHeaderView":
            let supplementaryItem = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: GlobalMonthHeaderView.reuseIdentifier, for: indexPath) as! GlobalMonthHeaderView
            
            let section = indexPath.section
            
            let month = dates[section]
            let monthValue = Calendar.current.component(.month, from: month)
            
            supplementaryItem.configure(with: monthValue)
            
            return supplementaryItem
        case UICollectionView.elementKindSectionHeader:
            let supplementaryItem = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MonthHeaderView.identifier, for: indexPath) as! MonthHeaderView
            
            let section = indexPath.section
            
            let month = dates[section]
            let monthDates = month.datesInSameMonth()
            let firstDayOfMonth = monthDates.first!
            let monthValue = Calendar.current.component(.month, from: month)
            
            supplementaryItem.configure(with: monthValue, for: firstDayOfMonth)
            
            return supplementaryItem
        default:
            fatalError("Unhandled supplementary view kind: \(kind)")
        }
    }
}

extension MonthViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == collectionView else { return }
        
        let centerPoint = CGPoint(
            x: collectionView.frame.width / 2,
            y: collectionView.contentOffset.y + (collectionView.frame.height / 2)
        )
        
        // 2. Get the index path for the item at that center point.
        if let centerIndexPath = collectionView.indexPathForItem(at: centerPoint) {
            
            // 3. If the center section has changed, update our property.
            // This triggers the didSet observers to update the header.
            if centerIndexPath.section != displayMonthSection {
                displayMonthSection = centerIndexPath.section
            }
        }
        
        if scrollView.contentOffset.y < centerDatePosition {
            coordinator?.vm.scrollState = .scrollingUp
        } else {
            coordinator?.vm.scrollState = .scrollingDown
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let month = dates[indexPath.section]
        let monthDates = month.datesInSameMonth()
        
        var offset = 0
        let firstDay = monthDates.first!
        let firstDayComponent = Calendar.current.component(.weekday, from: firstDay)
        if firstDayComponent > 1 {
            offset += firstDayComponent - 1
        }
        
        let day = monthDates[indexPath.row - offset]
        
        let weekViewController = WeekViewController(centerDay: day)
        weekViewController.coordinator = self.coordinator
        weekViewController.restorationIdentifier = "WeekViewController"

        weekViewController.preferredTransition = .zoom(sourceViewProvider: { context in
            // Use the context instead of capturing to avoid needing to make a weak reference.
//            let monthViewController = context.zoomedViewController as! MonthViewController
            // Fetch this instead of capturing in case the item shown by the destination view can change while the destination view is visible.
//            let item = monthViewController.item
//            // Look up the index path in case the items in the collection view can change.
//            guard let indexPath = self.dataSource.indexPath(for: item) else {
//                return nil
//            }
            // Always fetch the cell again because even if the data never changes, cell reuse might occur. E.g if the device rotates.
            guard let cell = self.collectionView.cellForItem(at: indexPath) else {
                return nil
            }
            return cell.contentView
        })

        navigationItem.backButtonTitle = "Month"
        navigationController?.pushViewController(weekViewController, animated: true)
    }
}

class DayCellBorder: UIView {
    
    // We will draw these borders ourselves
    let topBorderHeight: CGFloat = 0.5
    let borderColor = UIColor.separator

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Set the background color here
        backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // This is where the magic happens!
    override func draw(_ rect: CGRect) {
        super.draw(rect) // Draws the background color
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Draw Top Border (with its own width)
        context.setLineWidth(topBorderHeight)
        context.move(to: CGPoint(x: 0, y: 0))
        context.addLine(to: CGPoint(x: bounds.width, y: 0))
        context.strokePath()
    }
}

class DayCellView: UICollectionViewCell {
    
    static let identifier = "DayCell"
    
    let borderedView = DayCellBorder()
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        label.translatesAutoresizingMaskIntoConstraints = false
        borderedView.addSubview(label)
        borderedView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(borderedView)
        
        NSLayoutConstraint.activate([
            borderedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            borderedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            borderedView.topAnchor.constraint(equalTo: contentView.topAnchor),
            borderedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            label.centerXAnchor.constraint(equalTo: borderedView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: borderedView.centerYAnchor),
        ])
    }
    
    func configure(date: Date) {
        let day = Calendar.current.component(.day, from: date)
        
        let font = UIFont.preferredFont(forTextStyle: .title3)
        let boldFont = UIFont.systemFont(ofSize: font.pointSize, weight: .semibold)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: boldFont,
        ]
        let attributedString = NSAttributedString(string: "\(day)", attributes: attributes)
                
        label.attributedText = attributedString
        label.textAlignment = .center
    }
}

class MonthHeaderView: UICollectionReusableView {
    
    static let identifier = "MonthHeader"
    
    private var monthLabelLeadingConstraint: NSLayoutConstraint?
    
    let monthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .label // Adapts to light/dark mode
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
                
        addSubview(monthLabel)
        
        let leadingConstraint = monthLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
        self.monthLabelLeadingConstraint = leadingConstraint
        
        // 2. Activate the new leading constraint along with the others.
        //    The old leading/trailing constraints are removed.
        NSLayoutConstraint.activate([
            leadingConstraint, // Activate the stored constraint
            monthLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with month: Int, for firstDayOfMonth: Date) {
        let monthName = Calendar.current.shortMonthSymbols[month-1]
        
        monthLabel.text = "\(monthName)"
        
        // Ensure the view has a width before calculating.
        guard self.bounds.width > 0 else { return }
        
        // --- Calculation Logic ---
        // 1. Determine the width of a single day's column in the 7-day grid.
        let columnWidth = self.bounds.width / 7.0
        
        // 2. Get the weekday index (0 for Sunday, 1 for Monday, etc.).
        let weekdayIndex = Calendar.current.component(.weekday, from: firstDayOfMonth) - 1
        
        // 3. Calculate the total offset by multiplying the column width by the index.
        let totalOffset = columnWidth * CGFloat(weekdayIndex)
        
        // 4. Update the constraint's constant to shift the label.
        monthLabelLeadingConstraint?.constant = totalOffset
    }
}

class GlobalMonthHeaderView: UICollectionReusableView {
    
    // A unique string to identify this view for reuse.
    static let reuseIdentifier = "GlobalMonthHeaderView"
    
    // A formatter to avoid creating a new one every time the text is updated.
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy" // e.g., "October 2025"
        return formatter
    }()
    
    private var blurView: UIVisualEffectView!
    
    var topAnchorConstraint: NSLayoutConstraint!
    var bottomAnchorConstraint: NSLayoutConstraint!
    
    var topInset: CGFloat = 0 {
        didSet {
            topAnchorConstraint.constant = -topInset
            
            if let window = window {
                let insets = window.safeAreaInsets.top
                bottomAnchorConstraint.constant = insets - insets/3
            }
            
            layoutIfNeeded()
        }
    }
    
    // The label that will display the month and year.
    let monthLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let weekdayLabelStackView: UIStackView = {
        
        let font = UIFont.preferredFont(forTextStyle: .caption2)
        let boldFont = UIFont.systemFont(ofSize: font.pointSize, weight: .semibold)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: boldFont,
        ]
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let weekdays = Calendar.current.veryShortWeekdaySymbols
        for day in weekdays {
            let attributedString = NSAttributedString(string: "\(day)", attributes: attributes)
            let label = UILabel()
            label.textColor = .secondaryLabel
            label.attributedText = attributedString
            label.text = day
            label.textAlignment = .center
            
            stackView.addArrangedSubview(label)
        }
        
        return stackView
    }()
    
    // A thin line to separate the header from the collection view content.
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var hasCalculatedInitialPosition = false
    
    // The standard initializer for a view.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // This guard ensures the calculation only runs once after the initial layout.
        guard !hasCalculatedInitialPosition, let _ = window else { return }
        
        // Convert the view's top-left corner to the window's coordinate space.
        let originInWindow = self.convert(self.bounds.origin, to: nil)
        
        // The y-value is the distance from the top of the screen to the top of this view.
        let distanceToScreenTop = originInWindow.y
        
        // Now you can use this value. For example, if you want your blur view
        // to extend all the way up and cover the safe area (like the notch),
        // this distance is exactly what you need for the offset.
        self.topInset = distanceToScreenTop
        
        print("Distance to screen top is: \(distanceToScreenTop)")
        
        // Mark that we've done the initial setup.
        hasCalculatedInitialPosition = true
    }
    
    func configure(with month: Int) {
        let monthName = Calendar.current.monthSymbols[month - 1]
        
        let font = UIFont.preferredFont(forTextStyle: .largeTitle)
        let boldFont = UIFont.systemFont(ofSize: font.pointSize, weight: .bold)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: boldFont,
        ]
        let attributedString = NSAttributedString(string: "\(monthName)", attributes: attributes)
        
        monthLabel.attributedText = attributedString
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        // 2. Create the blur effect. `.systemMaterial` is a great choice to mimic the navigation bar.
        let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        // 3. Add the blurView as the base layer of your header.
        addSubview(blurView)
        
        // 4. IMPORTANT: Add all content to the blurView's `contentView`.
        // This ensures your content is displayed correctly on top of the blur.
        blurView.contentView.addSubview(monthLabel)
        blurView.contentView.addSubview(weekdayLabelStackView)

//        addSubview(separatorView)
        
        topAnchorConstraint = blurView.topAnchor.constraint(equalTo: topAnchor, constant: -topInset)
        bottomAnchorConstraint = blurView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: topInset)
        
        NSLayoutConstraint.activate([
            // Pin the blur view to the edges of the header
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topAnchorConstraint,
            bottomAnchorConstraint,
            
            // This constraint was incorrect in your original code.
            // It now correctly places the weekday labels below the month label.
            weekdayLabelStackView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
            weekdayLabelStackView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),
            // This bottom anchor helps the layout system determine the view's total height.
            weekdayLabelStackView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -4),
            
            // --- Content Constraints (relative to the contentView) ---
            monthLabel.bottomAnchor.constraint(equalTo: weekdayLabelStackView.topAnchor, constant: -12),
            monthLabel.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 16),
            monthLabel.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -16),

//            // --- Separator Constraints (relative to the main view) ---
//            separatorView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//            separatorView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
//            separatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
//            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}
