//
//  AboutView.swift
//  Pomosh
//
//  Created by Steven J. Selcuk on 28.05.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 14) {
            if let appIcon = NSImage(named: "AppIcon") {
                Image(nsImage: appIcon)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .cornerRadius(18)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            }

            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.7"
            Text("Pomosh v\(version)")
                .font(.custom("Space Mono Regular", size: 20))

            Text("A minimal Pomodoro timer\nfor your menu bar.")
                .font(.custom("Space Mono Regular", size: 12))
                .multilineTextAlignment(.center)
                .opacity(0.7)

            Button(action: {
                NSWorkspace.shared.open(URL(string: "https://pomosh.netlify.app")!)
            }) {
                Text("pomosh.netlify.app")
                    .font(.custom("Space Mono Regular", size: 12))
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("© 2021 Steven J. Selcuk")
                .font(.custom("Space Mono Regular", size: 10))
                .opacity(0.4)
        }
        .padding(24)
        .frame(width: 340, height: 300, alignment: .top)
    }
}


final class AboutWindowController: NSWindowController {
    convenience init() {
        let window = SwiftUIWindowForMenuBarApp()
        self.init(window: window)
        
        let view = AboutView()
        
        window.title = "About"
        window.styleMask = [
            .titled,
            .closable
        ]
        window.level = .modalPanel
        window.contentView = NSHostingView(rootView: view)
        window.center()
    }
    
    func showWindow() {
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}


struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
