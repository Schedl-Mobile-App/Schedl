//
//  CollectionViewCell.swift
//  Schedoolr
//
//  Created by David Medina on 2/20/25.
//

import UIKit
import SwiftUI

class BorderedCellView: UIView {
    
    // We will draw these borders ourselves
    let topBorderHeight: CGFloat = 1.0
    let sideBorderWidth: CGFloat = 0.5
    let borderColor = UIColor(Color("DividerLines"))

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

class CollectionViewCell: UICollectionViewCell {
    
    static let identifier = "EventCell"
    
//    let cellContainer = UIView()
    
    // The cell now only has ONE subview
        private lazy var borderedView: BorderedCellView = {
            let view = BorderedCellView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
    
        
//    // Lazy initialization of the UIImageView
//    private lazy var cellView: UILabel = {
//        let cellView = UILabel()
//        cellView.translatesAutoresizingMaskIntoConstraints = false
//        return cellView
//    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func configureUI() {
//        cellView.backgroundColor = UIColor(Color(hex: 0xf7f4f2))
//    }
    
    func setupView() {
           // Add the single, efficient view
           contentView.addSubview(borderedView)
           
           // Constrain it to fill the cell
           NSLayoutConstraint.activate([
               borderedView.topAnchor.constraint(equalTo: contentView.topAnchor),
               borderedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
               borderedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
               borderedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
           ])
       }
    
    // Setup the view and add imageView with constraints
//    private func setupView() {
////        contentView.addSubview(cellView)
//        
//        let rightBorderView = UIView()
//        let leftBorderView = UIView()
//        let topBorderView = UIView()
//        
//        rightBorderView.backgroundColor = UIColor(Color(hex: 0xD1CCC6))
//        leftBorderView.backgroundColor = UIColor(Color(hex: 0xD1CCC6))
//        topBorderView.backgroundColor = UIColor(Color(hex: 0xD1CCC6))
//        
//        rightBorderView.translatesAutoresizingMaskIntoConstraints = false
//        leftBorderView.translatesAutoresizingMaskIntoConstraints = false
//        topBorderView.translatesAutoresizingMaskIntoConstraints = false
//        
//        contentView.addSubview(rightBorderView)
//        contentView.addSubview(leftBorderView)
//        contentView.addSubview(topBorderView)
//        
//        let topBorderHeight: CGFloat = 1
//        let sideBorderWidth: CGFloat = 0.5
//        
//        // will take up the entire space of the given content view (parent view)
//        NSLayoutConstraint.activate([
//            cellView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//            
//            rightBorderView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            rightBorderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            rightBorderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//            rightBorderView.widthAnchor.constraint(equalToConstant: sideBorderWidth),
//            
//            leftBorderView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            leftBorderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            leftBorderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//            leftBorderView.widthAnchor.constraint(equalToConstant: sideBorderWidth),
//            
//            topBorderView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            topBorderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            topBorderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            topBorderView.heightAnchor.constraint(equalToConstant: topBorderHeight),
//        ])
//    }
}
