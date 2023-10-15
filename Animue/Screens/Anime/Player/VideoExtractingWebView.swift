//
//  VideoExtractingWebView.swift
//  Animue
//
//  Created by Artem Raykh on 15.10.2023.
//

import SwiftUI
import WebKit

struct VideoExtractingWebView: UIViewRepresentable {
    
    let url: URL
    
    let handle: (Result<URL, Error>) -> ()

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        private let parent: VideoExtractingWebView
        
        private let javascript = """
            var video = document.querySelector('video');
            if (video) {
                var videoURL = video.currentSrc;
                videoURL;
            }
        """
        
        init(_ parent: VideoExtractingWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            getUrl(webView: webView)
        }
        
        private func getUrl(webView: WKWebView) {
            
            webView.evaluateJavaScript(javascript) { [parent] result, error in
                if let result = result as? String,
                   let url = URL(string: result)
                {
                    parent.handle(.success(url))
                } else {
                    parent.handle(.failure(AnimeError(message: "Failed to parse episode URL")))
                }
            }
        }
    }
}


