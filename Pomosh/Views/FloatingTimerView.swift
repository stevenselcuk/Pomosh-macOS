//
//  FloatingTimerView.swift
//  Pomosh
//
//  Compact floating timer pill that stays visible on screen.
//

import SwiftUI

struct FloatingTimerView: View {
    @ObservedObject var timer = PomoshTimer.shared
    @ObservedObject var themeManager = ThemeManager.shared
    @State private var isHovering = false

    private var progress: CGFloat {
        guard timer.fulltime > 0 else { return 0 }
        return CGFloat(timer.fulltime - timer.timeRemaining) / CGFloat(timer.fulltime)
    }

    private var gradientColors: [Color] {
        timer.isBreakActive
            ? themeManager.currentTheme.ringBreakColors
            : themeManager.currentTheme.ringWorkColors
    }

    private var statusLabel: String {
        if timer.round == 0 { return "Pomosh" }
        return timer.isBreakActive ? "Break" : "Focus"
    }

    var body: some View {
        HStack(spacing: 10) {
            // Mini progress ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 28, height: 28)

            // Time + label
            VStack(alignment: .leading, spacing: 1) {
                if timer.round > 0 {
                    Text(timer.textForPlaybackTime(time: TimeInterval(timer.timeRemaining)))
                        .font(.custom("Space Mono Regular", size: 16))
                        .foregroundColor(themeManager.currentTheme.accentColor)
                        .lineLimit(1)
                } else {
                    Text("Pomosh")
                        .font(.custom("Space Mono Regular", size: 14))
                        .foregroundColor(themeManager.currentTheme.accentColor)
                }
                Text(statusLabel)
                    .font(.custom("Space Mono Regular", size: 9))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer(minLength: 0)

            // Close button (hover only)
            if isHovering {
                Button(action: {
                    PomoshTimer.shared.showFloatingTimer = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 16, height: 16)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(width: 160, height: 56)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color("Background").opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(
                            LinearGradient(colors: gradientColors.map { $0.opacity(0.4) }, startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1
                        )
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if timer.round > 0 {
                timer.isActive.toggle()
            }
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}
