//
//  ContentView.swift
//  CountDown
//
//  Created by Steven J. Selcuk on 19.05.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import SwiftUI
import HotKey
import UserNotifications

let settings = UserDefaults.standard

struct ContentView: View {
    
    // MARK: - Properties
    @State private var currentPage = 0
    @ObservedObject var ThePomoshTimer = PomoshTimer()
    @State var sliderValue: Double = 0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let notificationCenter = UNUserNotificationCenter.current()
    
    
    func refreshFullTime (time: Int) {
        settings.set(time, forKey: "time")
        self.ThePomoshTimer.timeRemaining = UserDefaults.standard.integer(forKey: "time")
    }
    
    init() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    
    
    // MARK: - Main Component
    
    var body: some View {
        
        PagerView(pageCount: 2, currentIndex: $currentPage) {
            ZStack(alignment: .bottomTrailing) {
                HStack(alignment: .bottom, spacing: 1.0) {
                    Button(action: {
                        self.currentPage = 1
                    }) {
                        Text("Settings")
                        
                    }
                    .buttonStyle(PomoshButtonStyle())
                    
                    Button(action: {NSApp.terminate(self)}) {
                        Text("Quit")
                            .font(.custom("Dank Mono Regular", size: 14))
                    }
                    .buttonStyle(PomoshButtonStyle())
                    
                    
                }
                VStack {
                    TimerRing(color1: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), color2: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), width: 300, height: 300, percent: CGFloat(((Float(ThePomoshTimer.fulltime) - Float(ThePomoshTimer.timeRemaining))/Float(ThePomoshTimer.fulltime)) * 100), Timer: ThePomoshTimer)
                        .padding()
                        .scaledToFit()
                        .frame(maxWidth: 600, maxHeight: 600, alignment: .center)
                    
                    Spacer()

                }
                
            }
                
            .onReceive(timer) { time in
                guard self.ThePomoshTimer.isActive else { return }
                if self.ThePomoshTimer.timeRemaining > 0 {
                    
                    self.ThePomoshTimer.timeRemaining -= 1
                    
                    if self.ThePomoshTimer.isBreakActive == true {
                        (NSApp.delegate as! AppDelegate).updateIcon(iconName: String("Break"))
                        (NSApp.delegate as! AppDelegate).updateTitle(newTitle: String(self.ThePomoshTimer.textForPlaybackTime(time: TimeInterval(self.ThePomoshTimer.timeRemaining))))
                    } else {
                        (NSApp.delegate as! AppDelegate).updateIcon(iconName: String("Work"))
                        (NSApp.delegate as! AppDelegate).updateTitle(newTitle: String(self.ThePomoshTimer.textForPlaybackTime(time: TimeInterval(self.ThePomoshTimer.timeRemaining))))
                    }
                    
                }
                
              //  if self.ThePomoshTimer.playSound && self.ThePomoshTimer.timeRemaining == 7 && self.ThePomoshTimer.round > 0 {
              //      NSSound(named: "before")?.play()
              //  }
                if self.ThePomoshTimer.timeRemaining == 1 && self.ThePomoshTimer.round > 0 {
                    
                    if self.ThePomoshTimer.playSound {
                        NSSound(named: "done2")?.play()
                    }
                    self.scheduleAlarmNotification()
                    
                    // Break time or working time switcher 🎛
                    self.ThePomoshTimer.isBreakActive.toggle()
                    
                    if self.ThePomoshTimer.isBreakActive == true {
                        if self.ThePomoshTimer.round == 1 {
                            self.ThePomoshTimer.timeRemaining = 0
                            self.ThePomoshTimer.isBreakActive = false
                        } else {
                            // Adds time for break
                             print("It's break time 😴")
                            // @TODO: We gonna handle this with user defaults
                            self.ThePomoshTimer.timeRemaining = 5
                        }
                        // Removes 1 from total remaining round
                         
                        self.ThePomoshTimer.round -= 1
                        print("🔥Remaining round: \(self.ThePomoshTimer.round)")
                    } else {
                        print("It's working time 💪")
                        self.ThePomoshTimer.timeRemaining = UserDefaults.standard.optionalInt(forKey: "time") ?? 1200
                    }
                    
                } else if self.ThePomoshTimer.timeRemaining == 0 {
                    print("Streak! 🔥 Session has ended.")
                    (NSApp.delegate as! AppDelegate).updateIcon(iconName: String("menubar-icon"))
                    (NSApp.delegate as! AppDelegate).updateTitle(newTitle: String("00:00"))
                    
                    self.ThePomoshTimer.isActive = false
                }
                
            }
            .onAppear {
                
                
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            .contentShape(Rectangle())
            
            VStack {
                Text("Henlo")
                VStack(alignment: .leading, spacing: 5.0) {
                    Slider(value: $sliderValue, in: 0...20)
                    Text("Current slider value: \(sliderValue, specifier: "%.2f")")
                }.padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(lineWidth: 1)
                            .foregroundColor(sliderValue > 10 ? .green : .gray)
                )
            }
        }
        
        
    }
    
    // MARK: - Local Notifications
    
    func scheduleAlarmNotification() {
        let content = UNMutableNotificationContent()
        var bodyString: String  {
            var string = ""
            if self.ThePomoshTimer.isBreakActive == true {
                string = "It's break time"
            } else {
                string = "Now It's work time"
            }
            return string
        }
        content.title = "Time is up"
        content.body = bodyString
        content.sound = UNNotificationSound(named: UNNotificationSoundName("done.wav"))
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let identifier = "localNotification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                self.notificationCenter.add(request) { (error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    
}


