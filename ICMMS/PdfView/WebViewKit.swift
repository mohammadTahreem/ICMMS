//
//  WebViewKit.swift
//  ICMMS
//
//  Created by Tahreem on 15/06/21.
//

import Foundation
import SwiftUI

import WebKit

struct WebView : UIViewRepresentable {
    
    let request: URLRequest
    
    func makeUIView(context: Context) -> WKWebView  {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
}
