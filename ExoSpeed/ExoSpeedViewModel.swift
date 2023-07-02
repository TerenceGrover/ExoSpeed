//
//  ExoSpeedViewModel.swift
//  ExoSpeed
//
//  Created by Terence Grover on 02/07/2023.
//

import Foundation
import CoreMotion
import AVFoundation

class ExoSpeedViewModel: ObservableObject {
    @Published var pullUpCount = ""
    private var motionManager = CMMotionManager()
    @Published var isTracking = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Published var startTime: Date?
    private var lastUpdateTime: Date?
    private var speedX: Double = 0
    private var speedY: Double = 0
    private var speedZ: Double = 0
    private var displacement: Double = 0.0
    private var maxSpeed: Double = 0
    private var sumSpeed: Double = 0
    private var countSpeed: Int = 0

    @Published var lastTimerTick = Date()
    @Published var timeToComplete: Double = 0
    @Published var averageTimePerPullup: Double = 0
    @Published var averageSpeedPerPullup: Double = 0
    @Published var maxSpeedPerPullup: Double = 0

    private var player: AVAudioPlayer?
    
    let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional // Use ":" as separator
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    func startTracking() {
        if self.motionManager.isAccelerometerAvailable {
            self.timeToComplete = 0
            self.averageTimePerPullup = 0
            self.averageSpeedPerPullup = 0
            self.maxSpeedPerPullup = 0
            self.playSound()
            self.motionManager.accelerometerUpdateInterval = 0.01
            self.motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
                if let acceleration = data?.acceleration {
                    let currentTime = Date()
                    if let lastUpdateTime = self.lastUpdateTime {
                        let timeElapsed = currentTime.timeIntervalSince(lastUpdateTime)

                        // Calculate speed for each direction
                        self.speedX += acceleration.x * timeElapsed
                        self.speedY += acceleration.y * timeElapsed
                        self.speedZ += acceleration.z * timeElapsed

                        // Calculate displacement
                        let displacementX = 0.5 * acceleration.x * pow(timeElapsed, 2)
                        let displacementY = 0.5 * acceleration.y * pow(timeElapsed, 2)
                        let displacementZ = 0.5 * acceleration.z * pow(timeElapsed, 2)

                        let currentDisplacement = sqrt(pow(displacementX, 2) + pow(displacementY, 2) + pow(displacementZ, 2))

                        self.displacement += currentDisplacement

                        // Update maxSpeed
                        self.maxSpeed = max(self.maxSpeed, currentDisplacement/timeElapsed)

                        // Update sumSpeed and countSpeed for average speed calculation
                        self.sumSpeed += currentDisplacement/timeElapsed
                        self.countSpeed += 1
                    }

                    self.lastUpdateTime = currentTime
                }
            }
        }

        self.isTracking = true
        self.startTime = Date()
    }
    
    func stopTracking() {
        self.motionManager.stopAccelerometerUpdates()
        self.playSound()
        self.isTracking = false

        var totalTime = 0.0
        if let lastUpdate = self.lastUpdateTime {
            totalTime = Date().timeIntervalSince(lastUpdate)
        }
        self.timeToComplete = totalTime
        if let pullUpsCompleted = Int(self.pullUpCount), pullUpsCompleted != 0 {
            self.averageTimePerPullup = totalTime / Double(pullUpsCompleted)
            self.averageSpeedPerPullup = self.sumSpeed / Double(self.countSpeed)
        } else {
            self.averageTimePerPullup = 0
            self.averageSpeedPerPullup = 0
        }
        self.maxSpeedPerPullup = self.maxSpeed
        
        // Clear variables
        self.lastUpdateTime = nil
        self.speedX = 0
        self.speedY = 0
        self.speedZ = 0
        self.displacement = 0.0
        self.maxSpeed = 0
        self.sumSpeed = 0
        self.countSpeed = 0

        // Clear results
        self.startTime = nil
    }
    
    private func playSound() {
        guard let url = Bundle.main.url(forResource: "Chime", withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}
