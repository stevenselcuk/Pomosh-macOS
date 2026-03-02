//
//  FloatingTimerWindowController.swift
//  Pomosh
//
//  NSPanel-based controller for the always-on-top floating timer.
//

import AppKit
import Combine
import SwiftUI

class FloatingTimerWindowController {
    private var panel: NSPanel?
    private var cancellable: AnyCancellable?

    private let posXKey = "floatingTimerPosX"
    private let posYKey = "floatingTimerPosY"

    init() {
        cancellable = PomoshTimer.shared.$showFloatingTimer
            .receive(on: RunLoop.main)
            .sink { [weak self] show in
                if show {
                    self?.showPanel()
                } else {
                    self?.hidePanel()
                }
            }
    }

    private func makePanel() -> NSPanel {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 160, height: 56),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.animationBehavior = .utilityWindow

        let hostingView = NSHostingView(rootView: FloatingTimerView())
        panel.contentView = hostingView

        // Restore saved position or default to top-right
        if let x = UserDefaults.standard.optionalDouble(forKey: posXKey),
           let y = UserDefaults.standard.optionalDouble(forKey: posYKey) {
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        } else if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let x = screenFrame.maxX - 180
            let y = screenFrame.maxY - 76
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        // Save position when the window moves
        NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: panel,
            queue: .main
        ) { [weak self] notification in
            guard let self, let movedPanel = notification.object as? NSPanel else { return }
            let origin = movedPanel.frame.origin
            UserDefaults.standard.set(origin.x, forKey: self.posXKey)
            UserDefaults.standard.set(origin.y, forKey: self.posYKey)
        }

        return panel
    }

    private func showPanel() {
        if panel == nil {
            panel = makePanel()
        }
        panel?.orderFront(nil)
    }

    private func hidePanel() {
        panel?.orderOut(nil)
    }
}
