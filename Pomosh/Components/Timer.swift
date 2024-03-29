//
//  Timer.swift
//  Pomosh
//
//  Created by Steven J. Selcuk on 28.05.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import Foundation
import SwiftUI 
class PomoshTimer: ObservableObject {
    // MARK: - Default Variables

    @Published var fulltime = UserDefaults.standard.optionalInt(forKey: "time") ?? 1200
    @Published var fullBreakTime = UserDefaults.standard.optionalInt(forKey: "fullBreakTime") ?? 600
    @Published var fullround = UserDefaults.standard.optionalInt(forKey: "fullround") ?? 5 {
        didSet {
            settings.set(fullround, forKey: "fullround")
        }
    }

    // MARK: - Active Variables

    @Published var timeRemaining = 0
    @Published var breakTime = 0
    @Published var round = 0

    // MARK: - Mechanic Variables

    @Published var isActive = true
    @Published var isBreakActive = false

    // MARK: - Settings

    @Published var playSound: Bool = UserDefaults.standard.optionalBool(forKey: "playsound") ?? true {
        didSet {
            settings.set(playSound, forKey: "playsound")
        }
    }

    @Published var showNotifications: Bool = UserDefaults.standard.optionalBool(forKey: "shownotifications") ?? true {
        didSet {
            settings.set(showNotifications, forKey: "shownotifications")
        }
    }
    
    @Published var showMenubarTimer: Bool = UserDefaults.standard.optionalBool(forKey: "showMenubarTimer") ?? true {
        didSet {
            settings.set(showMenubarTimer, forKey: "showMenubarTimer")
            (NSApp.delegate as! AppDelegate).updateIcon(iconName: String("menubar-icon"))
            (NSApp.delegate as! AppDelegate).updateTitle(newTitle: String(""))
        }
    }

    // MARK: - Initializer

    init() {
        // Operate registered shortcut Control + Command + P is toggles timer
        //toggleTimerHotkey.keyDownHandler = { [weak self] in
        //    self!.isActive.toggle()
        //}
    }

    // MARK: - Int to Human Readable Time String

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
