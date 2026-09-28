// DocumentsControlView.swift
// PDF and PowerPoint viewer module

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

// MARK: - Document Model
struct AppDocument: Identifiable {
    let id = UUID()
    let title: String
    let type: DocumentType
    let url: URL
    var pageCount: Int = 0
    var dateImported: Date = Date()
    
    enum DocumentType: String {
        case pdf = "PDF"
        case pptx = "PowerPoint"
        
        var icon: String {
            switch self {
            case .pdf: return "doc.richtext.fill"
            case .pptx: return "rectangle.on.rectangle.angled"
            }
        }
        
        var color: Color {
            switch self {
            case .pdf: return Color(hex: "E74C3C")
            case .pptx: return Color(hex: "E67E22")
            }
        }
    }
}

// MARK: - Documents ViewModel
class DocumentsViewModel: ObservableObject {
    @Published var documents: [AppDocument] = []
    @Published var selectedDocument: AppDocument?
    @Published var currentPage: Int = 0
    @Published var pdfDocument: PDFDocument?
    @Published var showImporter = false
    @Published var totalPages: Int = 0
    
    func importDocument(url: URL) {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        
        let ext = url.pathExtension.lowercased()
        
        if ext == "pdf" {
            if let pdf = PDFDocument(url: url) {
                let doc = AppDocument(
                    title: url.deletingPathExtension().lastPathComponent,
                    type: .pdf,
                    url: url,
                    pageCount: pdf.pageCount
                )
                documents.append(doc)
                selectDocument(doc)
                pdfDocument = pdf
                totalPages = pdf.pageCount
            }
        } else if ext == "pptx" {
            let doc = AppDocument(
                title: url.deletingPathExtension().lastPathComponent,
                type: .pptx,
                url: url,
                pageCount: 0
            )
            documents.append(doc)
            selectDocument(doc)
        }
    }
    
    func selectDocument(_ doc: AppDocument) {
        selectedDocument = doc
        currentPage = 0
        
        if doc.type == .pdf {
            pdfDocument = PDFDocument(url: doc.url)
            totalPages = pdfDocument?.pageCount ?? 0
        }
    }
    
    func nextPage() {
        if currentPage < totalPages - 1 {
            currentPage += 1
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
}

// MARK: - Documents Control View
struct DocumentsControlView: View {
    @EnvironmentObject var projectionState: ProjectionState
    @StateObject private var vm = DocumentsViewModel()
    
    var body: some View {
        HStack(spacing: 0) {
            // Document library
            documentLibrary
                .frame(width: 260)
            
            Rectangle()
                .fill(AppTheme.Colors.primaryDark.opacity(0.3))
                .frame(width: 1)
            
            // Document viewer
            documentViewer
        }
        .fileImporter(
            isPresented: $vm.showImporter,
            allowedContentTypes: [.pdf, UTType(filenameExtension: "pptx") ?? .data],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                vm.importDocument(url: url)
            }
        }
    }
    
    // MARK: - Library
    private var documentLibrary: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("📄 Documentos")
                    .font(AppTheme.Fonts.heading(16))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Spacer()
                Button {
                    vm.showImporter = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Importar")
                    }
                    .font(AppTheme.Fonts.caption(12))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.Colors.accent)
                    .cornerRadius(6)
                }
            }
            .padding(12)
            
            Divider().background(AppTheme.Colors.primaryDark)
            
            if vm.documents.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.Colors.textMuted)
                    Text("Sin documentos")
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(AppTheme.Colors.textMuted)
                    Text("Importa un PDF o PowerPoint")
                        .font(AppTheme.Fonts.caption())
                        .foregroundColor(AppTheme.Colors.textMuted)
                    
                    Button {
                        vm.showImporter = true
                    } label: {
                        HStack {
                            Image(systemName: "folder")
                            Text("Abrir Archivos")
                        }
                        .font(AppTheme.Fonts.body())
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(AppTheme.Colors.accent)
                        .cornerRadius(8)
                    }
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(vm.documents) { doc in
                            Button {
                                vm.selectDocument(doc)
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: doc.type.icon)
                                        .font(.system(size: 24))
                                        .foregroundColor(doc.type.color)
                                        .frame(width: 36)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(doc.title)
                                            .font(AppTheme.Fonts.body(14))
                                            .foregroundColor(AppTheme.Colors.textPrimary)
                                            .lineLimit(1)
                                        
                                        Text("\(doc.type.rawValue) • \(doc.pageCount) páginas")
                                            .font(AppTheme.Fonts.caption(11))
                                            .foregroundColor(AppTheme.Colors.textMuted)
                                    }
                                    Spacer()
                                }
                                .padding(10)
                                .background(vm.selectedDocument?.id == doc.id
                                            ? AppTheme.Colors.accent.opacity(0.15)
                                            : AppTheme.Colors.surface)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(10)
                }
            }
        }
        .background(AppTheme.Colors.surface.opacity(0.3))
    }
    
    // MARK: - Viewer
    private var documentViewer: some View {
        VStack(spacing: 0) {
            if let doc = vm.selectedDocument {
                // Toolbar
                HStack {
                    Text(doc.title)
                        .font(AppTheme.Fonts.heading(16))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Spacer()
                    
                    // Page navigation
                    HStack(spacing: 12) {
                        Button { vm.previousPage() } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(vm.currentPage > 0
                                                 ? AppTheme.Colors.accent : AppTheme.Colors.textMuted)
                        }
                        .disabled(vm.currentPage == 0)
                        
                        Text("\(vm.currentPage + 1) / \(vm.totalPages)")
                            .font(AppTheme.Fonts.caption(13))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .frame(width: 70)
                        
                        Button { vm.nextPage() } label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(vm.currentPage < vm.totalPages - 1
                                                 ? AppTheme.Colors.accent : AppTheme.Colors.textMuted)
                        }
                        .disabled(vm.currentPage >= vm.totalPages - 1)
                    }
                    
                    Divider().frame(height: 20)
                    
                    // Project button
                    Button {
                        projectionState.pdfDocument = vm.pdfDocument
                        projectionState.projectPDF(pageIndex: vm.currentPage)
                    } label: {
                        HStack(spacing: 4) {
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
                .padding(12)
                
                Divider().background(AppTheme.Colors.primaryDark)
                
                // Page slider
                if vm.totalPages > 1 {
                    HStack {
                        Text("Página:")
                            .font(AppTheme.Fonts.caption(11))
                            .foregroundColor(AppTheme.Colors.textMuted)
                        Slider(
                            value: Binding(
                                get: { Double(vm.currentPage) },
                                set: { vm.currentPage = Int($0) }
                            ),
                            in: 0...Double(max(vm.totalPages - 1, 1)),
                            step: 1
                        )
                        .tint(AppTheme.Colors.accent)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
                
                // PDF Preview
                if doc.type == .pdf, let pdf = vm.pdfDocument {
                    PDFPreviewView(document: pdf, currentPage: vm.currentPage)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "rectangle.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.Colors.textMuted)
                        Text("Vista previa de PowerPoint")
                            .foregroundColor(AppTheme.Colors.textMuted)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "doc.richtext")
                        .font(.system(size: 50))
                        .foregroundColor(AppTheme.Colors.textMuted)
                    Text("Selecciona o importa un documento")
                        .font(AppTheme.Fonts.heading())
                        .foregroundColor(AppTheme.Colors.textMuted)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

// MARK: - PDF Preview (UIKit wrapper)
struct PDFPreviewView: UIViewRepresentable {
    let document: PDFDocument
    let currentPage: Int
    
    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.document = document
        view.autoScales = true
        view.displayMode = .singlePage
        view.displayDirection = .horizontal
        view.backgroundColor = UIColor(AppTheme.Colors.surface)
        return view
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        if let page = document.page(at: currentPage) {
            pdfView.go(to: page)
        }
    }
}
