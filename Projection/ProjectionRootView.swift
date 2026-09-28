// ProjectionRootView.swift
// This view renders on the external TV/projector screen

import SwiftUI
import PDFKit

struct ProjectionRootView: View {
    @EnvironmentObject var state: ProjectionState
    
    var body: some View {
        ZStack {
            // Background
            state.backgroundColor
                .ignoresSafeArea()
            
            // Content
            Group {
                switch state.currentContent {
                case .blank:
                    Color.black.ignoresSafeArea()
                    
                case .bible(let text, let reference, let version):
                    BibleProjectionContent(
                        text: text,
                        reference: reference,
                        version: version,
                        fontSize: state.fontSize,
                        showReference: state.showReference
                    )
                    
                case .song(let verse, let title, let verseNumber):
                    SongProjectionContent(
                        verse: verse,
                        title: title,
                        verseNumber: verseNumber,
                        fontSize: state.fontSize
                    )
                    
                case .pdfPage(let pageIndex):
                    PDFProjectionContent(
                        document: state.pdfDocument,
                        pageIndex: pageIndex
                    )
                    
                case .presentation(let slideIndex):
                    SlideProjectionContent(slideIndex: slideIndex)
                    
                case .image(let imageName):
                    ImageProjectionContent(
                        imageName: imageName,
                        image: state.currentImage
                    )
                    
                case .message(let text):
                    MessageProjectionContent(
                        text: text,
                        fontSize: state.fontSize
                    )
                    
                case .timer(let display, let isRunning):
                    TimerProjectionContent(
                        display: display,
                        isRunning: isRunning
                    )
                    
                case .webView(let url):
                    Text(url)
                        .foregroundColor(.white)
                }
            }
            .opacity(state.brightness)
        }
        .animation(.easeInOut(duration: 0.3), value: state.currentContent)
    }
}

// MARK: - Bible Projection
struct BibleProjectionContent: View {
    let text: String
    let reference: String
    let version: String
    let fontSize: CGFloat
    let showReference: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text(text)
                .font(.system(size: fontSize, weight: .regular, design: .serif))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(fontSize * 0.3)
                .padding(.horizontal, 60)
            
            if showReference {
                HStack(spacing: 12) {
                    Text(reference)
                        .font(.system(size: fontSize * 0.5, weight: .semibold))
                        .foregroundColor(Color(hex: "6BB5FF"))
                    
                    Text(version)
                        .font(.system(size: fontSize * 0.35, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Song Projection
struct SongProjectionContent: View {
    let verse: String
    let title: String
    let verseNumber: Int
    let fontSize: CGFloat
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text(verse)
                .font(.system(size: fontSize, weight: .regular))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(fontSize * 0.35)
                .padding(.horizontal, 60)
            
            HStack {
                Text(title)
                    .font(.system(size: fontSize * 0.35, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                
                Text("— Estrofa \(verseNumber)")
                    .font(.system(size: fontSize * 0.3, weight: .regular))
                    .foregroundColor(.white.opacity(0.3))
            }
            
            Spacer()
        }
    }
}

// MARK: - PDF Projection
struct PDFProjectionContent: View {
    let document: PDFDocument?
    let pageIndex: Int
    
    var body: some View {
        if let doc = document, pageIndex < doc.pageCount,
           let page = doc.page(at: pageIndex) {
            PDFPageImageView(page: page)
        } else {
            VStack {
                Image(systemName: "doc.questionmark")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.3))
                Text("Sin documento")
                    .foregroundColor(.white.opacity(0.3))
            }
        }
    }
}

struct PDFPageImageView: View {
    let page: PDFPage
    
    var body: some View {
        GeometryReader { geo in
            if let image = renderPage(page: page, size: geo.size) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    func renderPage(page: PDFPage, size: CGSize) -> UIImage? {
        let pageRect = page.bounds(for: .mediaBox)
        let scale = min(size.width / pageRect.width, size.height / pageRect.height)
        let scaledSize = CGSize(width: pageRect.width * scale, height: pageRect.height * scale)
        
        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        return renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: scaledSize))
            
            ctx.cgContext.translateBy(x: 0, y: scaledSize.height)
            ctx.cgContext.scaleBy(x: scale, y: -scale)
            
            page.draw(with: .mediaBox, to: ctx.cgContext)
        }
    }
}

// MARK: - Slide Projection
struct SlideProjectionContent: View {
    let slideIndex: Int
    
    var body: some View {
        VStack {
            Image(systemName: "rectangle.on.rectangle")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.5))
            Text("Diapositiva \(slideIndex + 1)")
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Image Projection
struct ImageProjectionContent: View {
    let imageName: String
    let image: UIImage?
    
    var body: some View {
        if let img = image {
            Image(uiImage: img)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        } else if !imageName.isEmpty {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        } else {
            Color.black
        }
    }
}

// MARK: - Message Projection
struct MessageProjectionContent: View {
    let text: String
    let fontSize: CGFloat
    @State private var offset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Color.black
                
                Text(text)
                    .font(.system(size: fontSize * 0.6, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "1B2A4A"), Color(hex: "2C3E6B")],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .offset(x: offset)
                    .onAppear {
                        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                            offset = -geo.size.width
                        }
                    }
            }
        }
    }
}

// MARK: - Timer Projection
struct TimerProjectionContent: View {
    let display: String
    let isRunning: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text(display)
                .font(.system(size: 120, weight: .thin, design: .monospaced))
                .foregroundColor(isRunning ? .white : .white.opacity(0.5))
            
            Circle()
                .fill(isRunning ? Color(hex: "27AE60") : Color(hex: "E74C3C"))
                .frame(width: 16, height: 16)
        }
    }
}
