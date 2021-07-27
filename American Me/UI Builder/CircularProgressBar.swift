//
//  CircularProgressBar.swift
//  American Me
//
//  Created by Minh Nguyen on 10/12/20.
//  Copyright © 2020 Minh Nguyen. All rights reserved.
//

import Foundation
import UIKit

class CircularProgressBar: UIView {
    private var color: UIColor = UIColor(red: 0.549, green: 0.843, blue: 0.565, alpha: 1) {
        didSet { setNeedsDisplay() }
    }
    private var ringWidth: CGFloat = 7

    private var progress: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }

    private var progressLayer = CAShapeLayer()
    private var backgroundMask = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    private func setupLayers() {
        backgroundMask.lineWidth = ringWidth
        backgroundMask.fillColor = nil
        backgroundMask.strokeColor = UIColor.black.cgColor
        layer.mask = backgroundMask

        progressLayer.lineWidth = ringWidth
        progressLayer.fillColor = nil

        layer.addSublayer(progressLayer)
        layer.transform = CATransform3DMakeRotation(CGFloat(90 * Double.pi / 180), 0, 0, -1)
        
    }

    override func draw(_ rect: CGRect) {
        let circlePath = UIBezierPath(ovalIn: rect.insetBy(dx: ringWidth / 2, dy: ringWidth / 2))
        backgroundMask.path = circlePath.cgPath

        progressLayer.path = circlePath.cgPath
        progressLayer.lineCap = .butt
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = progress
        progressLayer.strokeColor = color.cgColor

    }
    
    func updateProgress(currentProgress: Int, maxProgress: Int){
        self.progress = CGFloat(Double(currentProgress) / Double(maxProgress))
    }
}
