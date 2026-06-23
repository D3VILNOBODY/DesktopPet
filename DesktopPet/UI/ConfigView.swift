//
// ConfigView.swift
// Created by ferris on 23/06/2026.
//

import Foundation
import SwiftUI

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

struct ConfigView: View {
    @Environment(PetManager.self) var petManager
    
    var body: some View {
        ForEach(petManager.loadedPets) { pet in
            VStack {
                Text("\(pet.name)")
                    .font(.title)
                    .bold()
                HStack {
                    Button("Activate") {
                        petManager.activatePet(id: pet.id)
                    }
                    Button("Deactivate") {
                        petManager.deactivatePet(id: pet.id)
                    }
                }
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
}
