//
// Extensions.swift
// Created by ferris on 15/06/2026.
//


import Foundation
import CoreGraphics
import AppKit
import Logging

private let loggerSubsystem = Bundle.main.bundleIdentifier!

extension CGPoint: @retroactive AdditiveArithmetic {
    /// Checks if two points are equal to each other within a range denoted by `epsilon`.
    func approximatelyEqualTo(_ p: CGPoint, epsilon: Double) -> Bool {
        return (abs(self.x - p.x) <= epsilon) && (abs(self.y - p.y) <= epsilon)
    }
    
    public static func +(_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    public static func -(_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

extension NSImage: @retroactive Identifiable {}

extension Logger {
    static let pet = Logger(label: loggerSubsystem)
    static let window = Logger(label: loggerSubsystem)
    static let petManager = Logger(label: loggerSubsystem)
}
