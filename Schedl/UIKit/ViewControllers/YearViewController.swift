//
//  YearViewController.swift
//  Schedl
//
//  Created by David Medina on 10/6/25.
//

import UIKit
import SwiftUI
import Combine

struct YearCalendarPreviewViewRepresentable: UIViewControllerRepresentable {
    
    var centerYear: Date
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = YearViewController(centerYear: centerYear)
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}

#Preview {
    
    let yearComponent = Calendar.current.dateComponents([.year], from: Date())
    let centerYear = Calendar.current.date(from: yearComponent)!
    
    NavigationStack {
        YearCalendarPreviewViewRepresentable(centerYear: centerYear)
            .ignoresSafeArea()
    }
}

struct YearItem: Hashable {
    let year: Date
    let month: Int
}

class YearViewController: UIViewController, VCCoordinatorProtocol {
    
    var collectionView: UICollectionView!
    
    private var hasScrolledToInitialPosition = false
    private var centerDatePosition: CGFloat = 0
    private var cancellables: Set<AnyCancellable> = []
    
    private var isLoadingData = false
    
    private var dataSource: UICollectionViewDiffableDataSource<Date, YearItem>!
    
    let calendarTypeButton = UIButton()
    var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search Events"
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()
    
    var coordinator: CalendarYearView.Coordinator?
    
    var centerYear: Date
    
    lazy var dates: [Date] = {
        
        let calendar = Calendar.current
        let yearComponent = calendar.dateComponents([.year], from: centerYear)
        let startOfCenterYear = calendar.date(from: yearComponent)!
        
        return (-10...10).map { index in
            Calendar.current.date(byAdding: .year, value: index, to: startOfCenterYear)!
        }
    }()
    
    init(centerYear: Date) {
        self.centerYear = centerYear
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupUI()
        configureDataSource()
        applySnapshot()
        setupPublishers()
        
        collectionView.register(MonthCellView.self, forCellWithReuseIdentifier: MonthCellView.identifier)
        collectionView.register(YearSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: YearSectionHeaderView.identifier)
        
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Only perform this scroll the very first time the layout is set
        if !hasScrolledToInitialPosition {
            scrollToCurrentYear(false)
            hasScrolledToInitialPosition = true
            
            centerDatePosition = collectionView.contentOffset.y
        }
    }
    
    private func scrollToCurrentYear(_ animated: Bool) {
        // the section index for the current year is in the middle
        let yearSection = dates.count / 2
        
        collectionView.scrollToItem(at: IndexPath(row: 7, section: yearSection), at: .centeredVertically, animated: animated)
    }
    
    private func configureDataSource() {
        // 1. CELL PROVIDER
        dataSource = UICollectionViewDiffableDataSource<Date, YearItem>(collectionView: collectionView) {
            (collectionView, indexPath, monthIndex) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MonthCellView.identifier, for: indexPath) as! MonthCellView
            
            // Get the section identifier (the Date for the year)
            let yearDate = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            cell.configure(with: yearDate, for: monthIndex.month)
            return cell
        }

        // 2. SUPPLEMENTARY VIEW PROVIDER (for the header)
        dataSource.supplementaryViewProvider = { [weak self]
            (collectionView, kind, indexPath) -> UICollectionReusableView? in
            
            guard let self = self else { return nil }
            
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: YearSectionHeaderView.identifier,
                for: indexPath
            ) as! YearSectionHeaderView
            
            let yearDate = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            let year = Calendar.current.component(.year, from: yearDate)
            header.configure(with: year)
            
            return header
        }
    }
    
    private func applySnapshot() {
        // 1. Create a new snapshot. The types must match your data source.
        var snapshot = NSDiffableDataSourceSnapshot<Date, YearItem>()
        
        // 2. Add the sections using your `dates` array.
        snapshot.appendSections(dates)
        
        // 3. Add items (months) to each section.
        for yearDate in dates {
            let months = Array(0..<12)
            let monthItems = months.map { YearItem(year: yearDate, month: $0 ) }
            snapshot.appendItems(monthItems, toSection: yearDate)
        }
        
        // 4. Apply the snapshot to the data source to update the UI.
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func setupPublishers() {
        coordinator?.vm.$scrollToCurrentPosition
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                if newValue {
//                    self?.scrollToCurrentYear(true)
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
    
    func setupUI() {
        
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "ellipsis")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold, scale: .default)
        
        calendarTypeButton.configuration = config
        calendarTypeButton.showsMenuAsPrimaryAction = true
        
        let searchBarItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(showSearchField))
        let calendarTypeItem = UIBarButtonItem(customView: calendarTypeButton)
        
        navigationItem.rightBarButtonItems = [calendarTypeItem, searchBarItem]
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            // --- ITEM ---
            // This defines the size of a single month cell.
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / 3.0), // Each item is 1/3 of the group's width
                heightDimension: .fractionalHeight(1.0)     // Each item is 100% of the group's height
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            // Add some padding around each month cell
            item.contentInsets = NSDirectionalEdgeInsets(top: -10, leading: 0, bottom: -10, trailing: 0)

            // --- GROUP ---
            // This defines a horizontal row containing 3 month cells.
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),       // The group spans the full width of the screen
                heightDimension: .fractionalWidth(1.0 / 4)       // Make the row's height 40% of the screen's width
            )
            // This group arranges 3 items horizontally. The layout engine handles the wrapping.
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 3)
            group.interItemSpacing = .flexible(12.5)

            // --- SECTION ---
            // The section is made up of the repeating group.
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 55, trailing: 15)
            section.interGroupSpacing = 50

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(50)
            )
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader, // Use the standard kind
                alignment: .top
            )
            section.boundarySupplementaryItems = [sectionHeader]
            
            return section
        }
        
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.decelerationRate = .fast
        
        view.addSubview(collectionView)
                
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension YearViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == collectionView else { return }
        
        if scrollView.contentOffset.y < centerDatePosition {
            coordinator?.vm.scrollState = .scrollingUp
        } else {
            coordinator?.vm.scrollState = .scrollingDown
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let year = dataSource.sectionIdentifier(for: indexPath.section) else { return }
        let yearComponent = Calendar.current.component(.year, from: year)
        let monthComponent = indexPath.item + 1
        
        let date = Calendar.current.date(from: DateComponents(year: yearComponent, month: monthComponent))!
        
//        guard let vm = coordinator?.vm else { return }

        let monthViewController = MonthViewController(centerMonth: date)
        monthViewController.coordinator = self.coordinator
        monthViewController.restorationIdentifier = "MonthViewController"

        monthViewController.preferredTransition = .zoom(sourceViewProvider: { context in
            guard let monthViewController = context.zoomedViewController as? MonthViewController else { return nil }
            
            // Fetch this instead of capturing in case the item shown by the destination view can change while the destination view is visible.
            let visibleDate = monthViewController.visibleDate // Make sure this property is accessible
            
            let calendar = Calendar.current
            
            // ✅ NORMALIZE the date to get a clean identifier for the year
            let components = calendar.dateComponents([.year], from: visibleDate)
            guard let targetYearDate = calendar.date(from: components) else {
                // This is a robust way to create the section identifier we're looking for
                return nil
            }
            
            // Now, find the index of that exact, normalized date.
            guard let sectionIndex = self.dataSource.snapshot().indexOfSection(targetYearDate) else {
                // This will now correctly find the section
                return nil
            }
            
            // Get the item index (0-11)
            let itemIndex = calendar.component(.month, from: visibleDate) - 1
            
            let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
            
            if !self.collectionView.indexPathsForVisibleItems.contains(indexPath) {
                
                self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            }
            
            // Always fetch the cell again because cell reuse might occur.
            guard let cell = self.collectionView.cellForItem(at: indexPath) else {
                return nil
            }
            
            return cell.contentView
        })
        

        navigationItem.backButtonTitle = "Year"
        navigationController?.pushViewController(monthViewController, animated: true)
    }
}

extension YearViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
            // 1. Prevent multiple loads at once
            guard !isLoadingData else { return }
            
            // 2. Find the maximum section index being prefetched
            if let maxSection = indexPaths.map({ $0.section }).max() {
                let totalSections = dataSource.snapshot().numberOfSections
                
                // 3. If we are within 3 sections of the end, load the next year
                if maxSection >= totalSections - 3 {
                    loadNextYear()
                }
            }
            
            // 4. Find the minimum section index being prefetched
            if let minSection = indexPaths.map({ $0.section }).min() {
                // 5. If we are within 3 sections of the beginning, load the previous year
                if minSection <= 2 {
                    loadPreviousYear()
                }
            }
        }
        
        private func loadNextYear() {
            isLoadingData = true
            
            // Get the last year we have data for
            guard let lastYear = dates.last else {
                isLoadingData = false
                return
            }
            
            // Calculate the next year
            let nextYears = (1...5).map { Calendar.current.date(byAdding: .year, value: $0, to: lastYear)! }
            
            // Add the new year to our local data model
            dates.append(contentsOf: nextYears)
            
            let datesToRemove = (1...5).map { _ in dates.removeFirst() }
                        
            // Update the data source snapshot
            var currentSnapshot = dataSource.snapshot()
            currentSnapshot.appendSections(nextYears)
            nextYears.forEach { year in
                let monthItems = (0..<12).map { monthIndex in
                    return YearItem(year: year, month: monthIndex)
                }
                
                currentSnapshot.appendItems(monthItems, toSection: year)
            }
            
            
            currentSnapshot.deleteSections(datesToRemove)
            
            // Apply the new snapshot
            dataSource.apply(currentSnapshot, animatingDifferences: true) { [weak self] in
                self?.isLoadingData = false
            }
        }
        
        private func loadPreviousYear() {
            isLoadingData = true
            
            // Get the first year we have data for
            guard let firstYear = dates.first else {
                isLoadingData = false
                return
            }
            
            // Calculate the previous year
            let previousYear = Calendar.current.date(byAdding: .year, value: -1, to: firstYear)!
            
            // Add the new year to the beginning of our local data model
            dates.insert(previousYear, at: 0)
            
            // Update the data source snapshot by inserting the new section
            var currentSnapshot = dataSource.snapshot()
            currentSnapshot.insertSections([previousYear], beforeSection: firstYear)
            let monthItems = (0..<12).map { YearItem(year: previousYear, month: $0) }
            currentSnapshot.appendItems(monthItems, toSection: previousYear)
            
            // Apply the new snapshot
            dataSource.apply(currentSnapshot, animatingDifferences: false) { [weak self] in
                self?.isLoadingData = false
            }
        }
}

class MonthCellView: UICollectionViewCell {
    static let identifier = "MonthCellView"
    
    let monthLabel = UILabel()
    let weekRowsStackView = UIStackView()
    var dayViews: [UIView] = []
    var dayLabels: [UILabel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        monthLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        monthLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        weekRowsStackView.translatesAutoresizingMaskIntoConstraints = false
        weekRowsStackView.axis = .vertical
        weekRowsStackView.distribution = .fillEqually
        
        for _ in 0..<6 {
            let weekStackView = UIStackView()
            weekStackView.axis = .horizontal
            weekStackView.alignment = .leading
            weekStackView.distribution = .fillEqually
            
            for _ in 1...7 {
                let label = UILabel()
                label.backgroundColor = .systemBackground
                label.font = UIFont.preferredFont(forTextStyle: .caption2)
                label.textColor = .black
                label.textAlignment = .center
                label.translatesAutoresizingMaskIntoConstraints = false
                dayLabels.append(label)
                weekStackView.addArrangedSubview(label)
            }
            
            weekRowsStackView.addArrangedSubview(weekStackView)
        }
        
        contentView.addSubview(monthLabel)
        contentView.addSubview(weekRowsStackView)
        
        NSLayoutConstraint.activate([
            monthLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            monthLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            monthLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            weekRowsStackView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 5),
            weekRowsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            weekRowsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            weekRowsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    func configure(with date: Date, for month: Int) {
        let monthName = Calendar.current.shortMonthSymbols[month]
        
        guard let targetMonthDate = Calendar.current.date(byAdding: .month, value: month, to: date) else { return }
        
        if Calendar.current.isDate(targetMonthDate, equalTo: Date.now, toGranularity: .month) {
            // If it is, make it red
            monthLabel.textColor = .systemRed
        } else {
            monthLabel.textColor = .primaryText
        }
        
        monthLabel.text = monthName
                
        dayLabels.forEach { $0.text = "" }
        
        // Set the month name label (assuming `month` is 0-11)
        monthLabel.text = Calendar.current.shortMonthSymbols[month]
        
        // --- Step 2: Get all the days in that month ---
        let daysInMonth = targetMonthDate.datesInSameMonth()
        guard let firstDayOfMonth = daysInMonth.first else { return }
        
        // --- Step 3: Find the starting weekday (the offset) ---
        // .weekday returns 1 for Sunday, 2 for Monday, etc. We subtract 1 for a 0-indexed offset.
        let startDayOffset = Calendar.current.component(.weekday, from: firstDayOfMonth) - 1
        
        // --- Step 4: Loop through the days and populate the labels ---
        for (index, date) in daysInMonth.enumerated() {
            let day = Calendar.current.component(.day, from: date)
            let labelIndex = startDayOffset + index
            
            if labelIndex < dayLabels.count {
                dayLabels[labelIndex].text = "\(day)"
            }
            
            if Calendar.current.isDate(date, inSameDayAs: Date.now) {
                // If it is, make it red
                
                let font = UIFont.preferredFont(forTextStyle: .caption2)
                let boldFont = UIFont.systemFont(ofSize: font.pointSize, weight: .heavy)
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.white,
                    .font: boldFont,
                ]
                let attributedString = NSAttributedString(string: "\(day)", attributes: attributes)
                
                dayLabels[labelIndex].layer.cornerRadius = 6.75
                dayLabels[labelIndex].layer.masksToBounds = true
                dayLabels[labelIndex].backgroundColor = .systemRed
                dayLabels[labelIndex].textColor = .white
                dayLabels[labelIndex].attributedText = attributedString
            } else {
                // IMPORTANT: If it's not, reset it to the default
                dayLabels[labelIndex].backgroundColor = .clear
                dayLabels[labelIndex].textColor = .label
            }
        }
    }
}

class YearSectionHeaderView: UICollectionReusableView {
    
    // A unique string to identify this view type
    static let identifier = "YearSectionHeaderView"
    
    let separatorView = UIView()
    
    // The label that will display the year
    let yearLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textColor = .label // Adapts to light/dark mode
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        separatorView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.3)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
                
        // Add the label to the view's hierarchy
        addSubview(yearLabel)
        addSubview(separatorView)
        
        // Set up constraints to position the label
        NSLayoutConstraint.activate([
            yearLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            yearLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.topAnchor.constraint(equalTo: yearLabel.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // A function to configure the view with data
    func configure(with year: Int) {
        
        let currentYear = Calendar.current.component(.year, from: Date())
        
        if currentYear == year {
            yearLabel.textColor = .systemRed
        }
        
        yearLabel.text = "\(year)"
    }
}
