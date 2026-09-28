// ExternalScreenManager.swift
// Detects and manages external HDMI display connection

import UIKit
import SwiftUI
import Combine

class ExternalScreenManager: ObservableObject {
    @Published var isConnected = false
    @Published var externalScreenBounds: CGRect = .zero
    
    var projectionState: ProjectionState?
    private var externalWindow: UIWindow?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupNotifications()
        checkExistingScreens()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenDidConnect(_:)),
            name: UIScreen.didConnectNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenDidDisconnect(_:)),
            name: UIScreen.didDisconnectNotification,
            object: nil
        )
    }
    
    private func checkExistingScreens() {
        if UIScreen.screens.count > 1 {
            let externalScreen = UIScreen.screens[1]
            setupExternalWindow(on: externalScreen)
        }
    }
    
    // MARK: - Screen Events
    @objc private func screenDidConnect(_ notification: Notification) {
        guard let screen = notification.object as? UIScreen else { return }
        print("📺 External display connected: \(screen.bounds)")
        setupExternalWindow(on: screen)
    }
    
    @objc private func screenDidDisconnect(_ notification: Notification) {
        print("📺 External display disconnected")
        tearDownExternalWindow()
    }
    
    // MARK: - Window Management
    private func setupExternalWindow(on screen: UIScreen) {
        // Select best available screen mode (highest resolution)
        if let bestMode = screen.availableModes.max(by: { $0.size.width * $0.size.height < $1.size.width * $1.size.height }) {
            screen.currentMode = bestMode
        }
        
        let window = UIWindow(frame: screen.bounds)
        window.screen = screen
        window.windowLevel = .normal
        
        // Create the projection view
        let projectionView = ProjectionRootView()
            .environmentObject(projectionState ?? ProjectionState())
        
        let hostingController = UIHostingController(rootView: projectionView)
        hostingController.view.backgroundColor = .black
        
        window.rootViewController = hostingController
        window.isHidden = false
        window.makeKeyAndVisible()
        
        self.externalWindow = window
        
        DispatchQueue.main.async {
            self.isConnected = true
            self.externalScreenBounds = screen.bounds
        }
    }
    
    private func tearDownExternalWindow() {
        externalWindow?.isHidden = true
        externalWindow?.rootViewController = nil
        externalWindow = nil
        
        DispatchQueue.main.async {
            self.isConnected = false
            self.externalScreenBounds = .zero
        }
    }
    
    // MARK: - Screen Info
    var externalScreenResolution: String {
        guard isConnected else { return "No conectada" }
        let b = externalScreenBounds
        return "\(Int(b.width))×\(Int(b.height))"
    }
}
