//
// Math.swift
// Created by ferris on 15/06/2026.
//


import Foundation
import CoreGraphics

func lerp<V: BinaryFloatingPoint, T: BinaryFloatingPoint>(from v0: V, to v1: V, _ t: T) -> V {
    return v0 + V(t) * (v1 - v0)
}

func lerp<T: BinaryFloatingPoint>(from p0: CGPoint, to p1: CGPoint, _ t: T) -> CGPoint {
    return CGPoint(x: lerp(from: p0.x, to: p1.x, t),
                   y: lerp(from: p0.y, to: p1.y, t))
}

func lerp<T: BinaryFloatingPoint>(from v0: CGVector, to v1: CGVector, _ t: T) -> CGVector {
    return CGVector(dx: lerp(from: v0.dx, to: v1.dx, t),
                    dy: lerp(from: v0.dy, to: v1.dy, t))
}

func clamp<T: BinaryFloatingPoint>(_ v0: T, lowerBound: T, upperBound: T) -> T {
    var n = v0
    
    if v0 <= lowerBound {
        n = lowerBound
    } else if v0 >= upperBound {
        n = upperBound
    }
    
    return n
}
