//
//  SignatureView.swift
//  APITestApp
//
//  Created by Mohammad Tahreem Qadri on 25/03/21.
//

import SwiftUI
import PencilKit

struct PencilKitRepresentable : UIViewRepresentable {
    @Binding var canvas: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.tool = PKInkingTool(.pen, color: .black, width: 10)
        canvas.drawingPolicy = .anyInput
        return canvas
    }
    func updateUIView(_ uiView: PKCanvasView, context: Context) { }
    
    func checkIfEmpty() -> Bool {
        if canvas.drawing.strokes.isEmpty {
            return true
        }else{
            return false
        }
    }
}
