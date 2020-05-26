//
//  AboutView.swift
//  Pomosh
//
//  Created by Steven J. Selcuk on 23.05.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
             Text("About pomosh")
        }
    .padding()
        .frame(width: 340, height: 340, alignment: Alignment.topLeading)
       
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
