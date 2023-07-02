//
//  ContentView.swift
//  ExoSpeed
//
//  Created by Terence Grover on 02/07/2023.
//

import SwiftUI
import CoreMotion
import AVFoundation

struct ContentView: View {
    @StateObject var exoSpeedViewModel = ExoSpeedViewModel()
    
    var body: some View {
        VStack {
            TimeView(exoSpeedViewModel: exoSpeedViewModel)
            PullUpInputView(exoSpeedViewModel: exoSpeedViewModel)
            TrackingButtonsView(exoSpeedViewModel: exoSpeedViewModel)
            ResultsView(exoSpeedViewModel: exoSpeedViewModel)
        }
        .padding()
        .onReceive(exoSpeedViewModel.timer) { time in
            exoSpeedViewModel.lastTimerTick = time
        }
    }
}

struct TimeView: View {
    @ObservedObject var exoSpeedViewModel: ExoSpeedViewModel
    
    var body: some View {
        if let startTime = exoSpeedViewModel.startTime {
            let timeInterval = Date().timeIntervalSince(startTime)
            let timeString = exoSpeedViewModel.timeFormatter.string(from: timeInterval) ?? "00:00"
            Text("Time: \(timeString)")
        } else {
            Text("Time: 00:00")
        }
    }
}

struct PullUpInputView: View {
    @ObservedObject var exoSpeedViewModel: ExoSpeedViewModel
    
    var body: some View {
        TextField("Enter number of pull-ups", text: $exoSpeedViewModel.pullUpCount)
            .keyboardType(.numberPad)
            .padding()
    }
}

struct TrackingButtonsView: View {
    @ObservedObject var exoSpeedViewModel: ExoSpeedViewModel
    
    var body: some View {
        Button(action: {
            exoSpeedViewModel.startTracking()
        }) {
            Text("Start Tracking")
        }
        .disabled(exoSpeedViewModel.isTracking)

        Button(action: {
            exoSpeedViewModel.stopTracking()
        }) {
            Text("Stop Tracking")
        }
        .disabled(!exoSpeedViewModel.isTracking)
    }
}

struct ResultsView: View {
    @ObservedObject var exoSpeedViewModel: ExoSpeedViewModel
    
    var body: some View {
        Text("Time to complete: \(String(format: "%.2f", exoSpeedViewModel.timeToComplete)) seconds")
        Text("Average time per pull-up: \(String(format: "%.2f", exoSpeedViewModel.averageTimePerPullup)) seconds")
        Text("Average speed per pull-up: \(String(format: "%.2f", exoSpeedViewModel.averageSpeedPerPullup)) m/s")
        Text("Max speed per pull-up: \(String(format: "%.2f", exoSpeedViewModel.maxSpeedPerPullup)) m/s")
    }
}

