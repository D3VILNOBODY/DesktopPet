//
// PetView.swift
// Created by ferris on 15/06/2026.
//


import SwiftUI
import Foundation

struct PetView: View {
    @Binding var activePet: Pet
    @State private var firstAppear: Bool = true
    var updateFrequency: Double = 1 / 30
    
    var body: some View {
        Image(nsImage: activePet.images[activePet.state]![activePet.currentSprite])
            .resizable(resizingMode: .stretch)
            .aspectRatio(contentMode: .fit)
            .scaleEffect(x: activePet.scale.x, y: activePet.scale.y)
            .rotationEffect(Angle(degrees: activePet.rotation))
            .frame(width: activePet.size.width,
                   height: activePet.size.height)
            .tint(.clear)
            .onAppear {
                if self.firstAppear == false {
                    return
                }
                self.firstAppear = false
                
                startRunLoop()
            }
    }
    
    func startRunLoop() {
        Timer.scheduledTimer(withTimeInterval: updateFrequency, repeats: true, block: { timer in
            Task {
                await activePet.update(dt: updateFrequency)
            }
        })
    }
}
