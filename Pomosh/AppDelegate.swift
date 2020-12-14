//
//  AppDelegate.swift
//  Pomosh
//
//  Created by Steven J. Selcuk on 28.05.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import Cocoa
import AppKit
import SwiftUI
import UserNotifications
import HotKey

let toggleTimerHotkey = HotKey(key: .p, modifiers: [.command, .control])
// let pauseHotkey = HotKey(key: .s, modifiers: [.command, .control])


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var popover: NSPopover!
    var statusBarItem: NSStatusItem! = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength + 70))
    @ObservedObject var PoTimer = PomoshTimer()
    
    // Init default variables for first launch
    let userDefaultsDefaults = [
        "time" : 1200,
        "fullBreakTime": 600,
        "fullround": 5,
        "playsound": true,
        "shownotifications": true ] as [String : Any]
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //  UserDefaults.standard.register(defaults: userDefaultsDefaults)
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()
        
        // Create the popover
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        // It will override users mode preferences: Now it is dark.
        // popover.appearance = NSAppearance(named: .vibrantDark)
        
        self.popover = popover
        self.popover.contentViewController?.view.window?.becomeKey()
        
        
        if let button = self.statusBarItem.button {
            button.image = NSImage(named: "menubar-icon")
            button.imagePosition = NSControl.ImagePosition.imageLeft
            button.title = String(PoTimer.textForPlaybackTime(time: TimeInterval(PoTimer.timeRemaining)))
            button.font = NSFont.monospacedDigitSystemFont(ofSize: 14.0, weight: NSFont.Weight.bold)
            button.action = #selector(togglePopover(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    func updateTitle(newTitle : String) {
        self.statusBarItem.button?.title = newTitle
    }
    
    func updateIcon(iconName : String) {
        self.statusBarItem.button?.image = NSImage(named: iconName)
    }
    
    
    @objc func togglePopover(_ sender: AnyObject?) {
        let event = NSApp.currentEvent!
        
        
        if event.type == NSEvent.EventType.leftMouseUp
        {
            
            if let sbutton = self.statusBarItem.button {
                if self.popover.isShown {
                    self.popover.performClose(sender)
                } else {
                    self.popover.show(relativeTo: sbutton.bounds, of: sbutton, preferredEdge: NSRectEdge.minY)
                }
            }
            
        } else if event.type == NSEvent.EventType.rightMouseUp{
            
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "Pomosh v1.0.1", action: nil, keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(withTitle: "About", action: #selector(about), keyEquivalent: "")
            menu.addItem(withTitle: "Bug Report", action: #selector(issues), keyEquivalent: "")
            menu.addItem(NSMenuItem.separator())
            menu.addItem(withTitle: "Quit App", action: #selector(quit), keyEquivalent: "q")
            
            
            
            self.statusBarItem.menu = menu
            self.statusBarItem.button?.performClick(nil)
            self.statusBarItem.menu = nil
        }
        
    }
    
    @objc func quit()
    {
        NSApp.terminate(self)
    }
    
    
    @objc func about()
    {
        let url = URL(string: "https://pomosh.netlify.app/")!
        NSWorkspace.shared.open(url)
    }
    
    @objc func issues()
    {
        let url = URL(string: "https://github.com/stevenselcuk/Pomosh-macOS/issues")!
        NSWorkspace.shared.open(url)
    }
    
    
}
