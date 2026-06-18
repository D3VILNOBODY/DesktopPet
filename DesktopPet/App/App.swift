//
// DesktopPetApp.swift
// Created by ferris on 12/06/2026.
//


import SwiftUI

@main
struct DesktopPetApp: App {
    @NSApplicationDelegateAdaptor var appDelegate: DesktopPetAppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
//            VStack {
//                Button("Show image window") {
//                    appDelegate.createImageWindow(nil)
//                }
//                Button("Close image window") {
//                    appDelegate.closeImageWindow(nil)
//                }
//            }
        }
        .windowLevel(.floating)
        .defaultSize(CGSize(width: 100.0, height: 100.0))
        .windowResizability(.contentSize)
        .commandsRemoved()
        .commands {
            CommandGroup(before: .appSettings) {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }.keyboardShortcut("Q", modifiers: .command)
            }
        }
    }
}
