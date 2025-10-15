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

struct MonthSection: Hashable {
    let id = UUID()
    let date: Date
    let month: Int
}

class YearViewController: UIViewController, VCCoordinatorProtocol {
    
    var collectionView: UICollectionView!
    
    private var hasScrolledToInitialPosition = false
    private var centerDatePosition: CGFloat = 0
    private var cancellables: Set<AnyCancellable> = []
    
    let calendarTypeButton = UIButton()
    var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search Events"
        searchController.searchBar.sizeToFit()
        return searchController
    }()
    
    var coordinator: CalendarYearView.Coordinator?
    
    var centerYear: Date
    
    lazy var dates: [Date] = {
        return (-300...300).map { index in
            Calendar.current.date(byAdding: .year, value: index, to: centerYear)!
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
        setupPublishers()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(MonthCellView.self, forCellWithReuseIdentifier: MonthCellView.identifier)
        collectionView.register(YearSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: YearSectionHeaderView.identifier)
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
        let yearSection = dates.count / 2 - 1
        
        collectionView.scrollToItem(at: IndexPath(row: 9, section: yearSection), at: .top, animated: animated)
    }
    
    private func setupPublishers() {
        coordinator?.vm.$scrollToCurrentPosition
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                if newValue {
                    self?.scrollToCurrentYear(true)
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
//            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

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
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 65, trailing: 15)
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

extension YearViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MonthCellView.identifier, for: indexPath) as! MonthCellView
        
        let section = indexPath.section
        let date = dates[section]
        let monthIndex = indexPath.row
        
        cell.configure(with: date, for: monthIndex)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let supplementaryItem = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: YearSectionHeaderView.identifier, for: indexPath) as! YearSectionHeaderView
        
        let section = indexPath.section
        
        let date = dates[section]
        let year = Calendar.current.component(.year, from: date)
        
        supplementaryItem.configure(with: year)
        
        return supplementaryItem
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
        
        let year = dates[indexPath.section]
        let yearComponent = Calendar.current.component(.year, from: year)
        let monthComponent = indexPath.item + 1
        
        let date = Calendar.current.date(from: DateComponents(year: yearComponent, month: monthComponent))!
        
//        guard let vm = coordinator?.vm else { return }

        let monthViewController = MonthViewController(centerMonth: date)
        monthViewController.coordinator = self.coordinator
        monthViewController.restorationIdentifier = "MonthViewController"

        monthViewController.preferredTransition = .zoom(sourceViewProvider: { context in
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
        

        navigationItem.backButtonTitle = "Year"
        navigationController?.pushViewController(monthViewController, animated: true)
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
        
        weekRowsStackView.translatesAutoresizingMaskIntoConstraints = false
        weekRowsStackView.axis = .vertical
        weekRowsStackView.distribution = .fillEqually
        weekRowsStackView.spacing = 5
        
        for _ in 0..<6 {
            let weekStackView = UIStackView()
            weekStackView.axis = .horizontal
            weekStackView.alignment = .leading
            weekStackView.distribution = .fillEqually
            weekStackView.spacing = 3
            
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
            
            weekRowsStackView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 5),
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
