//
//  ViewController.swift
//  ChatGPTAnimation
//
//  Created by phoenix on 2024/7/26.
//

import UIKit
import ReerKit

enum Constants {
    static let animationInterval: TimeInterval = 0.02
    static let barAmount = 4
    static let magnitudeLimit: Float = 32
}

class ViewController: UIViewController {
    
    var segmentedControl: UISegmentedControl!
    var switchView: UISwitch!
    
    let audioRecorder = AudioRecorder()
    
    var data: [Float] = Array(repeating: 0, count: Constants.barAmount)
    
    lazy var timer = RETimer(timeInterval: Constants.animationInterval) { [weak self] timer in
        guard let self = self else { return }
//        NSLog("!!!! \(audioRecorder.normalizedValue)")
        ballView.normalizedValue = audioRecorder.normalizedValue
        
        data = AudioProcessing.shared.fftMagnitudes.map {
            min($0, Constants.magnitudeLimit)
        }
        
        var datas = data
        if datas.count == 4 {
            datas.swapAt(1, 3)
        }
//        NSLog("$$$$ \(datas)")
        let updatedValues = datas.map { $0 / 32.0 }
        
        NSLog("#### \(updatedValues)")
        barView.update(heights: updatedValues)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        let items = ["Loading", "Listening", "Speaking", "Thinking"]
        segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segmentedControl.addTarget(
            self,
            action: #selector(segmentedControlValueChanged(_:)),
            for: .valueChanged
        )
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 80)
        ])
        
        switchView = UISwitch()
        switchView.isOn = false
        switchView.isHidden = true
        switchView.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        view.addSubview(switchView)
        switchView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            switchView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            switchView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ])
        
        view.addSubview(loadingView)
        
        view.addSubview(ballView)
        ballView.isHidden = true
        view.addSubview(barView)
        barView.isHidden = true
        
        view.addSubview(animatedCirclesView)
        animatedCirclesView.isHidden = true
        
        view.addSubview(littleThinkingView)
        littleThinkingView.isHidden = true
        
        audioRecorder.record()
        timer.schedule()
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        
        loadingView.isHidden = index != 0
        
        ballView.isHidden = index != 1
        barView.isHidden = index != 2
        switchView.isHidden = index != 2
        
        animatedCirclesView.isHidden = index != 3
        littleThinkingView.isHidden = index != 3
        
        if index == 3 {
            audioRecorder.stop()
            AudioProcessing.shared.stop()
            loadingVibration()
        } else {
            stopVibration()
            audioRecorder.record()
            AudioProcessing.shared.start()
        }
    }
    var vibrationTimer: Timer?
    func loadingVibration() {
        asyncOnMainQueue {
            self.vibrationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                Vibrator.occur(.success)
            }
            RunLoop.main.add(self.vibrationTimer!, forMode: .common)
        }
    }
    func stopVibration() {
        vibrationTimer?.invalidate()
        vibrationTimer = nil
    }
    
    @objc
    func switchValueChanged() {
        barView.alignment = switchView.isOn ? .center : .bottom
    }
    
    @objc
    func ballLongPressed(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            ballView.startHolding()
        case .ended, .cancelled:
            ballView.endHolding()
        default:
            break
        }
    }
    
    lazy var ballView: BallView = {
        let ball = BallView(frame: .init(x: 0, y: 120, width: view.bounds.width, height: view.bounds.height - 200))
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(ballLongPressed(_:)))
        ball.addGestureRecognizer(gesture)
        return ball
    }()
    lazy var barView: BarView = {
        let bar = BarView(barAmount: 4, barWidth: 80, barSpacing: 5)
        bar.frame = .init(x: 0, y: 120, width: view.bounds.width, height: view.bounds.height - 200)
        bar.setupBars()
        return bar
    }()
    
    lazy var animatedCirclesView: AnimatedCirclesView = {
        let animatedView = AnimatedCirclesView(frame: CGRect(x: 0, y: 200, width: view.bounds.width, height: 360))
        return animatedView
    }()
    
    lazy var littleThinkingView: AnimatedCirclesView = {
        let animatedView = AnimatedCirclesView(circleCount: 4, maxOffset: 8, circleRadius: 19, duration: 0.8)
        animatedView.rotationSpeed = 0.006
        animatedView.minProgress = 0.5
        animatedView.frame = .init(x: 20, y: 200 + 300, width: 70, height: 70)
        return animatedView
    }()
    
    lazy var loadingView: LoadingView = {
        let loading = LoadingView(frame: CGRect(x: 40, y: 200, width: view.bounds.width - 80, height: view.bounds.width - 80))
        return loading
    }()
}
