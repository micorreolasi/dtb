// MediaControlView.swift
// Media module (Images and Videos) - iPad control panel

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Media Models
struct MediaItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let type: MediaType
    let url: URL?
    let systemImage: String? // For built-in samples
    
    enum MediaType {
        case image
        case video
        case youtube
    }
}

class MediaViewModel: ObservableObject {
    @Published var mediaItems: [MediaItem] = []
    @Published var selectedItem: MediaItem?
    @Published var showImporter = false
    @Published var youtubeUrl = ""
    
    init() {
        loadSamples()
    }
    
    private func loadSamples() {
        mediaItems = [
            MediaItem(name: "Fondo Estrellas", type: .image, url: nil, systemImage: "sparkles"),
            MediaItem(name: "Paisaje Montañas", type: .image, url: nil, systemImage: "mountain.2.fill"),
            MediaItem(name: "Textura Madera", type: .image, url: nil, systemImage: "leaf.fill")
        ]
    }
    
    func importMedia(url: URL) {
        let isVideo = url.pathExtension.lowercased() == "mp4" || url.pathExtension.lowercased() == "mov"
        let item = MediaItem(
            name: url.lastPathComponent,
            type: isVideo ? .video : .image,
            url: url,
            systemImage: nil
        )
        mediaItems.append(item)
    }
}

// MARK: - Media Control View
struct MediaControlView: View {
    @EnvironmentObject var projectionState: ProjectionState
    @StateObject private var vm = MediaViewModel()
    
    let columns = [GridItem(.adaptive(minimum: 120, maximum: 160), spacing: 16)]
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Text("🖼️ Medios")
                    .font(AppTheme.Fonts.heading())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Button {
                    vm.showImporter = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Importar")
                    }
                    .font(AppTheme.Fonts.caption(13))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(AppTheme.Colors.accent)
                    .cornerRadius(8)
                }
            }
            .padding(16)
            
            Divider().background(AppTheme.Colors.primaryDark)
            
            // Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    // YouTube input card
                    youtubeCard
                    
                    // Media Items
                    ForEach(vm.mediaItems) { item in
                        mediaCard(for: item)
                    }
                }
                .padding(16)
            }
        }
        .fileImporter(
            isPresented: $vm.showImporter,
            allowedContentTypes: [.image, .movie],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                vm.importMedia(url: url)
            }
        }
    }
    
    private var youtubeCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)
            
            TextField("URL de YouTube", text: $vm.youtubeUrl)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(AppTheme.Fonts.caption(11))
            
            Button {
                projectionState.currentContent = .webView(url: vm.youtubeUrl)
            } label: {
                Text("Proyectar")
                    .font(AppTheme.Fonts.caption(12))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(vm.youtubeUrl.isEmpty ? AppTheme.Colors.textMuted : .red)
                    .cornerRadius(6)
            }
            .disabled(vm.youtubeUrl.isEmpty)
        }
        .padding(12)
        .background(AppTheme.Colors.surface)
        .cornerRadius(12)
    }
    
    private func mediaCard(for item: MediaItem) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Color(hex: "2A3B5C")
                    .aspectRatio(16/9, contentMode: .fit)
                    .cornerRadius(8)
                
                if let sysImg = item.systemImage {
                    Image(systemName: sysImg)
                        .font(.system(size: 30))
                        .foregroundColor(AppTheme.Colors.accentLight)
                } else if item.type == .video {
                    Image(systemName: "film.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
            }
            
            Text(item.name)
                .font(AppTheme.Fonts.caption(12))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .lineLimit(1)
            
            Button {
                vm.selectedItem = item
                // Simple implementation for sample system images
                if let _ = item.systemImage {
                    // For demo, we just clear and set a colored background
                    // In a real app, this would load the UIImage and pass it to state
                    projectionState.goBlack()
                    projectionState.backgroundColor = Color(hex: "2C3E6B") // Dummy background
                    projectionState.projectMessage(text: "Mostrando imagen: \(item.name)")
                }
            } label: {
                Text("Proyectar")
                    .font(AppTheme.Fonts.caption(12))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(AppTheme.Colors.accent)
                    .cornerRadius(6)
            }
        }
        .padding(12)
        .background(vm.selectedItem?.id == item.id ? AppTheme.Colors.accent.opacity(0.2) : AppTheme.Colors.surface)
        .cornerRadius(12)
    }
}
