// MainNavigationView.swift
// iPad control panel with sidebar navigation

import SwiftUI

enum AppModule: String, CaseIterable, Identifiable {
    case bible = "Biblia"
    case songs = "Canciones"
    case media = "Medios"
    case documents = "Documentos"
    case messages = "Mensajes"
    case timer = "Timer"
    case web = "Web"
    case settings = "Ajustes"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .bible: return "book.fill"
        case .songs: return "music.note.list"
        case .media: return "photo.on.rectangle.angled"
        case .documents: return "doc.richtext.fill"
        case .messages: return "text.bubble.fill"
        case .timer: return "timer"
        case .web: return "globe"
        case .settings: return "gearshape.fill"
        }
    }
}

struct MainNavigationView: View {
    @EnvironmentObject var screenManager: ExternalScreenManager
    @EnvironmentObject var projectionState: ProjectionState
    @State private var selectedModule: AppModule = .bible
    @State private var showProjectionPreview = true
    
    var body: some View {
        HStack(spacing: 0) {
            // MARK: - Sidebar
            sidebarView
            
            // MARK: - Divider
            Rectangle()
                .fill(AppTheme.Colors.primaryDark.opacity(0.5))
                .frame(width: 1)
            
            // MARK: - Main Content
            VStack(spacing: 0) {
                // Top bar
                topBar
                
                // Content + Preview
                GeometryReader { geo in
                    HStack(spacing: 0) {
                        // Module content
                        moduleContent
                            .frame(width: showProjectionPreview
                                   ? geo.size.width * 0.6
                                   : geo.size.width)
                        
                        if showProjectionPreview {
                            // Divider
                            Rectangle()
                                .fill(AppTheme.Colors.primaryDark.opacity(0.3))
                                .frame(width: 1)
                            
                            // Projection preview
                            projectionPreview
                                .frame(width: geo.size.width * 0.4)
                        }
                    }
                }
                
                // Bottom controls bar
                bottomControlsBar
            }
        }
        .background(AppTheme.Colors.background)
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Sidebar
    private var sidebarView: some View {
        VStack(spacing: 8) {
            // Logo
            VStack(spacing: 4) {
                Image(systemName: "tv.and.mediabox")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.Colors.accentLight)
                Text("DTB")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding(.vertical, 12)
            
            Divider()
                .background(AppTheme.Colors.primaryDark)
                .padding(.horizontal, 8)
            
            // Module buttons
            ForEach(AppModule.allCases) { module in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedModule = module
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: module.icon)
                            .font(.system(size: 20))
                        Text(module.rawValue)
                            .font(.system(size: 8, weight: .medium))
                    }
                    .sidebarButton(isSelected: selectedModule == module)
                }
            }
            
            Spacer()
            
            // Connection status
            VStack(spacing: 4) {
                Circle()
                    .fill(screenManager.isConnected
                          ? AppTheme.Colors.success
                          : AppTheme.Colors.danger)
                    .frame(width: 10, height: 10)
                Text(screenManager.isConnected ? "TV" : "Sin TV")
                    .font(.system(size: 8))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding(.bottom, 12)
        }
        .frame(width: AppTheme.Layout.sidebarWidth)
        .background(AppTheme.Colors.sidebarBackground)
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Text("VisualDTB")
                .font(AppTheme.Fonts.title(24))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("— \(selectedModule.rawValue)")
                .font(AppTheme.Fonts.heading(18))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Spacer()
            
            // External display indicator
            HStack(spacing: 8) {
                if screenManager.isConnected {
                    Image(systemName: "tv.fill")
                        .foregroundColor(AppTheme.Colors.success)
                    Text(screenManager.externalScreenResolution)
                        .font(AppTheme.Fonts.caption())
                        .foregroundColor(AppTheme.Colors.success)
                } else {
                    Image(systemName: "tv.slash")
                        .foregroundColor(AppTheme.Colors.textMuted)
                    Text("Sin display externo")
                        .font(AppTheme.Fonts.caption())
                        .foregroundColor(AppTheme.Colors.textMuted)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppTheme.Colors.surface)
            .cornerRadius(8)
            
            // Toggle preview
            Button {
                withAnimation { showProjectionPreview.toggle() }
            } label: {
                Image(systemName: showProjectionPreview
                      ? "rectangle.righthalf.inset.filled"
                      : "rectangle.split.2x1")
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.Colors.accent)
            }
            .padding(.leading, 8)
        }
        .padding(.horizontal, AppTheme.Layout.padding)
        .padding(.vertical, 10)
        .background(AppTheme.Colors.primaryDark)
    }
    
    // MARK: - Module Content
    @ViewBuilder
    private var moduleContent: some View {
        switch selectedModule {
        case .bible:
            BibleControlView()
        case .songs:
            SongsControlView()
        case .media:
            MediaControlView()
        case .documents:
            DocumentsControlView()
        case .messages:
            MessagesControlView()
        case .timer:
            TimerControlView()
        case .web:
            WebControlView()
        case .settings:
            SettingsView()
        }
    }
    
    // MARK: - Projection Preview
    private var projectionPreview: some View {
        VStack(spacing: 0) {
            // Preview header
            HStack {
                Image(systemName: "tv")
                    .font(.system(size: 12))
                Text("PREVIEW TV")
                    .font(.system(size: 11, weight: .bold))
                Spacer()
            }
            .foregroundColor(AppTheme.Colors.textMuted)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppTheme.Colors.surface.opacity(0.5))
            
            // Preview content (same as what shows on TV)
            ProjectionRootView()
                .aspectRatio(16/9, contentMode: .fit)
                .cornerRadius(8)
                .padding(8)
                .background(Color.black)
        }
        .background(AppTheme.Colors.surface.opacity(0.3))
    }
    
    // MARK: - Bottom Controls Bar
    private var bottomControlsBar: some View {
        HStack(spacing: 16) {
            // Brightness
            HStack(spacing: 8) {
                Image(systemName: "sun.min.fill")
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .font(.system(size: 14))
                Text("Brillo")
                    .font(AppTheme.Fonts.caption(11))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                Slider(value: $projectionState.brightness, in: 0.1...1.0)
                    .frame(width: 120)
                    .tint(AppTheme.Colors.accent)
                Text("\(Int(projectionState.brightness * 100))%")
                    .font(AppTheme.Fonts.caption(11))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(width: 35)
            }
            
            Divider()
                .frame(height: 20)
                .background(AppTheme.Colors.primaryDark)
            
            // Font size
            HStack(spacing: 8) {
                Image(systemName: "textformat.size")
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .font(.system(size: 14))
                Text("Tamaño")
                    .font(AppTheme.Fonts.caption(11))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                Slider(value: $projectionState.fontSize, in: 20...120)
                    .frame(width: 120)
                    .tint(AppTheme.Colors.accent)
                Text("\(Int(projectionState.fontSize))")
                    .font(AppTheme.Fonts.caption(11))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(width: 30)
            }
            
            Spacer()
            
            // Quick actions
            HStack(spacing: 10) {
                // Preview toggle
                Button {
                    withAnimation { showProjectionPreview.toggle() }
                } label: {
                    Image(systemName: "square.split.2x1.fill")
                        .quickActionButton()
                }
                
                // Go black
                Button {
                    projectionState.goBlack()
                } label: {
                    Image(systemName: "rectangle.slash.fill")
                        .quickActionButton(color: AppTheme.Colors.danger)
                }
                
                // Fullscreen
                Button {
                    // Toggle fullscreen on external
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .quickActionButton(color: AppTheme.Colors.success)
                }
            }
        }
        .padding(.horizontal, AppTheme.Layout.padding)
        .padding(.vertical, 10)
        .background(AppTheme.Colors.primaryDark)
    }
}

// MARK: - Quick Action Button Style
extension Image {
    func quickActionButton(color: Color = AppTheme.Colors.accent) -> some View {
        self
            .font(.system(size: 16))
            .foregroundColor(color)
            .frame(width: 40, height: 32)
            .background(color.opacity(0.15))
            .cornerRadius(8)
    }
}
