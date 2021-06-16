//
//  PDFKit.swift
//  ICMMS
//
//  Created by Tahreem on 14/06/21.
//

import SwiftUI
import PDFKit

struct PDFKitRepresentedView: UIViewRepresentable {
    
    let pdfView = PDFView()
    
    let data: Data
    init(_ data: Data) {
        self.data = data
    }
    
    func makeUIView(context: UIViewRepresentableContext<PDFKitRepresentedView>) -> PDFKitRepresentedView.UIViewType {
        pdfView.document = PDFDocument(data: data)
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .horizontal
        return pdfView
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PDFKitRepresentedView>) {
        pdfView.document = PDFDocument(data: data)
    }
    
}
