import SwiftUI
import Combine

struct EditorWebPreview: View {
    @Binding var code: String
    @Binding var selectedFile: LocalFileItem?

    @State private var showPreview = false
    @State private var previewWidth: CGFloat = 500
    @State private var lastWidth: CGFloat = 500

    @State private var fileManager = FileManagerHelper()
    @State private var currentFileURL: URL?
    @State private var saveCancellable: AnyCancellable?
    @State private var originalCode: String = ""  // NEW: store original content

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                CodeEditorView(
                    code: $code,
                    saveFile: { debounceSave() },
                    fileName: selectedFile?.url.lastPathComponent
                )
                .frame(width: showPreview ? geo.size.width - previewWidth : geo.size.width)

                if showPreview {
                    ResizableDivider(width: $previewWidth, maxWidth: geo.size.width)

                    WebPreview()
                        .frame(width: previewWidth)
                        .background(Color.secondary)
                }
            }
            .animation(.easeInOut, value: showPreview)
            .toolbar {
                PreviewToggleButton(
                    showPreview: $showPreview,
                    previewWidth: $previewWidth,
                    lastWidth: $lastWidth
                )
            }
            .onAppear {
                loadSelectedFile()
            }
            .onChange(of: selectedFile) { _ in
                loadSelectedFile()
            }
        }
    }

    private func loadSelectedFile() {
        guard let file = selectedFile else { return }
        currentFileURL = file.url
        code = fileManager.readFile(file) ?? ""
        originalCode = code   // store original content to prevent accidental overwrite
    }

    private func saveToDisk() {
        guard let url = currentFileURL else { return }
        try? code.write(to: url, atomically: true, encoding: .utf8)
        originalCode = code   // update original after save
    }

    private func debounceSave() {
        guard code != originalCode else { return } // only save if user edited
        saveCancellable?.cancel()
        saveCancellable = Just(())
            .delay(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { _ in
                saveToDisk()
            }
    }
}



