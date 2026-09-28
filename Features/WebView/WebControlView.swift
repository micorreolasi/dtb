// WebControlView.swift
// Web view module - iPad control panel

import SwiftUI

struct WebControlView: View {
    @EnvironmentObject var projectionState: ProjectionState
    @State private var urlString = "https://www.google.com"
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("🌐 Página Web")
                    .font(AppTheme.Fonts.heading())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            Divider().background(AppTheme.Colors.primaryDark)
            
            VStack(spacing: 24) {
                Image(systemName: "safari.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppTheme.Colors.accent)
                    .padding(.top, 40)
                
                Text("Proyectar una página web")
                    .font(AppTheme.Fonts.heading(20))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                TextField("https://...", text: $urlString)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(AppTheme.Fonts.body())
                    .padding(.horizontal, 40)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                HStack(spacing: 16) {
                    Button {
                        // Ensure it has https://
                        var finalUrl = urlString
                        if !finalUrl.lowercased().hasPrefix("http") {
                            finalUrl = "https://" + finalUrl
                        }
                        projectionState.currentContent = .webView(url: finalUrl)
                    } label: {
                        Text("Proyectar en TV")
                            .font(AppTheme.Fonts.heading(16))
                            .foregroundColor(.white)
                            .frame(width: 200)
                            .padding(.vertical, 14)
                            .background(AppTheme.Colors.accent)
                            .cornerRadius(10)
                    }
                    
                    Button {
                        projectionState.goBlack()
                    } label: {
                        Text("Quitar")
                            .font(AppTheme.Fonts.heading(16))
                            .foregroundColor(.white)
                            .frame(width: 100)
                            .padding(.vertical, 14)
                            .background(AppTheme.Colors.danger)
                            .cornerRadius(10)
                    }
                }
                .padding(.top, 10)
                
                Spacer()
            }
        }
    }
}
