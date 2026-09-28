// SettingsView.swift
// Settings and configuration module

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var projectionState: ProjectionState
    @EnvironmentObject var screenManager: ExternalScreenManager
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("⚙️ Ajustes")
                    .font(AppTheme.Fonts.heading())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Spacer()
            }
            .padding(16)
            
            Divider().background(AppTheme.Colors.primaryDark)
            
            List {
                Section(header: Text("Pantalla Externa")) {
                    HStack {
                        Text("Estado")
                        Spacer()
                        Text(screenManager.isConnected ? "Conectada" : "Desconectada")
                            .foregroundColor(screenManager.isConnected ? .green : .red)
                    }
                    
                    if screenManager.isConnected {
                        HStack {
                            Text("Resolución")
                            Spacer()
                            Text(screenManager.externalScreenResolution)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("Apariencia Proyección")) {
                    ColorPicker("Color de Fondo", selection: $projectionState.backgroundColor)
                    ColorPicker("Color de Texto", selection: $projectionState.textColor)
                    
                    Toggle("Mostrar referencia en Biblia", isOn: $projectionState.showReference)
                }
                
                Section(header: Text("Base de Datos")) {
                    Button("Importar Biblia (JSON/SQLite)...") { }
                    Button("Importar Cancionero...") { }
                    Button("Exportar Favoritos...") { }
                }
                
                Section(header: Text("Acerca de")) {
                    HStack {
                        Text("Versión")
                        Spacer()
                        Text("1.0.0 (Beta)")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Aplicación")
                        Spacer()
                        Text("VisualDTB")
                            .foregroundColor(.gray)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .environment(\.colorScheme, .dark)
        }
    }
}
