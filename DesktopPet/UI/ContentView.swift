//
// ContentView.swift
// Created by ferris on 12/06/2026.
//


import SwiftUI
import AppKit
import Cocoa

struct ContentView: View {
    @State var activePet = Pet(fromURL: Bundle.main.url(forResource: "placeholder", withExtension: "json")!)
    
    var body: some View {
        PetView(activePet: $activePet)
    }
}
