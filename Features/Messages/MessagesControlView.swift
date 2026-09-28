// MessagesControlView.swift
// Messages and announcements module - iPad control panel

import SwiftUI

class MessagesViewModel: ObservableObject {
    @Published var staticMessage: String = ""
    @Published var scrollingMessage: String = "Bienvenidos a nuestra reunión. Por favor, ponga su teléfono en silencio."
    @Published var isScrollingMode: Bool = true
}

struct MessagesControlView: View {
    @EnvironmentObject var projectionState: ProjectionState
    @StateObject private var vm = MessagesViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("💬 Mensajes y Avisos")
                    .font(AppTheme.Fonts.heading())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            Divider().background(AppTheme.Colors.primaryDark)
            
            VStack(alignment: .leading, spacing: 24) {
                // Mode selector
                Picker("Tipo de Mensaje", selection: $vm.isScrollingMode) {
                    Text("Estático (Centro)").tag(false)
                    Text("Marquesina (En movimiento)").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Message Editor
                VStack(alignment: .leading, spacing: 8) {
                    Text("Texto del mensaje:")
                        .font(AppTheme.Fonts.caption(14))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    TextEditor(text: vm.isScrollingMode ? $vm.scrollingMessage : $vm.staticMessage)
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .padding(8)
                        .background(AppTheme.Colors.surfaceLight)
                        .cornerRadius(8)
                        .frame(height: 150)
                }
                .padding(.horizontal)
                
                // Controls
                HStack(spacing: 16) {
                    Button {
                        if vm.isScrollingMode {
                            projectionState.projectMessage(text: vm.scrollingMessage)
                        } else {
                            // Reuse bible projection for static centered text but without reference
                            projectionState.projectBible(text: vm.staticMessage, reference: "", version: "")
                        }
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Proyectar Mensaje")
                        }
                        .font(AppTheme.Fonts.heading(16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.Colors.accent)
                        .cornerRadius(10)
                    }
                    
                    Button {
                        projectionState.goBlack()
                    } label: {
                        HStack {
                            Image(systemName: "stop.fill")
                            Text("Quitar")
                        }
                        .font(AppTheme.Fonts.heading(16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.Colors.danger)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 8)
        }
    }
}
