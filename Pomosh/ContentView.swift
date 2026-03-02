//
//  ContentView.swift
//  Pomosh
//
//  Created by Steven J. Selcuk on 28.05.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

// import HotKey
import SwiftUI
import SwiftData
import UserNotifications

let settings = UserDefaults.standard

struct ContentView: View {
    @State private var currentPage = 0
    @State private var runnedRounds = 0
    @State private var currentTaskName: String = ""
    @State private var activeTask: PomodoroTask? = nil
    @ObservedObject var ThePomoshTimer = PomoshTimer.shared
    @ObservedObject var themeManager = ThemeManager.shared
    @ObservedObject var ambientManager = AmbientSoundManager.shared
    @Environment(\.modelContext) private var modelContext

    let timer = Timer.publish(every: 1, tolerance: 1, on: .main, in: .common)
        .autoconnect()
    let notificationCenter = UNUserNotificationCenter.current()

    init() {
        if ThePomoshTimer.showNotifications {
            notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                if granted {
                    settings.set(true, forKey: "didNotificationsAllowed")
                } else {
                    settings.set(false, forKey: "didNotificationsAllowed")
                }
            }
        }
    }

    // MARK: - Main Component

    var body: some View {
        PagerView(pageCount: 4, currentIndex: $currentPage) {
            ZStack(alignment: .bottom) {
                HStack(alignment: .bottom, spacing: 5.0) {
                    Button(action: {
                        if self.ThePomoshTimer.round > 0 {
                            self.ThePomoshTimer.round -= 1
                            self.runnedRounds += 1
                            self.ThePomoshTimer.fulltime = UserDefaults.standard.optionalInt(forKey: "time") ?? 1200
                            self.ThePomoshTimer.timeRemaining = UserDefaults.standard.optionalInt(forKey: "time") ?? 1200
                        } else {
                            (NSApp.delegate as! AppDelegate).updateIcon(iconName: String("menubar-icon"))
                            (NSApp.delegate as! AppDelegate).updateTitle(newTitle: String("00:00"))
                        }

                        self.ThePomoshTimer.isActive = false

                    }) {
                        Image("skip")
                            .antialiased(true)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 28, maxHeight: 28, alignment: .center)
                            .overlay(Tooltip(tooltip: "Skip this round"))
                    }

                    .buttonStyle(PomoshButtonStyle())
                    .padding(.bottom, 0)

                    Spacer()

                    Button(action: {
                        self.ThePomoshTimer.fulltime = UserDefaults.standard.optionalInt(forKey: "time") ?? 1200
                        self.ThePomoshTimer.timeRemaining = UserDefaults.standard.optionalInt(forKey: "time") ?? 1200
                        self.ThePomoshTimer.isActive = false
                    }) {
                        Image("reload")
                            .antialiased(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 28, maxHeight: 28, alignment: .center)
                            .overlay(Tooltip(tooltip: "Reload this round"))
                    }

                    .buttonStyle(PomoshButtonStyle())
                    .padding(.bottom, 0)
                }
                .offset(x: 0, y: -340)

                HStack(alignment: .bottom, spacing: 5.0) {
                    Button(action: {
                        self.currentPage = 1
                        if self.ThePomoshTimer.playSound {
                            NSSound(named: "touch")?.play()
                        }
                    }) {
                        Image("Settings")
                            .antialiased(true)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 28, maxHeight: 28, alignment: .center)
                            .overlay(Tooltip(tooltip: "Settings"))
                    }
                    .buttonStyle(PomoshButtonStyle())
                    .padding(.bottom, 10)

                    Button(action: {
                        self.currentPage = 2
                        if self.ThePomoshTimer.playSound {
                            NSSound(named: "touch")?.play()
                        }
                    }) {
                        Image(systemName: "chart.bar.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 22, maxHeight: 22, alignment: .center)
                            .foregroundColor(themeManager.currentTheme.accentColor)
                            .overlay(Tooltip(tooltip: "Stats"))
                    }
                    .buttonStyle(PomoshButtonStyle())
                    .padding(.bottom, 10)

                    Button(action: {
                        self.currentPage = 3
                        if self.ThePomoshTimer.playSound {
                            NSSound(named: "touch")?.play()
                        }
                    }) {
                        Image(systemName: "checklist")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 22, maxHeight: 22, alignment: .center)
                            .foregroundColor(themeManager.currentTheme.accentColor)
                            .overlay(Tooltip(tooltip: "Tasks"))
                    }
                    .buttonStyle(PomoshButtonStyle())
                    .padding(.bottom, 10)

                    Spacer()

                    Button(action: { NSApp.terminate(self) }) {
                        Image("Quit")
                            .antialiased(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 28, maxHeight: 28, alignment: .center)
                            .overlay(Tooltip(tooltip: "Quit App"))
                    }

                    .buttonStyle(PomoshButtonStyle())
                    .padding(.bottom, 10)
                }
                VStack {
                    TimerRing(width: 300, height: 300, percent: CGFloat(((Float(ThePomoshTimer.fulltime) - Float(ThePomoshTimer.timeRemaining)) / Float(ThePomoshTimer.fulltime)) * 100), Timer: ThePomoshTimer, taskName: $currentTaskName, currentRound: self.runnedRounds)
                        .padding()
                        .scaledToFit()
                        .frame(maxWidth: 600, maxHeight: 600, alignment: .center)

                    Spacer()
                }
            }
            .onAppear {
                self.notificationCenter.removeAllDeliveredNotifications()
            }
            .onReceive(timer) { _ in
                guard self.ThePomoshTimer.isActive else { return }
                if self.ThePomoshTimer.timeRemaining > 0 {
                    self.ThePomoshTimer.timeRemaining -= 1

                    if self.ThePomoshTimer.isBreakActive == true {
                        if self.ThePomoshTimer.showMenubarTimer == true {
                            (NSApp.delegate as! AppDelegate).updateIcon(iconName: String("Coffee"))
                            (NSApp.delegate as! AppDelegate).updateTitle(newTitle: String(self.ThePomoshTimer.textForPlaybackTime(time: TimeInterval(self.ThePomoshTimer.timeRemaining))))
                        }
                    } else {
                        if self.ThePomoshTimer.showMenubarTimer == true {
                            (NSApp.delegate as! AppDelegate).updateIcon(iconName: String("Work"))
                            (NSApp.delegate as! AppDelegate).updateTitle(newTitle: String(self.ThePomoshTimer.textForPlaybackTime(time: TimeInterval(self.ThePomoshTimer.timeRemaining))))
                        }
                    }

                    // Auto-show popover + countdown ticks for last 5 seconds
                    if self.ThePomoshTimer.round > 0 &&
                       self.ThePomoshTimer.timeRemaining <= 5 &&
                       self.ThePomoshTimer.timeRemaining >= 2 {
                        if self.ThePomoshTimer.timeRemaining == 5 {
                            (NSApp.delegate as! AppDelegate).showPopover()
                        }
                        if self.ThePomoshTimer.playSound {
                            NSSound(named: "Tink")?.play()
                        }
                    }
                }

                if self.ThePomoshTimer.timeRemaining == 1 && self.ThePomoshTimer.round > 0 {
                    if self.ThePomoshTimer.playSound {
                        // Friendly alarm: plays twice for emphasis
                        NSSound(named: "Glass")?.play()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            NSSound(named: "Glass")?.play()
                        }
                    }

                    if self.ThePomoshTimer.showNotifications {
                        self.scheduleAlarmNotification()
                    }

                    // Save completed work session to SwiftData
                    if !self.ThePomoshTimer.isBreakActive {
                        let session = PomodoroSession(
                            taskName: self.currentTaskName,
                            duration: self.ThePomoshTimer.fulltime,
                            sessionType: "work"
                        )
                        session.wasCompleted = true
                        session.completedAt = Date()
                        modelContext.insert(session)
                        self.activeTask?.pomodorosCompleted += 1
                        try? modelContext.save()
                    }

                    // Break time or working time switcher 🎛
                    self.ThePomoshTimer.isBreakActive.toggle()

                    if self.ThePomoshTimer.isBreakActive == true {
                        AmbientSoundManager.shared.pauseForBreak()
                        if self.ThePomoshTimer.round == 1 {
                            self.ThePomoshTimer.timeRemaining = 0
                            self.ThePomoshTimer.isBreakActive = false
                        } else {
                            // Adds time for break
                            //        print("It's break time 😴"
                            if self.runnedRounds == 3 || self.runnedRounds == 7 {
                                self.ThePomoshTimer.timeRemaining = 1200
                                self.ThePomoshTimer.fulltime = 1200
                            } else {
                                self.ThePomoshTimer.timeRemaining = UserDefaults.standard.optionalInt(forKey: "fullBreakTime") ?? 600
                                self.ThePomoshTimer.fulltime = UserDefaults.standard.optionalInt(forKey: "fullBreakTime") ?? 600
                            }
                        }
                        // Removes 1 from total remaining round

                        self.ThePomoshTimer.round -= 1
                        self.runnedRounds += 1
                        //       print("🔥Remaining round: \(self.ThePomoshTimer.round)")
                    } else {
                        AmbientSoundManager.shared.resumeForWork()
                        self.ThePomoshTimer.fulltime = UserDefaults.standard.optionalInt(forKey: "time") ?? 1200
                        self.ThePomoshTimer.timeRemaining = UserDefaults.standard.optionalInt(forKey: "time") ?? 1200
                    }

                } else if self.ThePomoshTimer.timeRemaining == 0 {
                    //      print("Streak! 🔥 Session has ended.")

                    if self.ThePomoshTimer.showMenubarTimer == true {
                        (NSApp.delegate as! AppDelegate).updateIcon(iconName: String("menubar-icon"))
                        (NSApp.delegate as! AppDelegate).updateTitle(newTitle: String("00:00"))
                    }

                    self.ThePomoshTimer.isActive = false
                    self.activeTask = nil
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            .contentShape(Rectangle())

            ScrollView {
            VStack(alignment: .leading, spacing: 5.0) {
                Text("Preferences")
                    .font(.custom("Space Mono Regular", size: 22))
                    .padding(.bottom, 10.0)

                VStack(alignment: .leading, spacing: 10.0) {
                    // MARK: Theme picker
                    Text("Theme")
                        .font(.custom("Space Mono Regular", size: 12))

                    HStack(spacing: 10) {
                        ForEach(AppTheme.allCases) { theme in
                            Button(action: { themeManager.currentTheme = theme }) {
                                VStack(spacing: 4) {
                                    Circle()
                                        .fill(LinearGradient(
                                            colors: theme.ringWorkColors,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .frame(width: 28, height: 28)
                                        .overlay(
                                            Circle().strokeBorder(
                                                themeManager.currentTheme == theme ? Color.white : Color.clear,
                                                lineWidth: 2
                                            )
                                        )
                                    Text(theme.icon).font(.system(size: 10))
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 4)

                    // MARK: Ambient Sound
                    Text("Ambient Sound")
                        .font(.custom("Space Mono Regular", size: 12))

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 56))], spacing: 6) {
                        ForEach(AmbientSound.allCases) { sound in
                            Button(action: {
                                if sound == .none {
                                    AmbientSoundManager.shared.stop()
                                } else {
                                    AmbientSoundManager.shared.play(sound)
                                }
                            }) {
                                VStack(spacing: 3) {
                                    Image(systemName: sound.icon).font(.system(size: 14))
                                    Text(sound.rawValue).font(.system(size: 8))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 7)
                                .background(
                                    ambientManager.currentSound == sound
                                        ? themeManager.currentTheme.accentColor.opacity(0.25)
                                        : Color.white.opacity(0.05)
                                )
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if ambientManager.currentSound != .none {
                        HStack(spacing: 6) {
                            Image(systemName: "speaker.fill").font(.system(size: 9))
                            Slider(value: $ambientManager.volume, in: 0...1)
                                .tint(themeManager.currentTheme.accentColor)
                            Image(systemName: "speaker.wave.3.fill").font(.system(size: 9))
                        }
                    }

                    Divider().opacity(0.3).padding(.vertical, 2)

                    Text("Working Time:  \(self.ThePomoshTimer.fulltime / 60) minute")
                        .font(.custom("Space Mono Regular", size: 12))

                    Slider(value: Binding(
                        get: {
                            Double(UserDefaults.standard.integer(forKey: "time"))
                        },
                        set: { newValue in
                            settings.set(newValue, forKey: "time")
                            self.ThePomoshTimer.fulltime = Int(newValue)
                        }
                    ), in: 300 ... 3600, step: 300)

                    Text("Break Time:  \(self.ThePomoshTimer.fullBreakTime / 60) minute")
                        .font(.custom("Space Mono Regular", size: 12))

                    Slider(value: Binding(
                        get: {
                            Double(self.ThePomoshTimer.fullBreakTime)
                        },
                        set: { newValue in
                            settings.set(newValue, forKey: "fullBreakTime")
                            self.ThePomoshTimer.fullBreakTime = Int(newValue)
                        }
                    ), in: 300 ... 600, step: 60)

                    Text("Total cycles in a session")
                        .font(.custom("Space Mono Regular", size: 12))
                    HStack {
                        ForEach(0 ..< self.ThePomoshTimer.fullround, id: \.self) { _ in

                            Text("🔥")
                        }
                    }
                    Slider(value: Binding(
                        get: {
                            Double(UserDefaults.standard.integer(forKey: "fullround"))
                        },
                        set: { newValue in
                            settings.set(newValue, forKey: "fullround")
                            self.ThePomoshTimer.fullround = Int(newValue)
                        }
                    ), in: 1 ... 8)

                    HStack {
                        Toggle(isOn: $ThePomoshTimer.playSound) {
                            Text("Sound")
                                .font(.custom("Space Mono Regular", size: 12))
                        }.padding(.vertical, 5.0)

                        Toggle(isOn: $ThePomoshTimer.showNotifications) {
                            Text("Notifications")
                                .font(.custom("Space Mono Regular", size: 12))
                        }
                        .padding(.vertical, 5.0)

                        Toggle(isOn: $ThePomoshTimer.showMenubarTimer) {
                            Text("Menubar Timer")
                                .font(.custom("Space Mono Regular", size: 12))
                        }
                        .padding(.vertical, 5.0)
                    }

                    HStack {
                        Toggle(isOn: $ThePomoshTimer.showFloatingTimer) {
                            Text("Floating Timer")
                                .font(.custom("Space Mono Regular", size: 12))
                        }
                        .padding(.vertical, 5.0)

                        //     Toggle(isOn: $startUp) {
                        //         Text("Launch at startup")
                        //             .font(.custom("Space Mono Regular", size: 12))
                        //     }
                        //     .padding(.vertical, 5.0)
                    }

                    Button(action: {
                        self.currentPage = 0
                        if self.ThePomoshTimer.playSound {
                            NSSound(named: "touch")?.play()
                        }
                    }) {
                        HStack {
                            Image("Back")
                                .antialiased(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 28, maxHeight: 28, alignment: .center)
                                .overlay(Tooltip(tooltip: "Go back"))

                            Text("Back")
                                .font(.custom("Space Mono Regular", size: 12))
                        }
                    }

                    .buttonStyle(PomoshButtonStyle())
                    .offset(x: -18, y: 10)
                }
            }.padding(.horizontal, 30.0)
            } // ScrollView

            // MARK: Stats page (page 3)
            StatsView(currentPage: $currentPage)
                .padding(.horizontal, 20)

            // MARK: Tasks page (page 4)
            TaskBacklogView(
                activeTask: activeTask,
                onStartTask: startTask,
                currentPage: $currentPage
            )
        }
    }

    // MARK: - Start Task from Backlog

    func startTask(_ task: PomodoroTask) {
        task.status = .inProgress
        try? modelContext.save()

        activeTask = task
        currentTaskName = task.title

        ThePomoshTimer.fulltime = task.workDuration
        ThePomoshTimer.fullBreakTime = task.breakDuration
        ThePomoshTimer.fullround = task.cycles
        ThePomoshTimer.round = task.cycles
        ThePomoshTimer.timeRemaining = task.workDuration
        ThePomoshTimer.isBreakActive = false

        runnedRounds = 0
        currentPage = 0
        ThePomoshTimer.isActive = true
    }

    // MARK: - Local Notifications

    func scheduleAlarmNotification() {
        let content = UNMutableNotificationContent()
        var bodyString: String {
            var string = ""
            if self.ThePomoshTimer.isBreakActive == true {
                string = "Now, It's working time 🔥"
            } else {
                string = "It's break time ☕️"
            }
            return string
        }
        content.title = "Time is up 🙌"
        content.body = bodyString
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let identifier = "localNotification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        notificationCenter.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                self.notificationCenter.add(request) { error in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    func openAbout() {
        AboutWindowController().showWindow()
    }
}
