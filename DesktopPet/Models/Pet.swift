//
// Pet.swift
// Created by ferris on 12/06/2026.
//


import Foundation
import CoreGraphics
import AppKit
import Logging

struct PetSprite {
    var state: Pet.PetState
    var images: [NSImage]
    
    init(fromJSON json: PetSpriteJSON) {
        self.state = .idle
        self.images = []
    }
}

struct PetSpriteJSON: Codable {
    let state: String
    let images: [Data]
}

struct PetJSON: Codable {
    let name: String
    let width: Int
    let height: Int
    let scaleX: Int
    let scaleY: Int
    let sprites: [PetSpriteJSON]
}

@Observable
final class Pet: Identifiable, Sendable {
    enum PetState: CaseIterable {
        case idle
        case sitting
        case moving
        case falling
        case grabbed
    }
    
    var window: Window
    var name: String
    var size: CGSize
    var images: [PetState: [NSImage]]
    var scale: CGPoint = CGPoint(x: 1, y: 1)
    var rotation: Double = 0
    var position: CGPoint
    var state: PetState = .idle
    var currentSprite: Int = 0
    var speed: Double = 18
    var gravity: Double = 100
    
    private let randomlyChoosableStates: [PetState] = [.idle, .moving, .sitting]
    private var currentTimer: Timer?
    private var targetPosition: NSPoint?
    
    init(fromURL url: URL) {
        let decoder = JSONDecoder()
        decoder.dataDecodingStrategy = .base64
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to create data with the contents of url \(url)")
        }
        
        guard let json = try? decoder.decode(PetJSON.self, from: data) else {
            fatalError("Failed to decode data to json")
        }
        
        let mainScreen = NSScreen.main!
        let bottomMiddleOfScreen = NSPoint(x: mainScreen.frame.width / 2, y: mainScreen.frame.origin.y)
        
        self.position = bottomMiddleOfScreen
        self.name = json.name
        self.size = CGSize(width: json.width, height: json.height)
        self.scale = CGPoint(x: json.scaleX, y: json.scaleY)
        self.images = [:]
        
        for spriteJSON in json.sprites {
            var sprites: [NSImage] = []
            for imageData in spriteJSON.images {
                let img = NSImage(data: imageData)!
                sprites.append(img)
            }
            guard let state = Pet.stringToPetState(spriteJSON.state) else {
                fatalError("Failed to convert \(spriteJSON.state) to PetState")
            }
            self.images[state] = sprites
        }
    }
    
    static func stringToPetState(_ str: String) -> PetState? {
        return switch str {
        case "idle":
            .idle
        case "moving":
            .moving
        case "sitting":
            .sitting
        case "grabbed":
            .grabbed
        case "falling":
            .falling
        default:
            nil
        }
    }
    
    func setState(_ newState: PetState) {
        if newState == state {
            return
        }
        
        currentSprite = 0
        state = newState
        Logger.pet.notice("Changed state", metadata: ["newState": "\(newState)"])
    }
    
    private func randomizeState() {
        while true {
            let s = randomlyChoosableStates.randomElement()!
            if state == s {
                continue
            }
            setState(s)
            break
        }
    }
    
    func cycleSprite() {
        let upperBound = images[state]!.count - 1
        var nextSprite = currentSprite + 1
        if nextSprite > upperBound {
            nextSprite = 0
        }
        currentSprite = nextSprite
    }
    
    func update(dt: Double) async {
        if !isOnFloor() {
            targetPosition = nil
            if let currentTimer = currentTimer {
                currentTimer.invalidate()
            }
            currentTimer = nil
            setState(.falling)
        }
        
        switch state {
        case .idle:
            await idle(dt: dt)
        case .sitting:
            await sit(dt: dt)
        case .moving:
            await move(dt: dt)
        case .falling:
            await applyGravity(dt: dt)
        default:
            break
        }
    }
    
    func isOnFloor() -> Bool {
        return window.frame.origin.y <= window.screen!.frame.origin.y
    }
    
    private func applyGravity(dt: Double) async {
        if isOnFloor() {
            randomizeState()
            return
        }
        
        let newWindowPositionY = clamp(window.frame.origin.y - gravity * dt, lowerBound: window.screen!.frame.origin.y, upperBound: .infinity)
        position = NSPoint(x: window.frame.origin.x, y: newWindowPositionY)
        window.setFrameOrigin(position)
    }
    
    private func idle(dt: Double) async {
        if currentTimer != nil {
            return
        }
        
        setState(.idle)
        
//        let idleTime = Int.random(in: 5...15)
        let idleTime = 3
        let timer = Timer(fire: .now.addingTimeInterval(TimeInterval(idleTime)),
                          interval: 0,
                          repeats: false,
                          block: { timer in
            Logger.pet.warning("Idle timer over")
            self.randomizeState()
            self.currentTimer = nil
        })
        RunLoop.main.add(timer, forMode: .common)
        currentTimer = timer
        Logger.pet.notice("Idling", metadata: ["idleTime": "\(idleTime)"])
    }
    
    private func sit(dt: Double) async {
        if currentTimer != nil {
            return
        }
        
        setState(.sitting)
        
//        let sitTime = Int.random(in: 10...45)
        let sitTime = 3
        let timer = Timer(fire: .now.addingTimeInterval(TimeInterval(sitTime)),
                          interval: 0,
                          repeats: false,
                          block: { timer in
            Logger.pet.notice("Sitting timer over")
            self.randomizeState()
            self.currentTimer = nil
        })
        RunLoop.main.add(timer, forMode: .common)
        currentTimer = timer
        Logger.pet.notice("Sitting", metadata: ["sitTime": "\(sitTime)"])
    }
    
    private func moveWindowTowardsTarget(dt: Double) {
        let vector = targetPosition! - position
        let magnitude = CGPoint(x: sqrt(vector.x * vector.x),
                                y: sqrt(vector.y * vector.y))
        
        var dx = vector.x / magnitude.x
        if dx.isNaN { dx = 0 }
        var dy = vector.y / magnitude.y
        if dy.isNaN { dy = 0 }
        
        let direction = CGPoint(x: dx, y: dy)
        //Logger.pet.info("Vector results", metadata: ["vector": "\(vector)",
        //                                             "magnitude": "\(magnitude)",
        //                                             "direction": "\(direction)"])
        let newFrameOrigin = position + NSPoint(x: speed * direction.x * dt,
                                                y: speed * direction.y * dt)
        
        if direction.x >= 0 {
            scale.x = 1
        } else {
            scale.x = -1
        }
        
        position = newFrameOrigin
        window.setFrameOrigin(position)
    }
    
    func move(dt: Double) async {
        if targetPosition == nil {
            let screen = window.screen!
            // This is so fucked man holy shit
            targetPosition = CGPoint(x: Double.random(in: screen.frame.origin.x...screen.frame.width - window.frame.width),
                                     y: window.frame.origin.y)
            position = window.frame.origin
            Logger.pet.notice("Target position set", metadata: ["targetPosition": "\(targetPosition ?? NSPoint(x: 0, y: 0))"])
        }
        
        if window.frame.origin.approximatelyEqualTo(targetPosition!, epsilon: 0.5) {
            targetPosition = nil
            position = window.frame.origin
            randomizeState()
            return
        }
        
        setState(.moving)
        moveWindowTowardsTarget(dt: dt)
    }
}
