//
// PetView.swift
// Created by ferris on 15/06/2026.
//


import SwiftUI
import Foundation

struct PetImageWindow: View {
    @State var pet: Pet
    
    var body: some View {
        Image(nsImage: pet.sprites[pet.state]![pet.currentSprite])
            .resizable(resizingMode: .stretch)
            .aspectRatio(contentMode: .fit)
            .scaleEffect(x: pet.scale.x, y: pet.scale.y)
            .rotationEffect(Angle(degrees: pet.rotation))
            .frame(width: pet.size.width, height: pet.size.height)
            .tint(.clear)
            .onAppear {
                Task {
                    try! await Task.sleep(for: .seconds(2))
                    pet.state = .sitting
                }
            }
    }
}
