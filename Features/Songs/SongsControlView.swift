// SongsControlView.swift
// Songs module - iPad control panel

import SwiftUI

// MARK: - Song Models
struct Song: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let key: String
    let style: String
    let verses: [SongVerse]
    var isFavorite: Bool = false
}

struct SongVerse: Identifiable, Hashable {
    let id = UUID()
    let number: Int
    let content: String
    let type: String // "verse", "chorus", "bridge"
}

// MARK: - Songs ViewModel
class SongsViewModel: ObservableObject {
    @Published var songs: [Song] = []
    @Published var selectedSong: Song?
    @Published var selectedVerseIndex: Int = 0
    @Published var searchText: String = ""
    @Published var filterStyle: String = "Todos"
    
    let styles = ["Todos", "Alabanza", "Adoración"]
    
    var filteredSongs: [Song] {
        var result = songs
        if filterStyle != "Todos" {
            result = result.filter { $0.style == filterStyle }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.verses.contains { $0.content.localizedCaseInsensitiveContains(searchText) }
            }
        }
        return result
    }
    
    init() { loadSampleSongs() }
    
    func loadSampleSongs() {
        songs = [
            Song(title: "A Ti Mis Manos Alzare", key: "C", style: "Alabanza", verses: [
                SongVerse(number: 1, content: "A ti mis manos alzaré, tu dulce nombre anunciaré\nTu eres mi roca oh Dios,\nno temeré Siento tu fuerza y poder", type: "verse"),
                SongVerse(number: 2, content: "Tu gran amor vive en mi ser, de tu refugio oh Dios proclamaré\nProclamaré tu amor, proclamaré tu perdón.", type: "verse"),
                SongVerse(number: 3, content: "//Y diré, que tú eres Dios mi rey\nTu nombre grande es, eres escudo\nfuerza y poder//.", type: "chorus"),
                SongVerse(number: 4, content: "Hosanna, hosanna Digno de alabar\nHosanna, Hosanna Digno de alabar.", type: "chorus"),
            ]),
            Song(title: "Celebrad A Cristo Celebrad", key: "C", style: "Alabanza", verses: [
                SongVerse(number: 1, content: "Celebrad a Cristo celebrad\nAlzad la voz y su nombre alabad\nCelebrad a Cristo celebrad\nÉl es el Rey, el Rey de reyes", type: "verse"),
            ]),
            Song(title: "Como El Ciervo Brama", key: "D", style: "Adoración", verses: [
                SongVerse(number: 1, content: "Como el ciervo brama por las corrientes de las aguas\nAsí clama por ti, oh Dios, el alma mía", type: "verse"),
                SongVerse(number: 2, content: "Tú solo eres mi fuerza, mi escudo\nA ti solo mi alma te adorará\nTú solo eres mi anhelo, mi único deseo", type: "verse"),
            ]),
            Song(title: "Con Todo Mi Corazón", key: "A", style: "Adoración", verses: [
                SongVerse(number: 1, content: "Con todo mi corazón te exaltaré\nCon todo mi corazón te alabaré\nCon todo mi ser te adoraré Señor", type: "verse"),
            ]),
            Song(title: "Clamando Estoy", key: ".", style: "Adoración", verses: [
                SongVerse(number: 1, content: "Clamando estoy, a ti Señor\nMi corazón anhela más de ti\nRendido estoy, humillado estoy", type: "verse"),
            ]),
            Song(title: "Con Tu Sangre", key: "C", style: "Alabanza", verses: [
                SongVerse(number: 1, content: "Con tu sangre me limpiaste\nCon tu amor me rescataste\nMe diste vida nueva, vida eterna", type: "verse"),
            ]),
        ]
    }
}

// MARK: - Songs Control View
struct SongsControlView: View {
    @EnvironmentObject var projectionState: ProjectionState
    @StateObject private var vm = SongsViewModel()
    
    var body: some View {
        HStack(spacing: 0) {
            // Song list
            songListPanel
                .frame(width: 340)
            
            Rectangle()
                .fill(AppTheme.Colors.primaryDark.opacity(0.3))
                .frame(width: 1)
            
            // Song detail / verses
            songDetailPanel
        }
    }
    
    // MARK: - Song List
    private var songListPanel: some View {
        VStack(spacing: 0) {
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppTheme.Colors.textMuted)
                TextField("Filtrar Canciones - por título o texto", text: $vm.searchText)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Button { } label: {
                    Image(systemName: "plus")
                        .foregroundColor(AppTheme.Colors.accent)
                }
            }
            .padding(10)
            .background(AppTheme.Colors.surface)
            .cornerRadius(8)
            .padding(10)
            
            // Style filter
            HStack(spacing: 8) {
                ForEach(vm.styles, id: \.self) { style in
                    Button {
                        vm.filterStyle = style
                    } label: {
                        Text(style)
                            .font(AppTheme.Fonts.caption(12))
                            .foregroundColor(vm.filterStyle == style ? .white : AppTheme.Colors.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(vm.filterStyle == style
                                        ? AppTheme.Colors.accent : AppTheme.Colors.surface)
                            .cornerRadius(6)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 8)
            
            Divider().background(AppTheme.Colors.primaryDark)
            
            // Table header
            HStack {
                Text("Canciones")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Tono")
                    .frame(width: 50)
                Text("Estilo")
                    .frame(width: 90, alignment: .leading)
            }
            .font(AppTheme.Fonts.caption(11))
            .foregroundColor(AppTheme.Colors.textMuted)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppTheme.Colors.primaryDark.opacity(0.5))
            
            // Song rows
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(vm.filteredSongs) { song in
                        Button {
                            vm.selectedSong = song
                            vm.selectedVerseIndex = 0
                        } label: {
                            HStack {
                                Text(song.title)
                                    .foregroundColor(vm.selectedSong?.id == song.id
                                                     ? AppTheme.Colors.accentLight
                                                     : AppTheme.Colors.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(song.key)
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                    .frame(width: 50)
                                
                                Text(song.style)
                                    .foregroundColor(AppTheme.Colors.accent)
                                    .frame(width: 90, alignment: .leading)
                            }
                            .font(AppTheme.Fonts.body(13))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(vm.selectedSong?.id == song.id
                                        ? AppTheme.Colors.accent.opacity(0.1) : .clear)
                        }
                        
                        Divider().background(AppTheme.Colors.primaryDark.opacity(0.2))
                    }
                }
            }
        }
        .background(AppTheme.Colors.surface.opacity(0.3))
    }
    
    // MARK: - Song Detail
    private var songDetailPanel: some View {
        VStack(spacing: 0) {
            if let song = vm.selectedSong {
                // Song title bar
                HStack {
                    Text(song.title)
                        .font(AppTheme.Fonts.heading(18))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Spacer()
                    
                    Button { } label: {
                        Image(systemName: song.isFavorite ? "star.fill" : "star")
                            .foregroundColor(AppTheme.Colors.warning)
                    }
                }
                .padding(16)
                
                Divider().background(AppTheme.Colors.primaryDark)
                
                // Verses
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(song.verses.enumerated()), id: \.element.id) { index, verse in
                            Button {
                                vm.selectedVerseIndex = index
                                projectionState.projectSong(
                                    verse: verse.content,
                                    title: song.title,
                                    verseNumber: verse.number
                                )
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(verse.number)")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(vm.selectedVerseIndex == index
                                                         ? .white : AppTheme.Colors.accent)
                                        .frame(width: 30)
                                    
                                    Text(verse.content)
                                        .font(AppTheme.Fonts.body(15))
                                        .foregroundColor(vm.selectedVerseIndex == index
                                                         ? .white : AppTheme.Colors.textPrimary)
                                        .multilineTextAlignment(.leading)
                                        .lineSpacing(6)
                                    
                                    Spacer()
                                }
                                .padding(14)
                                .background(vm.selectedVerseIndex == index
                                            ? AppTheme.Colors.accent.opacity(0.3)
                                            : AppTheme.Colors.surface)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(16)
                }
            } else {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 50))
                        .foregroundColor(AppTheme.Colors.textMuted)
                    Text("Selecciona una canción")
                        .font(AppTheme.Fonts.heading())
                        .foregroundColor(AppTheme.Colors.textMuted)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
