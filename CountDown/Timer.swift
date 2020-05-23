//
//  Timer.swift
//  CountDown
//
//  Created by Steven J. Selcuk on 20.05.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import Foundation


class PomoshTimer: ObservableObject {
    
    
    @Published var fulltime = UserDefaults.standard.integer(forKey: "time")
    @Published var breakTime = UserDefaults.standard.optionalInt(forKey: "breaktime") ?? 600
    @Published var timeRemaining = 0
    @Published var fullround = UserDefaults.standard.optionalInt(forKey: "fullround") ?? 5
    @Published var round = 0
    @Published var isActive = true
    @Published var isBreakActive = false
    @Published var playSound = UserDefaults.standard.optionalBool(forKey: "playsound") ?? true

    

    
    
    // MARK: - Initializer
    init() {

    }
    
    func textForPlaybackTime(time: TimeInterval) -> String {
        if !time.isNormal {
            return "00:00"
        }
        let hours = Int(floor(time / 3600))
        let minutes = Int(floor((time / 60).truncatingRemainder(dividingBy: 60)))
        let seconds = Int(floor(time.truncatingRemainder(dividingBy: 60)))
        let minutesAndSeconds = NSString(format: "%02d:%02d", minutes, seconds) as String
        if hours > 0 {
            return NSString(format: "%02d:%@", hours, minutesAndSeconds) as String
        } else {
            return minutesAndSeconds
        }
    }

    
}
