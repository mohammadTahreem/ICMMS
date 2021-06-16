//
//  DocumentPicker.swift
//  ICMMS
//
//  Created by Tahreem on 14/06/21.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    
    @Binding var fileContent: URL
    @Binding var fileData: Data
    func makeCoordinator() -> DocumentPickerCoordinator {
        return DocumentPickerCoordinator(parent1: self, fileContent: $fileContent, fileData: $fileData)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf], asCopy: true)
        documentPicker.allowsMultipleSelection = false
        documentPicker.delegate = context.coordinator
        return documentPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        //
    }
    
    class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate{
        var parent : DocumentPicker
        @Binding var fileContent: URL
        @Binding var fileData: Data
        
        init(parent1: DocumentPicker, fileContent: Binding<URL>, fileData: Binding<Data>) {
            parent = parent1
            _fileContent = fileContent
            _fileData = fileData
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            fileContent = urls[0]
            do{
                fileData = try Data.init(contentsOf: fileContent)
            }catch let error {
                print(error.localizedDescription)
            }   
        }
    }
    
}


