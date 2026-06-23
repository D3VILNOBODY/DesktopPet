//
// ContentView.swift
// Created by ferris on 12/06/2026.
//


import SwiftUI
import AppKit
import Logging

struct ContentView: View {
    @Environment(PetManager.self) private var petManager
    
    var body: some View {
        ConfigView()
    }
}
