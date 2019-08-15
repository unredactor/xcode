//
//  UIColor+Helpers.swift
//  Unredactor
//
//  Created by Tyler Gee on 8/15/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import UIKit

// from https://stackoverflow.com/questions/15428422/how-can-i-modify-a-uicolors-hue-brightness-and-saturation
extension UIColor {
    public func adjusted(hueBy hue: CGFloat = 0, saturationBy saturation: CGFloat = 0, brightnessBy brightness: CGFloat = 0) -> UIColor {
        
        var currentHue: CGFloat = 0.0
        var currentSaturation: CGFloat = 0.0
        var currentBrigthness: CGFloat = 0.0
        var currentAlpha: CGFloat = 0.0
        
        if getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrigthness, alpha: &currentAlpha) {
            return UIColor(hue: currentHue + hue,
                           saturation: currentSaturation + saturation,
                           brightness: currentBrigthness + brightness,
                           alpha: currentAlpha)
        } else {
            return self
        }
    }
}
