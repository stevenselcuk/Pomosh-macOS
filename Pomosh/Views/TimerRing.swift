//
//  TimerRing.swift
//  Pomosh
//
//  Created by Steven J. Selcuk on 28.05.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import SwiftUI

struct TimerRing: View {
    var color1 = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    var color2 = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
    var color3 = #colorLiteral(red: 1, green: 0.003921568627, blue: 0.4588235294, alpha: 1)
    var color4 = #colorLiteral(red: 0.9921568627, green: 0.9294117647, blue: 0.1333333333, alpha: 1)
    var width: CGFloat = 300
    var height: CGFloat = 300
    var percent: CGFloat = 10

    @State private var morphing = false
    var Timer: PomoshTimer
    
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
                        LinearGradient(gradient: Gradient(colors: [Color(self.Timer.isBreakActive ? color3 : color1), Color(self.Timer.isBreakActive ? color4 : color2)]), startPoint: .topLeading, endPoint: .bottomLeading),
                        style: StrokeStyle(lineWidth: 5 * multiplier, lineCap: .round, lineJoin: .round, miterLimit: .infinity, dash: [20, 0], dashPhase: 0)
                    )
        .frame(width: width, height: width)
        //.animation(.linear)                
        .rotationEffect(Angle(degrees: 90))
        .rotation3DEffect(Angle(degrees: 180), axis: (x: 1, y: 0, z: 0))
        .shadow(color: Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)).opacity(0.1), radius: 5 * multiplier, x: 0, y: 5 * multiplier)
                
                VStack(alignment: .center, spacing: 15) {
                    if self.Timer.isActive {
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
                            .shadow(color: Color("Green").opacity(0.1), radius: 5 * multiplier, x: 0, y: 5 * multiplier)
                            .lineLimit(1)
                            .foregroundColor(Color("Neon"))
                            .offset(x: 0, y: 5)
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
