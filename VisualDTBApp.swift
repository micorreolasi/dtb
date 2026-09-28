// VisualDTBApp.swift
// VisualDTB - Projector App for iPad with External Display
// Created for iPad 10th generation + HDMI output

import SwiftUI

@main
struct VisualDTBApp: App {
    @StateObject private var screenManager = ExternalScreenManager()
    @StateObject private var projectionState = ProjectionState()
    
    var body: some Scene {
        WindowGroup {
            MainNavigationView()
                .environmentObject(screenManager)
                .environmentObject(projectionState)
                .onAppear {
                    screenManager.projectionState = projectionState
                }
        }
    }
}
