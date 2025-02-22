//
//  ScheduleViewController.swift
//  Schedoolr
//
//  Created by David Medina on 2/20/25.
//

import UIKit
import SwiftUI

class ScheduleViewController: UIViewController {
            
    // using the lazy keyword allows us to safely access member methods within our class => layout function
    lazy var collectionView: UICollectionView = {
        let layout = self.layout()
        
        // creates our collection view with an initial frame of size 0 since we will define the constraints in viewDidLoad
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBlue
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(CollectionViewDaysHeader.self, forSupplementaryViewOfKind: "DayHeader", withReuseIdentifier: "DayHeader")
        collectionView.register(CollectionViewTimesColumn.self, forSupplementaryViewOfKind: "TimeColumn", withReuseIdentifier: "TimeColumn")

//        older method of cell registration which is handled in the initialization of our collection view
//        view.register(EventCell.self, forCellWithReuseIdentifier: "EventCell")
        
        collectionView.isDirectionalLockEnabled = true
        collectionView.bounces = false
        collectionView.decelerationRate = .fast

        // needed since our view controller sets the data source for our collection view
        collectionView.dataSource = self
        
        // tells the collection view that our view controller will handle it's delegation methods
        collectionView.delegate = self
                
        return collectionView
    }()
    
    let cellRegistration = UICollectionView.CellRegistration<CollectionViewCell, Int> { cell, indexPath, item in
        cell.configureUI()
    }
    
    let overlayView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // add the collection view to root view
        view.addSubview(collectionView)
        
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = .systemBackground
        
        view.addSubview(overlayView)
        
        // constraints for our collection view
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.widthAnchor.constraint(equalToConstant: 44),
            overlayView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollToCurrentPosition()
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
        let currentDayIndex = 30 // Middle of our 60-day range (today)
        let itemWidth: CGFloat = 75
        let xOffset = CGFloat(currentDayIndex) * itemWidth + (itemWidth - 44) // Adjust to center current day
        
        collectionView.setContentOffset(CGPoint(x: xOffset, y: safeYOffset), animated: false)
    }
    
    func layout() -> UICollectionViewCompositionalLayout {
        
        let numberOfTimeIntervals: Double = 24
        let numberOfDays: Double = 60
        let itemWidth: CGFloat = 75
        let itemHeight: CGFloat = 100
        let singleDayGroupWidth: CGFloat = itemWidth
        let singleDayGroupHeight: CGFloat = Double(itemHeight) * numberOfTimeIntervals
        let horizontalGroupWidth: CGFloat = singleDayGroupWidth * numberOfDays
        let horizontalGroupHeight: CGFloat = singleDayGroupHeight
        
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
        
        let timeColumnSize = NSCollectionLayoutSize(widthDimension: .absolute(44),
                                                    heightDimension: .absolute(singleDayGroupHeight))
        
        let timeColumn = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: timeColumnSize,
                                                                    elementKind: "TimeColumn",
                                                                    alignment: .leading)
        timeColumn.pinToVisibleBounds = true
        
        section.boundarySupplementaryItems = [timeColumn, dayHeader]
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
}

extension ScheduleViewController: UICollectionViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            snapCellPosition()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapCellPosition()
    }
    
    func snapCellPosition() {
        let timeColumnWidth: CGFloat = 44
        let itemWidth: CGFloat = 75
        
        // Get the total offset from the left edge
        let totalOffset = collectionView.contentOffset.x
        
        // Calculate which day we're closest to, accounting for the time column
        let adjustedOffset = totalOffset - timeColumnWidth
        let estimatedIndex = round(adjustedOffset / itemWidth)
        
        // Ensure the index is within bounds (0 to 59 for your 60 days)
        let safeIndex = max(0, min(Int(estimatedIndex), 59))
        
        // Calculate the precise final position
        // Add a small adjustment factor (e.g., 1-2 points) if needed to fine-tune alignment
        let finalXOffset = (CGFloat(safeIndex) * itemWidth) + timeColumnWidth-12
        
        // Maintain the current y offset
        let currentYOffset = collectionView.contentOffset.y
        
        collectionView.setContentOffset(CGPoint(x: finalXOffset, y: currentYOffset), animated: true)
    }
}

extension ScheduleViewController: UICollectionViewDataSource {

    // only need one section for the entire page
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // 24 represents the number of hours in a day => number of cells needed since an item represents a single hour
    // 60 represents the total number of days we will have available to the user to scroll through
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 24 * 60
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == "TimeColumn" {
            let timeView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TimeColumn", for: indexPath) as! CollectionViewTimesColumn
            return timeView
        } else if kind == "DayHeader" {
            let dayView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DayHeader", for: indexPath) as! CollectionViewDaysHeader
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
