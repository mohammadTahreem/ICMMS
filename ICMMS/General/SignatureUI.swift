//
//  SignatureView.swift
//  APITestApp
//
//  Created by Mohammad Tahreem Qadri on 25/03/21.
//

import SwiftUI
import PencilKit

struct PencilKitRepresentable : UIViewRepresentable {
    let canvas = PKCanvasView(frame: .init(x: 0, y: 0, width: 400, height: 80))
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.tool = PKInkingTool(.pen, color: .black, width: 10)
        //#if targetEnvironment(simulator)
        canvas.drawingPolicy = .anyInput
        //#endif
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

struct SignatureUI: View {
    let canvasView = PencilKitRepresentable()
    let imgRect = CGRect(x: 0, y: 0, width: 400.0, height: 100.0)
    
    var body: some View {
        VStack {
            canvasView.frame(height: 100.0)
                .border(Color.gray, width: 5)
                
        }
    }
    
    
}
