import SwiftUI
import WebKit

struct WebPreview: View {
    @State private var webViewWidth: CGFloat = 500
    
    var body: some View {
       
        ServerWebView(url: URL(string: "http://127.0.0.1:8080")!)
            .frame(minWidth: 300, idealWidth: 400,maxWidth: .infinity)
            .accessibilityIdentifier("webView")
    }
}

struct ServerWebView: NSViewRepresentable {
    let url: URL
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        webView.load(URLRequest(url: url))
        return webView
    }
    func updateNSView(_ nsView: WKWebView, context: Context) { nsView.load(URLRequest(url: url)) }
}
