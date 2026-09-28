// ProjectionState.swift
// Shared state between iPad controls and TV projection

import SwiftUI
import PDFKit
import Combine

// MARK: - Projection Content Types
enum ProjectionContent: Equatable {
    case blank
    case bible(text: String, reference: String, version: String)
    case song(verse: String, title: String, verseNumber: Int)
    case pdfPage(pageIndex: Int)
    case presentation(slideIndex: Int)
    case image(imageName: String)
    case message(text: String)
    case timer(display: String, isRunning: Bool)
    case webView(url: String)
    
    static func == (lhs: ProjectionContent, rhs: ProjectionContent) -> Bool {
        switch (lhs, rhs) {
        case (.blank, .blank): return true
        case (.bible(let t1, let r1, let v1), .bible(let t2, let r2, let v2)):
            return t1 == t2 && r1 == r2 && v1 == v2
        case (.song(let v1, let t1, let n1), .song(let v2, let t2, let n2)):
            return v1 == v2 && t1 == t2 && n1 == n2
        case (.pdfPage(let i1), .pdfPage(let i2)): return i1 == i2
        case (.presentation(let i1), .presentation(let i2)): return i1 == i2
        case (.message(let t1), .message(let t2)): return t1 == t2
        case (.timer(let d1, let r1), .timer(let d2, let r2)): return d1 == d2 && r1 == r2
        default: return false
        }
    }
}

// MARK: - Projection State (Observable)
class ProjectionState: ObservableObject {
    @Published var currentContent: ProjectionContent = .blank
    @Published var fontSize: CGFloat = 48
    @Published var brightness: CGFloat = 1.0
    @Published var backgroundColor: Color = .black
    @Published var textColor: Color = .white
    @Published var showReference: Bool = true
    
    // PDF State
    @Published var pdfDocument: PDFDocument?
    @Published var pdfCurrentPage: Int = 0
    @Published var pdfPageCount: Int = 0
    
    // Image State
    @Published var currentImage: UIImage?
    
    // MARK: - Projection Actions
    func projectBible(text: String, reference: String, version: String) {
        currentContent = .bible(text: text, reference: reference, version: version)
    }
    
    func projectSong(verse: String, title: String, verseNumber: Int) {
        currentContent = .song(verse: verse, title: title, verseNumber: verseNumber)
    }
    
    func projectPDF(pageIndex: Int) {
        pdfCurrentPage = pageIndex
        currentContent = .pdfPage(pageIndex: pageIndex)
    }
    
    func projectSlide(index: Int) {
        currentContent = .presentation(slideIndex: index)
    }
    
    func projectMessage(text: String) {
        currentContent = .message(text: text)
    }
    
    func projectTimer(display: String, isRunning: Bool) {
        currentContent = .timer(display: display, isRunning: isRunning)
    }
    
    func projectImage(named: String) {
        currentContent = .image(imageName: named)
    }
    
    func goBlack() {
        currentContent = .blank
    }
}
