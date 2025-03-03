//
//  CollectionViewCell.swift
//  Schedoolr
//
//  Created by David Medina on 2/20/25.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    static let identifier = "EventCell"
        
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
        cellView.backgroundColor = .systemBackground
        cellView.layer.borderColor = UIColor(named: "PrimaryTextColor")?.cgColor
        cellView.layer.borderWidth = 0.25
    }
    
    // Setup the view and add imageView with constraints
    private func setupView() {
        contentView.addSubview(cellView)
        // will take up the entire space of the given content view (parent view)
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
