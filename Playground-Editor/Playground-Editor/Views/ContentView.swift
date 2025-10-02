import SwiftUI

struct ContentView: View {
    @State private var files: [LocalFileItem] = []
    @State private var selectedFile: LocalFileItem?
    @State private var code: String = ""
    let fileHelper = FileManagerHelper()
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedFile: $selectedFile, loadFile: { file in
                do {
                              code = try String(contentsOf: file.url)
                          } catch {
                              code = "Failed to load file: \(error)"
                          }
            })
        } detail: {
            EditorWebPreview(code: $code, selectedFile: $selectedFile)
        }
    }
}

