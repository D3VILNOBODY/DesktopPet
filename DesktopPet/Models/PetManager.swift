//
// PetManager.swift
// Created by ferris on 20/06/2026.
//


import Foundation
import AppKit
import Logging
import SwiftUI

@Observable
final class PetManager {
    var loadedPets: [Pet] = []
    var activePets: [Pet] = []
    var activeWindowControllers: [String : NSWindowController] = [:]
    var updateFrequency: Double = 1 / 60
    var deltaTime: Double = 1 / 60 // starts the same as update frequency but changes. TODO: yeah uh make this change
    
    init() {
        let fileManager = FileManager()
        let applicationSupportURL = try! URL(for: .applicationSupportDirectory, in: .userDomainMask)
        let bundleFolderURL = applicationSupportURL.appendingPathComponent(Bundle.main.bundleIdentifier!)
        let petConfigFilesURL = bundleFolderURL.appendingPathComponent("pets")
        
        guard let petConfigFiles = try? fileManager.contentsOfDirectory(at: petConfigFilesURL, includingPropertiesForKeys: [.isRegularFileKey]) else {
            fatalError("Failed to read pet config files from URL \"\(petConfigFilesURL.path(percentEncoded: false))\"")
        }
        
        for url in petConfigFiles {
            if url.isFileURL == false || url.pathExtension != "json" {
                continue
            }
            
            do {
                let pet = try Pet(fromURL: url/*, window: NSApplication.shared.windows.first!*/) // TODO: replace this with an actual way of getting a specific window. the current system is BAD
                loadedPets.append(pet)
                Logger.petManager.info("Loaded pet \"\(pet.name)\" and added it to loadedPets")
            } catch PetError.jsonParseFailure {
                Logger.petManager.warning("Got a JSON parse failure when attempting to create a pet object")
            } catch PetError.stringToStateFailure(let msg) {
                Logger.petManager.warning("Failed to convert \"\(msg)\" to PetState")
            } catch let error {
                Logger.petManager.warning("Got error \(error)")
            }
        }
    }
    
    /// Puts a pet that is in `loadedPets` into `activePets`, making it able to be updated by `startRunLoop`.
    func activatePet(id: String) {
        var pet: Pet?
        
        for p in loadedPets {
            if p.id == id {
                pet = p
                break
            }
        }
        
        if let pet = pet {
            let windowController = createPetWindow(forPet: pet)
            pet.setWindow(windowController.window!)
            activePets.append(pet)
            Logger.petManager.notice("Activated pet",
                                     metadata: ["id": "\(pet.id)"])
        }
    }
    
    /// Starts a repeating timer that runs the update logic for every active pet object.
    func startRunLoop() {
        Logger.petManager.notice("Starting run loop...")
        
        Timer.scheduledTimer(withTimeInterval: updateFrequency, repeats: true, block: { timer in
            for pet in self.activePets {
                pet.update(dt: self.deltaTime)
            }
            
            //Logger.petManager.info("Run loop cycle ended", metadata: ["deltaTime": "\(self.deltaTime)"])
        })
    }
    
    func createPetWindow(forPet pet: Pet) -> NSWindowController {
        // There is already a window controller available for this, so dont make a new one
        if let windowController = activeWindowControllers[pet.id] {
            Logger.petManager.notice("Window already exists")
            return windowController
        }
        
        Logger.petManager.notice("Window doesnt exist. Creating one...")
        
        let hostingView = NSHostingView(rootView: PetImageWindow(pet: pet))
        let window = NSWindow()
        window.contentView = hostingView
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
        window.backgroundColor = .clear
        window.hidesOnDeactivate = false
        window.hasShadow = false
        window.isMovableByWindowBackground = true
        window.setContentSize(NSSize(width: 100, height: 100))
        window.center()
        window.orderFront(nil)
        //window.orderFrontRegardless()
        //window.ignoresMouseEvents = true
        
        let windowController = NSWindowController(window: window)
        
        activeWindowControllers[pet.id] = windowController
        
        return windowController
    }
}
