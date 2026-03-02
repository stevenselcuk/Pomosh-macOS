//
//  TimerRing.swift
//  Pomosh
//
//  Created by Steven J. Selcuk on 28.05.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import SwiftUI

struct TimerRing: View {
    var width: CGFloat = 300
    var height: CGFloat = 300
    var percent: CGFloat = 10

    @State private var morphing = false
    @ObservedObject var themeManager = ThemeManager.shared
    var Timer: PomoshTimer
    @Binding var taskName: String
    var currentRound: Int

    var body: some View {
        let multiplier = width / 1000
        let progress = 0 + (percent / 100)


        return HStack {
            
            ZStack {
                Circle()
                    .stroke(Color.black.opacity(0.1), style: StrokeStyle(lineWidth: 3 * multiplier))
                    .frame(width: width, height: height)
                
             
                Circle()
                    .trim(from: true ? progress : 1, to: 1)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: self.Timer.isBreakActive
                                ? themeManager.currentTheme.ringBreakColors
                                : themeManager.currentTheme.ringWorkColors),
                            startPoint: .topLeading,
                            endPoint: .bottomLeading
                        ),
                        style: StrokeStyle(lineWidth: 5 * multiplier, lineCap: .round, lineJoin: .round, miterLimit: .infinity, dash: [20, 0], dashPhase: 0)
                    )
                    .frame(width: width, height: width)
                    .rotationEffect(Angle(degrees: 90))
                    .rotation3DEffect(Angle(degrees: 180), axis: (x: 1, y: 0, z: 0))
                    .shadow(color: themeManager.currentTheme.accentColor.opacity(0.2), radius: 5 * multiplier, x: 0, y: 5 * multiplier)
                
                VStack(alignment: .center, spacing: 15) {
                    if self.Timer.isActive {
                        if !taskName.isEmpty && !self.Timer.isBreakActive {
                            Text(taskName)
                                .font(.custom("Space Mono Regular", size: 10))
                                .opacity(0.5)
                                .lineLimit(1)
                                .frame(maxWidth: 160)
                        }
                        Text(self.Timer.isBreakActive ? self.currentRound == 4 || self.currentRound == 8 ? "Long break 🎉" : "Break time 🙌" : "🔥 X \(self.Timer.round)")
                            .font(.custom("Space Mono Regular", size: 12))
                            .animation(nil)
                    } else {
                        Text(self.Timer.round > 0 ? self.Timer.isBreakActive ? "Break stopped" : "Start" : "Create New Session")
                            .font(.custom("Space Mono Regular", size: 12))
                            .onTapGesture {
                                if self.Timer.round == 0 {
                                    if self.Timer.playSound {
                                        NSSound(named: "start")?.play()
                                    }
                                    self.Timer.round = UserDefaults.standard.optionalInt(forKey: "fullround") ?? 5
                                    self.Timer.timeRemaining = UserDefaults.standard.optionalInt(forKey: "time") ?? 1200
                                }
                            }
                    }

                    Button(action: {
                        self.Timer.isActive.toggle()

                    }) {
                        if self.Timer.isActive && self.Timer.round > 0 {
                            Image("Pause")
                                .antialiased(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 64, maxHeight: 64, alignment: .center)

                        } else if self.Timer.isActive == false && self.Timer.round > 0 {
                            Image("Play")
                                .antialiased(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 64, maxHeight: 64, alignment: .center)
                                .offset(x: 2, y: 0)
                        }
                    }

                    .buttonStyle(PomoshButtonStyle())
                    .offset(x: 0, y: 5)

                    if self.Timer.round > 0 {
                        Text("\(self.Timer.textForPlaybackTime(time: TimeInterval(self.Timer.timeRemaining)))")
                            .font(.custom("Space Mono Regular", size: 28))
                            .shadow(color: themeManager.currentTheme.accentColor.opacity(0.3), radius: 5 * multiplier, x: 0, y: 5 * multiplier)
                            .lineLimit(1)
                            .foregroundColor(themeManager.currentTheme.accentColor)
                            .offset(x: 0, y: 5)
                    } else {
                        TextField("What's your focus?", text: $taskName)
                            .textFieldStyle(.plain)
                            .font(.custom("Space Mono Regular", size: 11))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(width: 180)
                            .padding(.top, 8)
                    }
                }
            }

            .scaleEffect(morphing ? 1.06 : 1)
            .onHover { _ in
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)) {
                    self.morphing.toggle()
                }
            }
        }
        .contentShape(Circle())
        .overlay(Tooltip(tooltip: self.Timer.isActive ? "Pause" : "Start"))
        .onTapGesture {
            if self.Timer.round == 0 {
                if self.Timer.playSound {
                    NSSound(named: "start")?.play()
                }
                self.Timer.round = UserDefaults.standard.optionalInt(forKey: "fullround") ?? 5
                self.Timer.timeRemaining = UserDefaults.standard.optionalInt(forKey: "time") ?? 1200
            } else {
                if self.Timer.playSound {
                    NSSound(named: "touch2")?.play()
                }
            }
            self.Timer.isActive.toggle()
        }
    }
}
