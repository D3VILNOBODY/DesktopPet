//
// ContentView.swift
// Created by ferris on 12/06/2026.
//


import SwiftUI
import AppKit
import Logging

private struct PetImageList: View {
    var pet: Pet
    var key: Pet.PetState
    
    var body: some View {
        HStack {
            if let sprites = pet.sprites[key] {
                ForEach(sprites) { image in
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                }
            } else {
                Text("No images to display")
            }
        }
    }
}

struct ContentView: View {
    @Environment(PetManager.self) private var petManager
    
    var body: some View {
        List(petManager.loadedPets) { pet in
            Text("\(pet.name)")
                .font(.title)
                .bold()
            Button("Activate", action: {
                petManager.activatePet(id: pet.id)
            })
            VStack {
                List(Array(pet.sprites.keys.enumerated()), id: \.element) { _, key in
                    Section("\(LocalizedStringResource(stringLiteral: "\(key)"))") {
                        PetImageList(pet: pet, key: key)
                    }
                    .font(.title2)
                }
            }
            .frame(height: 450)
            .padding()
        }
    }
}
