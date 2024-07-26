//
//  BallView.swift
//  OpenAIUX
//
//  Created by phoenix on 2024/5/27.
//

import UIKit
import ReerKit

class BallView: UIView {
    
    enum State {
        // 常规
        case normal
        // 常规到长按状态的动画中, 要加上圆弧转圈
        case toHolding
        // 长按中
        case holding
        // 长按到常规状态的动画中
        case toNormal
    }
    
    private var state: State = .normal
    
    private var radius: CGFloat = 0.0
    private let defaultRadius: CGFloat = 140.0
    private let maxRadius: CGFloat = 180
    
    private let changeStateDuration: Double = 0.2
    
    private let shapeLayer = CAShapeLayer()
    
    private let ringWidth: CGFloat = 30
    private var holdingDefaultRadius: CGFloat {
        return defaultRadius - ringWidth
    }
    
    private var holdingMaxRadius: CGFloat {
        return maxRadius - ringWidth
    }
    
    private lazy var ringLayer: CAShapeLayer = {
        let ringLayer = CAShapeLayer()
        let arcPath = createRingPath(for: holdingDefaultRadius - ringWidth / 2)
        
        ringLayer.path = arcPath.cgPath
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.strokeColor = UIColor.white.cgColor
        ringLayer.lineWidth = ringWidth
        ringLayer.lineCap = .round
        return ringLayer
    }()
    
    var normalizedValue: Float = 0 {
        didSet {
            switch state {
            case .normal:
                let scaledRadius = CGFloat(normalizedValue) * (maxRadius - defaultRadius) + defaultRadius
                radius = min(maxRadius, scaledRadius)
                animateRadiusChange()
            case .toHolding:
                break
            case .holding:
                
//                let scaledRadius = CGFloat(normalizedValue) * (holdingMaxRadius - holdingDefaultRadius) + holdingDefaultRadius
//                radius = min(holdingMaxRadius, scaledRadius)
//                animateRadiusChangeWhenHolding()
                break
            case .toNormal:
                break
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }
    
    private func setupLayer() {
        shapeLayer.fillColor = UIColor.white.cgColor
        layer.addSublayer(shapeLayer)
        
        ringLayer.isHidden = true
        layer.addSublayer(ringLayer)
    }
    
    private func animateRadiusChange() {
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = Constants.animationInterval
        animation.fromValue = shapeLayer.path
        animation.toValue = createPath(for: radius).cgPath
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        shapeLayer.add(animation, forKey: "path")
        
        shapeLayer.path = createPath(for: radius).cgPath
        
        let colorFactor = calculateColor(radius: radius, default: defaultRadius, max: maxRadius) / 255
                let targetColor = UIColor(red: colorFactor, green: colorFactor, blue: colorFactor, alpha: 1)
        shapeLayer.fillColor = targetColor.cgColor
    }
    
    private func animateRadiusChangeWhenHolding() {
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = Constants.animationInterval
        animation.fromValue = shapeLayer.path
        let toPath = createPath(for: radius).cgPath
        animation.toValue = toPath
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        shapeLayer.add(animation, forKey: "path")
        shapeLayer.path = toPath
        
        
        let ringAnimation = CABasicAnimation(keyPath: "path")
        ringAnimation.duration = Constants.animationInterval
        ringAnimation.fromValue = ringLayer.path
        let ringToPath = createRingPath(for: radius + 5 + ringWidth / 2.0).cgPath
        ringAnimation.toValue = ringToPath
        ringAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        ringLayer.add(ringAnimation, forKey: "path")
        ringLayer.path = ringToPath
        
        let colorFactor = calculateColor(radius: radius, default: holdingDefaultRadius, max: holdingMaxRadius) / 255
                let targetColor = UIColor(red: colorFactor, green: colorFactor, blue: colorFactor, alpha: 1)
        shapeLayer.fillColor = targetColor.cgColor
        ringLayer.fillColor = targetColor.cgColor
    }
    
    func calculateColor(radius: CGFloat, default: CGFloat, max: CGFloat) -> CGFloat {
        let numerator = 200 * (radius - `default`) - 255 * (radius - max)
        let denominator = (radius - `default`) - (radius - max)
        return numerator / denominator
    }
    
    private func createPath(for radius: CGFloat) -> UIBezierPath {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        return UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
    }
    
    private func createRingPath(for radius: CGFloat, endAngle: CGFloat = 2 * .pi * 0.95) -> UIBezierPath {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let startAngle: CGFloat = 0
        return UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
    }
    
    
    func startHolding() {
        state = .toHolding
        
        // 先把圆变小
        radius = holdingDefaultRadius
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = changeStateDuration
        animation.fromValue = shapeLayer.path
        animation.toValue = createPath(for: radius).cgPath
        animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        shapeLayer.add(animation, forKey: "path")
        shapeLayer.path = createPath(for: radius).cgPath
        // 把颜色改为纯白
        shapeLayer.fillColor = UIColor.white.cgColor
        
        self.ringLayer.isHidden = false
        let ringAnimation = CABasicAnimation(keyPath: "path")
        ringAnimation.duration = self.changeStateDuration
        ringAnimation.fromValue = self.ringLayer.path
        let toPath = self.createRingPath(for: self.holdingDefaultRadius + 5 + self.ringWidth / 2).cgPath
        ringAnimation.toValue = toPath
        ringAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        self.ringLayer.add(ringAnimation, forKey: "path")
        self.ringLayer.path = toPath
        
        // 添加旋转动画
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = 2 * CGFloat.pi
        rotationAnimation.duration = 4
        rotationAnimation.repeatCount = .infinity
        self.layer.add(rotationAnimation, forKey: "rotationAnimation")
        
        
        delay(changeStateDuration) {
            self.state = .holding
        }
    }
    
    func endHolding() {
        self.state = .toNormal

        ringRollback()
        observeDeinit(for: displayLink) {
            print("~~~~ displaylink deinit")
            
            let ringAnimation = CABasicAnimation(keyPath: "path")
            ringAnimation.duration = self.changeStateDuration
            ringAnimation.fromValue = self.ringLayer.path
            let toPath = self.createRingPath(for: self.holdingDefaultRadius - self.ringWidth / 2, endAngle: 2 * .pi * 0.02).cgPath
            ringAnimation.toValue = toPath
            ringAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.ringLayer.add(ringAnimation, forKey: "path")
            self.ringLayer.path = toPath
            
            delay(self.changeStateDuration) {
                self.ringLayer.isHidden = true
                self.state = .normal
            }
        }
        

    }
    
    private var displayLink: CADisplayLink?
    
    func ringRollback() {
        displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(_:)))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    var startTime: CFTimeInterval?
    
    @objc
    private func handleDisplayLink(_ displayLink: CADisplayLink) {
        if startTime == nil {
            startTime = displayLink.timestamp
        }
        
        let elapsedTime = displayLink.timestamp - startTime!
        
        let endAngleStart = 2 * .pi * 0.95
        let endAngleEnd = 2 * .pi * 0.02
        let duration: CGFloat = 0.5
        var angle = (endAngleEnd - endAngleStart) * elapsedTime / duration + endAngleStart
        if angle < endAngleEnd {
            angle = endAngleEnd
        }
        print("~~~~ \(angle)")
        
        // + 5是因为有环境噪音
        let animatedRadius = (defaultRadius + 5 - holdingDefaultRadius) * elapsedTime / duration + holdingDefaultRadius
        let circleAnimation = CABasicAnimation(keyPath: "path")
        circleAnimation.duration = changeStateDuration
        circleAnimation.fromValue = shapeLayer.path
        let path = createPath(for: animatedRadius).cgPath
        circleAnimation.toValue = path
        circleAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        shapeLayer.add(circleAnimation, forKey: "path")
        shapeLayer.path = path
        
        if angle < 0.8 {
            if tempRadius == nil {
                tempRadius = animatedRadius
            }
            tempRadius! -= 5
            let animation = CABasicAnimation(keyPath: "path")
            animation.duration = self.changeStateDuration
            animation.fromValue = self.ringLayer.path
            let toPath = self.createRingPath(for: tempRadius! + 5 + self.ringWidth / 2, endAngle: angle).cgPath
            animation.toValue = toPath
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            self.ringLayer.add(animation, forKey: "path")
            self.ringLayer.path = toPath
        } else {
            let animation = CABasicAnimation(keyPath: "path")
            animation.duration = self.changeStateDuration
            animation.fromValue = self.ringLayer.path
            let toPath = self.createRingPath(for: animatedRadius + 5 + self.ringWidth / 2, endAngle: angle).cgPath
            animation.toValue = toPath
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            self.ringLayer.add(animation, forKey: "path")
            self.ringLayer.path = toPath
        }
        
        
        
        if angle == endAngleEnd {
            displayLink.invalidate()
            displayLink.remove(from: .current, forMode: .common)
            startTime = nil
            self.displayLink = nil
            tempRadius = nil
        }
    }
    
    var tempRadius: CGFloat?
}
