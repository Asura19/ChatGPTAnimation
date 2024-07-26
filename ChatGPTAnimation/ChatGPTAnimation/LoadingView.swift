//
//  LoadingView.swift
//  OpenAIUX
//
//  Created by phoenix on 2024/5/30.
//

import UIKit

class LoadingView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    private let maskLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayers()
    }
    
    private func setupLayers() {
        // 设置背景颜色为透明
        self.backgroundColor = .clear
        let minSide = min(bounds.width, bounds.height)
        
        // 配置渐变层
        gradientLayer.frame = .init(x: (bounds.width - minSide) / 2, y: (bounds.height - minSide) / 2, width: minSide, height: minSide)
        gradientLayer.type = .conic
        gradientLayer.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.cornerRadius = bounds.width / 2
        
        layer.addSublayer(gradientLayer)
        
        // 创建一个圆环遮罩
        let outerPath = UIBezierPath(roundedRect: gradientLayer.frame, cornerRadius: minSide / 2.0)
        let insetRect = outerPath.bounds.insetBy(dx: minSide / 3, dy: minSide / 3)
        let innerPath = UIBezierPath(ovalIn: insetRect)
        
        outerPath.append(innerPath.reversing())
        maskLayer.path = outerPath.cgPath
        maskLayer.fillRule = .evenOdd
        gradientLayer.mask = maskLayer
        
        let circle = CAShapeLayer()
        let circleWidth = insetRect.width
        let ballPath = UIBezierPath(ovalIn: .init(x: gradientLayer.frame.origin.x, y: (gradientLayer.frame.width - circleWidth) / 2.0, width: circleWidth, height: circleWidth))
        
        circle.path = ballPath.cgPath
        circle.fillColor = UIColor.white.cgColor
        circle.strokeColor = UIColor.clear.cgColor
        circle.lineWidth = 0
        layer.addSublayer(circle)
        
        // 添加旋转动画
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = 2 * CGFloat.pi
        rotationAnimation.duration = 2
        rotationAnimation.repeatCount = .infinity
        self.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
}
