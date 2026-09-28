// BibleControlView.swift
// Bible module - iPad control panel

import SwiftUI

// MARK: - Bible Data Models
struct BibleBook: Identifiable, Hashable {
    let id: Int
    let name: String
    let abbreviation: String
    let testament: Testament
    let chapters: Int
    
    enum Testament: String {
        case old = "Antiguo Testamento"
        case new = "Nuevo Testamento"
    }
}

struct BibleVerse: Identifiable, Hashable {
    let id = UUID()
    let number: Int
    let text: String
}

// MARK: - Bible View Model
class BibleViewModel: ObservableObject {
    @Published var selectedBook: BibleBook?
    @Published var selectedChapter: Int = 1
    @Published var selectedVersion: String = "RV1960"
    @Published var verses: [BibleVerse] = []
    @Published var selectedVerses: Set<Int> = []
    @Published var searchText: String = ""
    @Published var testamentFilter: TestamentFilter = .all
    
    enum TestamentFilter: String, CaseIterable {
        case all = "Toda"
        case old = "A.T."
        case new = "N.T."
    }
    
    let versions = ["RV1960", "NVI", "DHH", "NTV", "KJV", "LBLA", "RVR2009"]
    
    let books: [BibleBook] = [
        // Antiguo Testamento
        BibleBook(id: 1, name: "Génesis", abbreviation: "Gn", testament: .old, chapters: 50),
        BibleBook(id: 2, name: "Éxodo", abbreviation: "Ex", testament: .old, chapters: 40),
        BibleBook(id: 3, name: "Levítico", abbreviation: "Lv", testament: .old, chapters: 27),
        BibleBook(id: 4, name: "Números", abbreviation: "Nm", testament: .old, chapters: 36),
        BibleBook(id: 5, name: "Deuteronomio", abbreviation: "Dt", testament: .old, chapters: 34),
        BibleBook(id: 6, name: "Josué", abbreviation: "Jos", testament: .old, chapters: 24),
        BibleBook(id: 7, name: "Jueces", abbreviation: "Jue", testament: .old, chapters: 21),
        BibleBook(id: 8, name: "Rut", abbreviation: "Rt", testament: .old, chapters: 4),
        BibleBook(id: 9, name: "1 Samuel", abbreviation: "1S", testament: .old, chapters: 31),
        BibleBook(id: 10, name: "2 Samuel", abbreviation: "2S", testament: .old, chapters: 24),
        BibleBook(id: 11, name: "1 Reyes", abbreviation: "1R", testament: .old, chapters: 22),
        BibleBook(id: 12, name: "2 Reyes", abbreviation: "2R", testament: .old, chapters: 25),
        BibleBook(id: 13, name: "1 Crónicas", abbreviation: "1Cr", testament: .old, chapters: 29),
        BibleBook(id: 14, name: "2 Crónicas", abbreviation: "2Cr", testament: .old, chapters: 36),
        BibleBook(id: 15, name: "Esdras", abbreviation: "Esd", testament: .old, chapters: 10),
        BibleBook(id: 16, name: "Nehemías", abbreviation: "Neh", testament: .old, chapters: 13),
        BibleBook(id: 17, name: "Ester", abbreviation: "Est", testament: .old, chapters: 10),
        BibleBook(id: 18, name: "Job", abbreviation: "Job", testament: .old, chapters: 42),
        BibleBook(id: 19, name: "Salmos", abbreviation: "Sal", testament: .old, chapters: 150),
        BibleBook(id: 20, name: "Proverbios", abbreviation: "Pr", testament: .old, chapters: 31),
        BibleBook(id: 21, name: "Eclesiastés", abbreviation: "Ec", testament: .old, chapters: 12),
        BibleBook(id: 22, name: "Cantares", abbreviation: "Cnt", testament: .old, chapters: 8),
        BibleBook(id: 23, name: "Isaías", abbreviation: "Is", testament: .old, chapters: 66),
        BibleBook(id: 24, name: "Jeremías", abbreviation: "Jer", testament: .old, chapters: 52),
        BibleBook(id: 25, name: "Lamentaciones", abbreviation: "Lm", testament: .old, chapters: 5),
        BibleBook(id: 26, name: "Ezequiel", abbreviation: "Ez", testament: .old, chapters: 48),
        BibleBook(id: 27, name: "Daniel", abbreviation: "Dn", testament: .old, chapters: 12),
        BibleBook(id: 28, name: "Oseas", abbreviation: "Os", testament: .old, chapters: 14),
        BibleBook(id: 29, name: "Joel", abbreviation: "Jl", testament: .old, chapters: 3),
        BibleBook(id: 30, name: "Amós", abbreviation: "Am", testament: .old, chapters: 9),
        BibleBook(id: 31, name: "Abdías", abbreviation: "Abd", testament: .old, chapters: 1),
        BibleBook(id: 32, name: "Jonás", abbreviation: "Jon", testament: .old, chapters: 4),
        BibleBook(id: 33, name: "Miqueas", abbreviation: "Mi", testament: .old, chapters: 7),
        BibleBook(id: 34, name: "Nahúm", abbreviation: "Nah", testament: .old, chapters: 3),
        BibleBook(id: 35, name: "Habacuc", abbreviation: "Hab", testament: .old, chapters: 3),
        BibleBook(id: 36, name: "Sofonías", abbreviation: "Sof", testament: .old, chapters: 3),
        BibleBook(id: 37, name: "Hageo", abbreviation: "Hag", testament: .old, chapters: 2),
        BibleBook(id: 38, name: "Zacarías", abbreviation: "Zac", testament: .old, chapters: 14),
        BibleBook(id: 39, name: "Malaquías", abbreviation: "Mal", testament: .old, chapters: 4),
        // Nuevo Testamento
        BibleBook(id: 40, name: "Mateo", abbreviation: "Mt", testament: .new, chapters: 28),
        BibleBook(id: 41, name: "Marcos", abbreviation: "Mr", testament: .new, chapters: 16),
        BibleBook(id: 42, name: "Lucas", abbreviation: "Lc", testament: .new, chapters: 24),
        BibleBook(id: 43, name: "Juan", abbreviation: "Jn", testament: .new, chapters: 21),
        BibleBook(id: 44, name: "Hechos", abbreviation: "Hch", testament: .new, chapters: 28),
        BibleBook(id: 45, name: "Romanos", abbreviation: "Ro", testament: .new, chapters: 16),
        BibleBook(id: 46, name: "1 Corintios", abbreviation: "1Co", testament: .new, chapters: 16),
        BibleBook(id: 47, name: "2 Corintios", abbreviation: "2Co", testament: .new, chapters: 13),
        BibleBook(id: 48, name: "Gálatas", abbreviation: "Gá", testament: .new, chapters: 6),
        BibleBook(id: 49, name: "Efesios", abbreviation: "Ef", testament: .new, chapters: 6),
        BibleBook(id: 50, name: "Filipenses", abbreviation: "Fil", testament: .new, chapters: 4),
        BibleBook(id: 51, name: "Colosenses", abbreviation: "Col", testament: .new, chapters: 4),
        BibleBook(id: 52, name: "1 Tesalonicenses", abbreviation: "1Ts", testament: .new, chapters: 5),
        BibleBook(id: 53, name: "2 Tesalonicenses", abbreviation: "2Ts", testament: .new, chapters: 3),
        BibleBook(id: 54, name: "1 Timoteo", abbreviation: "1Ti", testament: .new, chapters: 6),
        BibleBook(id: 55, name: "2 Timoteo", abbreviation: "2Ti", testament: .new, chapters: 4),
        BibleBook(id: 56, name: "Tito", abbreviation: "Tit", testament: .new, chapters: 3),
        BibleBook(id: 57, name: "Filemón", abbreviation: "Flm", testament: .new, chapters: 1),
        BibleBook(id: 58, name: "Hebreos", abbreviation: "He", testament: .new, chapters: 13),
        BibleBook(id: 59, name: "Santiago", abbreviation: "Stg", testament: .new, chapters: 5),
        BibleBook(id: 60, name: "1 Pedro", abbreviation: "1P", testament: .new, chapters: 5),
        BibleBook(id: 61, name: "2 Pedro", abbreviation: "2P", testament: .new, chapters: 3),
        BibleBook(id: 62, name: "1 Juan", abbreviation: "1Jn", testament: .new, chapters: 5),
        BibleBook(id: 63, name: "2 Juan", abbreviation: "2Jn", testament: .new, chapters: 1),
        BibleBook(id: 64, name: "3 Juan", abbreviation: "3Jn", testament: .new, chapters: 1),
        BibleBook(id: 65, name: "Judas", abbreviation: "Jud", testament: .new, chapters: 1),
        BibleBook(id: 66, name: "Apocalipsis", abbreviation: "Ap", testament: .new, chapters: 22),
    ]
    
    var filteredBooks: [BibleBook] {
        var result = books
        if testamentFilter == .old {
            result = result.filter { $0.testament == .old }
        } else if testamentFilter == .new {
            result = result.filter { $0.testament == .new }
        }
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return result
    }
    
    func loadChapter(book: BibleBook, chapter: Int) {
        // Demo data — in production, load from SQLite/JSON
        selectedBook = book
        selectedChapter = chapter
        selectedVerses = []
        
        // Sample verses for Mateo 8
        if book.name == "Mateo" && chapter == 8 {
            verses = [
                BibleVerse(number: 1, text: "Cuando descendió Jesús del monte, le seguía mucha gente."),
                BibleVerse(number: 2, text: "Y he aquí vino un leproso y se postró ante él, diciendo: Señor, si quieres, puedes limpiarme."),
                BibleVerse(number: 3, text: "Jesús extendió la mano y le tocó, diciendo: Quiero; sé limpio. Y al instante su lepra desapareció."),
                BibleVerse(number: 4, text: "Entonces Jesús le dijo: Mira, no lo digas a nadie; sino vé, muéstrate al sacerdote, y presenta la ofrenda que ordenó Moisés, para testimonio a ellos."),
                BibleVerse(number: 5, text: "Entrando Jesús en Capernaum, vino a él un centurión, rogándole,"),
                BibleVerse(number: 6, text: "y diciendo: Señor, mi criado está postrado en casa, paralítico, gravemente atormentado."),
                BibleVerse(number: 7, text: "Y Jesús le dijo: Yo iré y le sanaré."),
                BibleVerse(number: 8, text: "Respondió el centurión y dijo: Señor, no soy digno de que entres bajo mi techo; solamente di la palabra, y mi criado sanará."),
                BibleVerse(number: 9, text: "Porque también yo soy hombre bajo autoridad, y tengo bajo mis órdenes soldados; y digo a éste: Vé, y va; y al otro: Ven, y viene; y a mi siervo: Haz esto, y lo hace."),
                BibleVerse(number: 10, text: "Al oírlo Jesús, se maravilló, y dijo a los que le seguían: De cierto os digo, que ni aun en Israel he hallado tanta fe."),
            ]
        } else {
            // Generate sample verses for any other chapter
            verses = (1...Int.random(in: 15...35)).map { num in
                BibleVerse(number: num, text: "Versículo \(num) de \(book.name) capítulo \(chapter). Este es un texto de ejemplo que será reemplazado con el texto bíblico real de la base de datos.")
            }
        }
    }
    
    func getSelectedText() -> String {
        if selectedVerses.isEmpty { return "" }
        return verses
            .filter { selectedVerses.contains($0.number) }
            .sorted { $0.number < $1.number }
            .map { "\($0.number) \($0.text)" }
            .joined(separator: "\n")
    }
    
    func getReference() -> String {
        guard let book = selectedBook else { return "" }
        if selectedVerses.isEmpty { return "\(book.name) \(selectedChapter)" }
        let sorted = selectedVerses.sorted()
        if sorted.count == 1 {
            return "\(book.name) \(selectedChapter):\(sorted[0])"
        }
        return "\(book.name) \(selectedChapter):\(sorted.first!)-\(sorted.last!)"
    }
}

// MARK: - Bible Control View
struct BibleControlView: View {
    @EnvironmentObject var projectionState: ProjectionState
    @StateObject private var vm = BibleViewModel()
    @State private var showBookList = true
    
    var body: some View {
        HStack(spacing: 0) {
            // Book/Chapter selector
            if showBookList {
                bookAndChapterSelector
                    .frame(width: 320)
                    .transition(.move(edge: .leading))
            }
            
            // Verse list
            verseListView
        }
        .onAppear {
            // Load default chapter
            if vm.selectedBook == nil {
                vm.loadChapter(book: vm.books[39], chapter: 8) // Mateo 8
            }
        }
    }
    
    // MARK: - Book & Chapter Selector
    private var bookAndChapterSelector: some View {
        VStack(spacing: 0) {
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppTheme.Colors.textMuted)
                TextField("Filtrar Libros", text: $vm.searchText)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                if !vm.searchText.isEmpty {
                    Button { vm.searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.textMuted)
                    }
                }
            }
            .padding(10)
            .background(AppTheme.Colors.surface)
            .cornerRadius(8)
            .padding(10)
            
            // Testament filter
            HStack(spacing: 0) {
                ForEach(BibleViewModel.TestamentFilter.allCases, id: \.self) { filter in
                    Button {
                        vm.testamentFilter = filter
                    } label: {
                        Text(filter.rawValue)
                            .font(AppTheme.Fonts.caption(12))
                            .foregroundColor(vm.testamentFilter == filter
                                             ? .white : AppTheme.Colors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(vm.testamentFilter == filter
                                        ? AppTheme.Colors.primaryLight : .clear)
                            .cornerRadius(6)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 8)
            
            // Version selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(vm.versions, id: \.self) { version in
                        Button {
                            vm.selectedVersion = version
                        } label: {
                            Text(version)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(vm.selectedVersion == version
                                                 ? .white : AppTheme.Colors.textMuted)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(vm.selectedVersion == version
                                            ? AppTheme.Colors.accent : AppTheme.Colors.surface)
                                .cornerRadius(6)
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
            .padding(.bottom, 8)
            
            Divider().background(AppTheme.Colors.primaryDark)
            
            // Book list + Chapter grid
            if let selectedBook = vm.selectedBook {
                // Chapter grid
                VStack(spacing: 8) {
                    HStack {
                        Button {
                            vm.selectedBook = nil
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Libros")
                            }
                            .font(AppTheme.Fonts.caption())
                            .foregroundColor(AppTheme.Colors.accent)
                        }
                        Spacer()
                        Text("Capítulos de: \(selectedBook.name)")
                            .font(AppTheme.Fonts.caption())
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 8)
                    
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 6)
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(1...selectedBook.chapters, id: \.self) { chapter in
                            Button {
                                vm.loadChapter(book: selectedBook, chapter: chapter)
                            } label: {
                                Text("\(chapter)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(vm.selectedChapter == chapter
                                                     ? .white : AppTheme.Colors.textSecondary)
                                    .frame(width: 40, height: 36)
                                    .background(vm.selectedChapter == chapter
                                                 ? AppTheme.Colors.accent : AppTheme.Colors.surface)
                                    .cornerRadius(6)
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.bottom, 10)
                
            } else {
                // Book list
                ScrollView {
                    HStack(alignment: .top, spacing: 0) {
                        // Old Testament
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Antiguo Testamento")
                                .font(AppTheme.Fonts.caption(11))
                                .foregroundColor(AppTheme.Colors.accent)
                                .padding(.bottom, 4)
                            
                            ForEach(vm.filteredBooks.filter { $0.testament == .old }) { book in
                                bookButton(book)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // New Testament
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Nuevo Testamento")
                                .font(AppTheme.Fonts.caption(11))
                                .foregroundColor(AppTheme.Colors.accent)
                                .padding(.bottom, 4)
                            
                            ForEach(vm.filteredBooks.filter { $0.testament == .new }) { book in
                                bookButton(book)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(10)
                }
            }
        }
        .background(AppTheme.Colors.surface.opacity(0.3))
    }
    
    private func bookButton(_ book: BibleBook) -> some View {
        Button {
            vm.selectedBook = book
        } label: {
            Text(book.name)
                .font(AppTheme.Fonts.body(13))
                .foregroundColor(AppTheme.Colors.accentLight)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
                .padding(.horizontal, 6)
        }
    }
    
    // MARK: - Verse List
    private var verseListView: some View {
        VStack(spacing: 0) {
            // Chapter header
            if let book = vm.selectedBook {
                HStack {
                    Button { showBookList.toggle() } label: {
                        Image(systemName: showBookList ? "sidebar.left" : "sidebar.right")
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                    
                    Text("\(book.name) \(vm.selectedChapter)")
                        .font(AppTheme.Fonts.heading(20))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Spacer()
                    
                    // Project selected button
                    if !vm.selectedVerses.isEmpty {
                        Button {
                            projectionState.projectBible(
                                text: vm.getSelectedText(),
                                reference: vm.getReference(),
                                version: vm.selectedVersion
                            )
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Proyectar")
                            }
                            .font(AppTheme.Fonts.caption(13))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(AppTheme.Colors.accent)
                            .cornerRadius(8)
                        }
                    }
                    
                    Text(vm.selectedVersion)
                        .font(AppTheme.Fonts.caption(12))
                        .foregroundColor(AppTheme.Colors.textMuted)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.Colors.surface)
                        .cornerRadius(6)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            
            Divider().background(AppTheme.Colors.primaryDark)
            
            // Verses
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(vm.verses) { verse in
                        Button {
                            if vm.selectedVerses.contains(verse.number) {
                                vm.selectedVerses.remove(verse.number)
                            } else {
                                vm.selectedVerses.insert(verse.number)
                            }
                        } label: {
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(verse.number)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppTheme.Colors.accent)
                                    .frame(width: 28, alignment: .trailing)
                                
                                Text(verse.text)
                                    .font(AppTheme.Fonts.body(15))
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                    .multilineTextAlignment(.leading)
                                    .lineSpacing(4)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(vm.selectedVerses.contains(verse.number)
                                        ? AppTheme.Colors.accent.opacity(0.15)
                                        : .clear)
                        }
                        
                        // Quick project on double tap
                        .onTapGesture(count: 2) {
                            vm.selectedVerses = [verse.number]
                            projectionState.projectBible(
                                text: "\(verse.number) \(verse.text)",
                                reference: "\(vm.selectedBook?.name ?? "") \(vm.selectedChapter):\(verse.number)",
                                version: vm.selectedVersion
                            )
                        }
                        
                        Divider()
                            .background(AppTheme.Colors.primaryDark.opacity(0.3))
                            .padding(.leading, 56)
                    }
                }
            }
        }
    }
}
