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
    
    func getLoadedPet(id: String) -> Pet? {
        for p in loadedPets {
            if p.id == id {
                return p
            }
        }
        
        return nil
    }
    
    func activatePet(id: String) {
        if let pet = getLoadedPet(id: id) {
            if pet.isActive {
                Logger.petManager.notice("Pet already active",
                                         metadata: ["id": "\(pet.id)"])
            } else {
                let windowController = createPetWindow(forPet: pet)
                pet.setWindowController(windowController)
                pet.isActive = true
                
                Logger.petManager.notice("Activated pet",
                                         metadata: ["id": "\(pet.id)"])
            }
        }
    }
    
    func deactivatePet(id: String) {
        if let pet = getLoadedPet(id: id) {
            if pet.isActive {
                pet.setWindowController(nil)
                pet.isActive = false
                
                Logger.petManager.notice("Deactivated pet",
                                         metadata: ["id": "\(pet.id)"])
            } else {
                Logger.petManager.notice("Pet is already deactivated",
                                         metadata: ["id": "\(pet.id)"])
            }
        }
    }
    
    /// Starts a repeating timer that runs the update logic for every active pet object.
    func startRunLoop() {
        Logger.petManager.notice("Starting run loop...")
        
        Timer.scheduledTimer(withTimeInterval: updateFrequency, repeats: true, block: { timer in
            for pet in self.loadedPets {
                if pet.isActive {
                    pet.update(dt: self.deltaTime)
                }
            }
        })
    }
    
    func createPetWindow(forPet pet: Pet) -> NSWindowController {
        // There is already a window controller available for this, so dont make a new one
        if let windowController = pet.windowController {
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
        window.styleMask = .borderless
        window.backgroundColor = .clear
        window.hidesOnDeactivate = false
        window.hasShadow = false
        window.isMovableByWindowBackground = true
        window.setContentSize(NSSize(width: 100, height: 100))
        window.center()
        window.orderFront(nil)
        
        let windowController = NSWindowController(window: window)
        pet.windowController = windowController
        
        return windowController
    }
}
