//
//  UINavigationController+Extension.swift
//  Schedl
//
//  Created by David Medina on 6/22/25.
//

import UIKit

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
        interactivePopGestureRecognizer?.addTarget(self, action: #selector(handlePopGesture(_:)))
    }

    @objc private func handlePopGesture(_ gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .began:
            print("Swipe-back began")
        case .changed:
            // Optional: Track progress
            break
        case .ended:
            print("Swipe-back finished successfully")
        case .cancelled, .failed:
            print("Swipe-back was cancelled or failed")
        default:
            break
        }
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1 && presentedViewController == nil
    }
    

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
