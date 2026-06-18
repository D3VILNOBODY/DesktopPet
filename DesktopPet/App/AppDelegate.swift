//
// DesktopPetAppDelegate.swift
// Created by ferris on 12/06/2026.
//


import Foundation
import AppKit
import SwiftUI

class DesktopPetAppDelegate: NSObject, NSApplicationDelegate {
//    private var imageWindowController: NSWindowController?
    
//    @IBAction func createImageWindow(_ sender: Any?) {
//        if let imageWindowController = imageWindowController {
//            /// The window already exists, we just show it.
//            imageWindowController.window?.orderFrontRegardless()
//        } else {
//            /// The styleMask is not set just to `.borderless` so you can also programmaticaly resize the window.
//            /// You don't have to specify the screen but it's best practice.
//            let imageWindow = NSWindow(contentRect: .zero,
//                                       styleMask: [.borderless, .resizable],
//                                       backing: .buffered,
//                                       defer: true,
//                                       screen: NSApp.keyWindow?.screen)
//            
//            imageWindow.isMovableByWindowBackground = true
//            /// It makes the standard NSWindow chrome actualy disappear.
//            imageWindow.backgroundColor = .clear
//            
//            /// We have to set the content ourselves
//            let contentView = NSHostingView(rootView: ContentView())
//            imageWindow.contentView = contentView
//            
//            /// Let's make the window controller handle the lifecycle of the window.
//            imageWindowController = .init(window: imageWindow)
//            
//            /// We show the window on screen
//            imageWindow.orderFrontRegardless()
//            imageWindow.center()
//        }
//    }
//    
//    @IBAction func closeImageWindow(_ sender: Any?) {
//        guard let imageWindowController = imageWindowController else {
//            return
//        }
//        
//        imageWindowController.close()
//        self.imageWindowController = nil
//    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let window = NSApplication.shared.windows.first!
        
        window.collectionBehavior = [
            .canJoinAllSpaces,
            .canJoinAllApplications,
            .auxiliary,
            .fullScreenAuxiliary,
            .ignoresCycle
        ]
        window.level = .floating
        window.styleMask = [
            .borderless,
        ]
        // window.ignoresMouseEvents = true
        window.backgroundColor = .clear
        window.hidesOnDeactivate = false
        window.hasShadow = false
        window.isMovableByWindowBackground = true
        window.setContentSize(NSSize(width: 100, height: 100))
        window.center()
        window.orderFrontRegardless()
    }
}
