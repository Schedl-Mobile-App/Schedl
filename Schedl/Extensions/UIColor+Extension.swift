//
//  UIColor+Extension.swift
//  Schedl
//
//  Created by David Medina on 10/17/25.
//

import UIKit

extension UIColor {
    func withBrightnessAdjusted(by factor: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        guard getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return self
        }

        let newBrightness = min(max(brightness * factor, 0), 1)

        return UIColor(
            hue: hue,
            saturation: saturation,
            brightness: newBrightness,
            alpha: alpha
        )
    }
}
