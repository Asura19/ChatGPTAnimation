//
//  BarView.swift
//  OpenAIUX
//
//  Created by phoenix on 2024/5/27.
//

import UIKit
import ReerKit

class BarView: UIView {
    
    enum Alignment {
        case center
        case bottom
    }
    
    var bars: [CAShapeLayer] = []
    
    let barAmount: Int
    var alignment: Alignment
    let barWidth: CGFloat
    let barSpacing: CGFloat
    
    init(barAmount: Int, alignment: Alignment = .bottom, barWidth: CGFloat, barSpacing: CGFloat) {
        self.barAmount = barAmount
        self.alignment = alignment
        self.barWidth = barWidth
        self.barSpacing = barSpacing
        super.init(frame: .zero)
    }
      
    required init?(coder: NSCoder) {
        self.barAmount = 4
        self.alignment = .bottom
        self.barWidth = 80
        self.barSpacing = 5
        super.init(coder: coder)
    }
    
    func setupBars() {
        let barWidth: CGFloat = barWidth
        let barSpacing: CGFloat = barSpacing
        let totalWidth = CGFloat(barAmount) * (barWidth + barSpacing) - barSpacing
        
        for i in 0..<barAmount {
            let bar = CAShapeLayer()
            bar.frame = CGRect(
                x: bounds.midX - totalWidth / 2 + CGFloat(i) * (barWidth + barSpacing),
                y: bounds.midY - barWidth / 2,
                width: barWidth,
                height: barWidth
            )
            bar.backgroundColor = UIColor.white.cgColor
            bar.cornerRadius = barWidth / 2
            bar.cornerCurve = .continuous
            layer.addSublayer(bar)
            bars.append(bar)
        }
    }
    
    /// 0 ~ 1
    func update(heights: [Float]) {
        guard heights.count == barAmount else { return }
        
        for (i, bar) in self.bars.enumerated() {
            let value: Float = min(1, heights[i])
            let height = barWidth * CGFloat(value + 1)
            bar.frame.size.height = height
            switch self.alignment {
            case .bottom:
                bar.frame.origin.y = self.bounds.midY - height
            case .center:
                bar.frame.origin.y = self.bounds.midY - height / 2
            }
        }
    }
    
    func shrink(animationDuration: TimeInterval? = nil, completion: (() -> Void)? = nil) {
        let barWidth: CGFloat = barWidth
        let barSpacing: CGFloat = barSpacing
        let totalWidth = CGFloat(barAmount) * (barWidth + barSpacing) - barSpacing
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setCompletionBlock(completion)
        
        for (i, bar) in self.bars.enumerated() {
            bar.removeAllAnimations()
            
            if let animationDuration {
                let fromX = bounds.midX - totalWidth / 2 + CGFloat(i) * (barWidth + barSpacing) + barWidth / 2
                let animation = CABasicAnimation(keyPath: "position.x")
                animation.fromValue = fromX
                animation.toValue = frame.midX
                animation.duration = animationDuration
                animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                animation.fillMode = .forwards
                animation.isRemovedOnCompletion = false
                
                bar.add(animation, forKey: "positionAnimation")
            }
            bar.position.x = frame.midX
        }
        
        CATransaction.commit()
    }

    func expand(animationDuration: TimeInterval? = nil, completion: (() -> Void)? = nil) {
        let barWidth: CGFloat = barWidth
        let barSpacing: CGFloat = barSpacing
        let totalWidth = CGFloat(barAmount) * (barWidth + barSpacing) - barSpacing
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setCompletionBlock(completion)
        
        for (i, bar) in self.bars.enumerated() {
            bar.removeAllAnimations()
            
            let newPointX = bounds.midX - totalWidth / 2 + CGFloat(i) * (barWidth + barSpacing) + barWidth / 2
            if let animationDuration {
                let animation = CABasicAnimation(keyPath: "position.x")
                animation.fromValue = bar.position.x
                animation.toValue = newPointX
                animation.duration = animationDuration
                animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                animation.fillMode = .forwards
                animation.isRemovedOnCompletion = false
                
                bar.add(animation, forKey: "positionAnimation")
            }
            bar.position.x = newPointX
        }
        
        CATransaction.commit()
    }
}
