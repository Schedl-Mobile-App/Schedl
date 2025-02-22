//
//  CollectionViewOverlayCell.swift
//  Schedoolr
//
//  Created by David Medina on 2/21/25.
//

import UIKit

class CollectionViewOverlayCell: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
