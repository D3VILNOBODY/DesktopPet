//
// PetView.swift
// Created by ferris on 15/06/2026.
//

import Foundation
import SwiftUI

struct PetImageWindow: View {
    @State var pet: Pet

    @GestureState var isWindowBeingDragged = false

    var dragGesture: some Gesture {
        WindowDragGesture()
            .updating($isWindowBeingDragged) { _, state, _ in
                state = true
                pet.setState(.grabbed)
            }
    }

    var body: some View {
        Image(nsImage: pet.sprites[pet.state]![pet.currentSprite])
            .resizable(resizingMode: .stretch)
            .aspectRatio(contentMode: .fit)
            .scaleEffect(x: pet.scale.x, y: pet.scale.x)
            .rotationEffect(Angle(degrees: pet.rotation))
            .frame(width: pet.size.width, height: pet.size.height)
            .tint(.clear)
            .gesture(dragGesture, isEnabled: true)
            .allowsWindowActivationEvents()
    }
}
