//
//  UIConfig.swift
//  American Me
//
//  Created by Minh Nguyen on 9/24/20.
//  Copyright © 2020 Minh Nguyen. All rights reserved.
//

import Foundation
import UIKit

enum arrowType {
    case up, down, left, right
}

class AllButton: UIButton {
    func configButton () {
        self.layer.cornerRadius = 10
    }
}

class RoundButton: UIButton {
    func configButton() {
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
    }
}

class BackButton: RoundButton {
    override func configButton() {
        super.configButton()
        guard let image = UIImage(named: Identifier.imageArrowUp) else {
            return
        }
        self.setImage(image.rotate(radians: -(.pi / 2)), for: .normal)
    }
}

class NextButton: RoundButton {
    override func configButton() {
        super.configButton()
        guard let image = UIImage(named: Identifier.imageArrowUp) else {
            return
        }
        self.setImage(image.rotate(radians: (.pi / 2)), for: .normal)
    }
}

class AnswerButton: AllButton {
    
    var direction: arrowType = .up
    
    override func configButton() {
        super.configButton()
        guard let image = UIImage(named: Identifier.imageArrowUp) else {
            return
        }
        self.setImage(image, for: .normal)
        self.direction = .up
    }
    
    func rotateButton() {
        if self.direction == .down {
            guard let image = UIImage(named: Identifier.imageArrowUp) else {
                return
            }
            self.setImage(image, for: .normal)
            self.direction = .up
        }
        if self.direction == .up {
            guard let image = UIImage(named: Identifier.imageArrowUp) else {
                return
            }
            self.setImage(image.rotate(radians: (.pi)), for: .normal)
            self.direction = .down
        }
    }
}

class AllCardView: UIView {
    
    func configCard() {
        self.layer.cornerRadius = 15
    }
}

class AnswerCardView: AllCardView {
    
    var openAnswerCard: Bool = false
    
    override func configCard() {
        super.configCard()
        self.openAnswerCard = false
    }
}


extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
