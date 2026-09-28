// TimerControlView.swift
// Timer and Countdown module - iPad control panel

import SwiftUI
import Combine

class TimerViewModel: ObservableObject {
    @Published var minutes: Int = 5
    @Published var seconds: Int = 0
    @Published var mode: TimerMode = .countdown
    
    @Published var isRunning = false
    @Published var timeRemaining: TimeInterval = 0
    @Published var displayString = "05:00"
    
    private var timer: AnyCancellable?
    
    enum TimerMode: String, CaseIterable {
        case countdown = "Cuenta Regresiva"
        case stopwatch = "Cronómetro"
        case clock = "Reloj"
    }
    
    func start() {
        if mode == .countdown && timeRemaining == 0 {
            timeRemaining = TimeInterval((minutes * 60) + seconds)
        }
        
        isRunning = true
        updateDisplay()
        
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            self?.tick()
        }
    }
    
    func pause() {
        isRunning = false
        timer?.cancel()
        updateDisplay()
    }
    
    func reset() {
        pause()
        if mode == .countdown {
            timeRemaining = TimeInterval((minutes * 60) + seconds)
        } else {
            timeRemaining = 0
        }
        updateDisplay()
    }
    
    private func tick() {
        if mode == .countdown {
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                pause()
            }
        } else if mode == .stopwatch {
            timeRemaining += 1
        } else if mode == .clock {
            // Handled in updateDisplay
        }
        updateDisplay()
    }
    
    func updateDisplay() {
        if mode == .clock {
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            displayString = formatter.string(from: Date())
        } else {
            let m = Int(timeRemaining) / 60
            let s = Int(timeRemaining) % 60
            displayString = String(format: "%02d:%02d", m, s)
        }
    }
}

struct TimerControlView: View {
    @EnvironmentObject var projectionState: ProjectionState
    @StateObject private var vm = TimerViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("⏱️ Cronómetro y Reloj")
                    .font(AppTheme.Fonts.heading())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            Divider().background(AppTheme.Colors.primaryDark)
            
            VStack(spacing: 30) {
                // Mode selector
                Picker("Modo", selection: $vm.mode) {
                    ForEach(TimerViewModel.TimerMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .onChange(of: vm.mode) { _ in vm.reset() }
                
                // Display
                Text(vm.displayString)
                    .font(.system(size: 80, weight: .light, design: .monospaced))
                    .foregroundColor(AppTheme.Colors.accentLight)
                    .padding(.vertical, 20)
                
                // Settings (only for countdown)
                if vm.mode == .countdown {
                    HStack(spacing: 20) {
                        VStack {
                            Text("Minutos")
                                .foregroundColor(AppTheme.Colors.textSecondary)
                            Stepper("\(vm.minutes)", value: $vm.minutes, in: 0...120)
                        }
                        
                        VStack {
                            Text("Segundos")
                                .foregroundColor(AppTheme.Colors.textSecondary)
                            Stepper("\(vm.seconds)", value: $vm.seconds, in: 0...59, step: 15)
                        }
                    }
                    .padding(.horizontal, 40)
                    .onChange(of: vm.minutes) { _ in vm.reset() }
                    .onChange(of: vm.seconds) { _ in vm.reset() }
                }
                
                // Controls
                HStack(spacing: 20) {
                    Button(action: vm.isRunning ? vm.pause : vm.start) {
                        Image(systemName: vm.isRunning ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(vm.isRunning ? AppTheme.Colors.warning : AppTheme.Colors.success)
                    }
                    
                    Button(action: vm.reset) {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.Colors.textMuted)
                    }
                }
                
                Spacer()
                
                // Project Button
                Button {
                    projectionState.projectTimer(display: vm.displayString, isRunning: vm.isRunning)
                } label: {
                    HStack {
                        Image(systemName: "play.rectangle.fill")
                        Text("Proyectar Reloj")
                    }
                    .font(AppTheme.Fonts.heading(16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.Colors.accent)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                // Auto-sync projection when running
                .onChange(of: vm.displayString) { newValue in
                    if case .timer = projectionState.currentContent {
                        projectionState.projectTimer(display: newValue, isRunning: vm.isRunning)
                    }
                }
            }
            .padding(.top, 10)
        }
    }
}
