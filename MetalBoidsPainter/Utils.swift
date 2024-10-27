//
//  Utils.swift
//  MetalBoidsPainter
//
//  Created by Andreas Olausson on 2024-10-22.
//
import UIKit


extension UIColor {
    func isApproximatelyEqualToColor(_ otherColor: UIColor, tolerance: CGFloat = 0.1) -> Bool {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        otherColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return abs(r1 - r2) < tolerance && abs(g1 - g2) < tolerance && abs(b1 - b2) < tolerance
    }
}
