//
//  Utils.swift
//  CountDown
//
//  Created by Steven J. Selcuk on 19.05.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import Foundation
import Cocoa
import IOKit.ps
import IOKit.pwr_mgt
import WebKit
import SwiftUI
import Combine
import Network
import SystemConfiguration
import LaunchAtLogin

extension UserDefaults {
    
    public func optionalInt(forKey defaultName: String) -> Int? {
        let defaults = self
        if let value = defaults.value(forKey: defaultName) {
            return value as? Int
        }
        return nil
    }
    
    public func optionalBool(forKey defaultName: String) -> Bool? {
        let defaults = self
        if let value = defaults.value(forKey: defaultName) {
            return value as? Bool
        }
        return nil
    }
}


class TimeHelper {
    private init() {
    }
    
    static func toTimeString(count: Int) -> String {
        let minutes = count / 60;
        let seconds = count - (minutes * 60)
        var minutesString: String;
        var secondsString: String;
        
        if (minutes < 10) {
            minutesString = "0\(minutes)"
        } else {
            minutesString = "\(minutes)"
        }
        
        if (seconds < 10) {
            secondsString = "0\(seconds)"
        } else {
            secondsString = "\(seconds)"
        }
        
        return minutesString + ":" + secondsString
    }
}

final class SwiftUIWindowForMenuBarApp: NSWindow {
    override var canBecomeMain: Bool { true }
    override var canBecomeKey: Bool { true }
    override var acceptsFirstResponder: Bool { true }
    
    var shouldCloseOnEscapePress = false
    
    convenience init() {
        self.init(
            contentRect: .zero,
            styleMask: [
                .titled,
                .closable,
                .miniaturizable,
                .resizable
            ],
            backing: .buffered,
            defer: true
        )
    }
    
    override func cancelOperation(_ sender: Any?) {
        guard shouldCloseOnEscapePress else {
            return
        }
        
        performClose(self)
    }
    
}
