//
//  UIScreen+Extension.swift
//  Schedl
//
//  Created by David Medina on 7/23/25.
//

import SwiftUI

extension UIScreen {
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
}
