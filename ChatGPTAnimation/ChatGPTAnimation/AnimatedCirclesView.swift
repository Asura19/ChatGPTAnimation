//
//  AnimatedCirclesView.swift
//  OpenAIUX
//
//  Created by phoenix on 2024/5/29.
//

import UIKit

class AnimatedCirclesView: UIView {
    
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval?
    private var progress: CGFloat = 0.0
    /// Cycle duration
    private let duration: CFTimeInterval
    private let circleRadius: CGFloat
    private let circleCount: Int
    private let maxOffset: CGFloat
    /// Angle per frame
    var rotationSpeed: CGFloat = 0.015
    var minProgress: CGFloat = 0.8
    
    init(
        circleCount: Int = 5,
        maxOffset: CGFloat = 80,
        circleRadius: CGFloat = 97,
        duration: CFTimeInterval = 1.0
    ) {
        self.circleCount = circleCount
        self.maxOffset = maxOffset
        self.circleRadius = circleRadius
        self.duration = duration
        super.init(frame: .zero)
        self.backgroundColor = .clear
        setupDisplayLink()
    }

    override init(frame: CGRect) {
        self.circleCount = 5
        self.maxOffset = 80
        self.circleRadius = 97
        self.duration = 1.0
        super.init(frame: frame)
        self.backgroundColor = .clear
        setupDisplayLink()
    }

    required init?(coder aDecoder: NSCoder) {
        self.circleCount = 5
        self.maxOffset = 80
        self.circleRadius = 97
        self.duration = 1.0
        super.init(coder: aDecoder)
        self.backgroundColor = .clear
        setupDisplayLink()
    }

    deinit {
        displayLink?.invalidate()
    }

    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(_:)))
        displayLink?.add(to: .current, forMode: .default)
    }
    
    var progressArray: [CGFloat] = []
    
    @objc private func handleDisplayLink(_ displayLink: CADisplayLink) {
        if startTime == nil {
            startTime = displayLink.timestamp
        }
        
        
        var elapsedTime = displayLink.timestamp - startTime!
        
        progressArray.removeAll()
        for i in 0..<circleCount {
            let delay: Double = duration / Double(circleCount + 1)
            
            elapsedTime += Double(i) * delay
            elapsedTime = elapsedTime.truncatingRemainder(dividingBy: duration)
            
            NSLog("#### \(elapsedTime)")
            var indexProgress: CGFloat
//            if elapsedTime < duration / 2.0 {
//                indexProgress = (elapsedTime) * 2.0 / duration
//            } else {
//                indexProgress = (elapsedTime) * -2.0 / duration + 2
//            }
            // 线性改为正弦
            // f(x)=0.5*(sin ((2\pi / 2)x- \pi / 2 ) + 1)
            indexProgress = 0.5 * (sin((2 * .pi / duration) * elapsedTime - .pi / 2.0) + 1)
            progressArray.append(indexProgress)
        }
        
        NSLog("~~~ \(progress)")

        // 强制调用 drawRect 来更新视图
        self.setNeedsDisplay()
        
        if rotationSpeed > 0 {
            rotationAngle += rotationSpeed
            self.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }
    }
    
    private var rotationAngle: CGFloat = 0

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let centerX = rect.width / 2
        let centerY = rect.height / 2
        // 最大位移
//        let maxOffset: CGFloat = 40

        for (i, progress) in progressArray.enumerated() {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(circleCount))
            // 将 progress 0 ~ 1 拟合到 minProgress ~ 1
            let ratio = ((1 - minProgress) * progress + minProgress)
            
            let offsetX = maxOffset * ratio * cos(angle)
            let offsetY = maxOffset * ratio * sin(angle)
            let circleCenter = CGPoint(x: centerX + offsetX, y: centerY + offsetY)
            
            context.setFillColor(UIColor.white.cgColor)
            context.addArc(center: circleCenter, radius: circleRadius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            context.fillPath()
        }
    }
}
