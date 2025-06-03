//
//  CollectionViewCell.swift
//  Schedoolr
//
//  Created by David Medina on 2/20/25.
//

import UIKit
import SwiftUICore

class CollectionViewCell: UICollectionViewCell {
    
    static let identifier = "EventCell"
    
    let cellContainer = UIView()
    
        
    // Lazy initialization of the UIImageView
    private lazy var cellView: UILabel = {
        let cellView = UILabel()
        cellView.translatesAutoresizingMaskIntoConstraints = false
        return cellView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        cellView.backgroundColor = UIColor(Color(hex: 0xf7f4f2))
    }
    
    // Setup the view and add imageView with constraints
    private func setupView() {
        contentView.addSubview(cellView)
        
        let rightBorderView = UIView()
        let leftBorderView = UIView()
        let topBorderView = UIView()
        
        rightBorderView.backgroundColor = UIColor(Color(hex: 666666))
        leftBorderView.backgroundColor = UIColor(Color(hex: 666666))
        topBorderView.backgroundColor = UIColor(Color(hex: 666666))
        
        rightBorderView.translatesAutoresizingMaskIntoConstraints = false
        leftBorderView.translatesAutoresizingMaskIntoConstraints = false
        topBorderView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(rightBorderView)
        contentView.addSubview(leftBorderView)
        contentView.addSubview(topBorderView)
        
        let topBorderHeight: CGFloat = 1
        let sideBorderWidth: CGFloat = 0.5
        
        // will take up the entire space of the given content view (parent view)
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            rightBorderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            rightBorderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            rightBorderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            rightBorderView.widthAnchor.constraint(equalToConstant: sideBorderWidth),
            
            leftBorderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            leftBorderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            leftBorderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            leftBorderView.widthAnchor.constraint(equalToConstant: sideBorderWidth),
            
            topBorderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topBorderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topBorderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topBorderView.heightAnchor.constraint(equalToConstant: topBorderHeight),
        ])
    }
}
