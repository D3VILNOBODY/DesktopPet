//
// Pet.swift
// Created by ferris on 12/06/2026.
//

import AppKit
import CoreGraphics
import Foundation
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

enum PetError: Error {
    case jsonParseFailure
    case stringToStateFailure(String)
    case noWindow
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

    var id: String
    var windowController: NSWindowController?
    var window: NSWindow?
    var name: String
    var size: CGSize
    var sprites: [PetState : [NSImage]] = [:]
    var isActive: Bool = false
    var scale: CGPoint = CGPoint(x: 1, y: 1)
    var rotation: Double = 0
    var position: CGPoint
    var state: PetState = .idle
    var currentSprite: Int = 0
    var speed: Double = 30
    var gravity: Double = 100

    private let randomlyChoosableStates: [PetState] = [.idle, .moving, .sitting]
    private var currentTimer: Timer?
    private var targetPosition: NSPoint?

    init(fromURL url: URL) throws {
        let decoder = JSONDecoder()
        decoder.dataDecodingStrategy = .base64

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to create data with the contents of url \(url)")
        }

        guard let json = try? decoder.decode(PetJSON.self, from: data) else {
            Logger.pet.error("Failed to decode json data")
            throw PetError.jsonParseFailure
        }

        let mainScreen = NSScreen.main!
        let bottomMiddleOfScreen = NSPoint(
            x: mainScreen.frame.width / 2,
            y: mainScreen.frame.origin.y
        )

        self.position = bottomMiddleOfScreen
        self.id = "\(json.name)-\(UUID())"
        self.window = nil
        self.window = nil
        self.name = json.name
        self.size = CGSize(width: json.width, height: json.height)
        self.scale = CGPoint(x: json.scaleX, y: json.scaleY)

        for spriteJSON in json.sprites {
            var sprites: [NSImage] = []
            for imageData in spriteJSON.images {
                let img = NSImage(data: imageData)!
                sprites.append(img)
            }

            guard let state = Pet.stringToPetState(spriteJSON.state) else {
                throw PetError.stringToStateFailure(spriteJSON.state)
            }

            self.sprites[state] = sprites
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
    
    func setWindowController(_ windowController: NSWindowController?) {
        if windowController != self.windowController {
            self.windowController?.close()
        }
        self.windowController = windowController
        self.window = windowController?.window
    }
    
    func setState(_ newState: PetState) {
        if newState == state {
            return
        }

        currentSprite = 0
        state = newState
        Logger.pet.notice("Changed state",
                          metadata: ["newState": "\(newState)"])
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
        let upperBound = sprites[state]!.count - 1
        var nextSprite = currentSprite + 1
        if nextSprite > upperBound {
            nextSprite = 0
        }
        currentSprite = nextSprite
    }

    func update(dt: Double) {
        //Logger.pet.info("Updating", metadata: ["time": "\(Date.now)"])
        
        if try! !isOnFloor() {
            targetPosition = nil
            if let currentTimer = currentTimer {
                currentTimer.invalidate()
            }
            currentTimer = nil
            setState(.falling)
        }

        switch state {
        case .idle:
            idle(dt: dt)
        case .sitting:
            sit(dt: dt)
        case .moving:
            move(dt: dt)
        case .falling:
            applyGravity(dt: dt)
        case .grabbed:
            grabbed(dt: dt)
        }
    }

    private func isOnFloor() throws -> Bool {
        guard let window = window else {
            throw PetError.noWindow
        }
        
        return window.frame.origin.y <= window.screen!.frame.origin.y
    }
    
    private func grabbed(dt: Double) {
        currentTimer = nil
        targetPosition = nil
        Logger.pet.notice("PUT ME DOWNNNNN")
    }

    private func applyGravity(dt: Double) {
        guard let window = self.window else {
            return
        }

        if try! isOnFloor() {
            randomizeState()
            return
        }

        let newWindowPositionY = clamp(
            window.frame.origin.y - gravity * dt,
            lowerBound: window.screen!.frame.origin.y,
            upperBound: .infinity
        )
        
        position = NSPoint(x: window.frame.origin.x, y: newWindowPositionY)
        
        window.setFrameOrigin(position)
    }

    private func idle(dt: Double) {
        if currentTimer != nil {
            return
        }

        setState(.idle)

        let idleTime = Int.random(in: 5...15)
        let timer = Timer(
            fire: .now.addingTimeInterval(TimeInterval(idleTime)),
            interval: 0,
            repeats: false,
            block: { timer in
                Logger.pet.warning("Idle timer over")
                self.randomizeState()
                self.currentTimer = nil
            }
        )
        RunLoop.main.add(timer, forMode: .common)
        currentTimer = timer
        Logger.pet.notice("Idling", metadata: ["idleTime": "\(idleTime)"])
    }

    private func sit(dt: Double) {
        if currentTimer != nil {
            return
        }

        setState(.sitting)

        let sitTime = Int.random(in: 10...45)
        let timer = Timer(
            fire: .now.addingTimeInterval(TimeInterval(sitTime)),
            interval: 0,
            repeats: false,
            block: { timer in
                Logger.pet.notice("Sitting timer over")
                self.randomizeState()
                self.currentTimer = nil
            }
        )
        RunLoop.main.add(timer, forMode: .common)
        currentTimer = timer
        Logger.pet.notice("Sitting", metadata: ["sitTime": "\(sitTime)"])
    }

    private func moveWindowTowardsTarget(dt: Double) {
        guard let window = window else {
            return
        }

        let vector = targetPosition! - position
        let magnitude = CGPoint(
            x: sqrt(vector.x * vector.x),
            y: sqrt(vector.y * vector.y)
        )

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
        
        scale.x = scale.x >= 0 ? 1 : -1
        position = newFrameOrigin
        
        window.setFrameOrigin(position)
    }

    func move(dt: Double) {
        guard let window = window else {
            return
        }

        if targetPosition == nil {
            let screen = window.screen!
            
            targetPosition = CGPoint(
                x: Double.random(in: screen.frame.origin.x...screen.frame.width - window.frame.width),
                y: window.frame.origin.y
            )
            position = window.frame.origin
            
            Logger.pet.notice("Target position set",
                              metadata: ["targetPosition": "\(targetPosition ?? NSPoint(x: 0, y: 0))"])
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
