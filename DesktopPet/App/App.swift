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
    }
    
    init() {
        petManager.startRunLoop()
    }
}
