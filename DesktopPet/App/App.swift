//
// DesktopPetApp.swift
// Created by ferris on 12/06/2026.
//


import SwiftUI

@main
struct DesktopPetApp: App {
    @NSApplicationDelegateAdaptor var appDelegate: DesktopPetAppDelegate
    
    @State var petManager: PetManager = PetManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(petManager)
//        .windowLevel(.floating)
//        .defaultSize(CGSize(width: 100.0, height: 100.0))
//        .windowResizability(.contentSize)
//        .commandsRemoved()
//        .commands {
//            CommandGroup(before: .appSettings) {
//                Button("Quit") {
//                    NSApplication.shared.terminate(nil)
//                }.keyboardShortcut("Q", modifiers: .command)
//            }
//        }
    }
    
    init() {
        petManager.startRunLoop()
    }
}
