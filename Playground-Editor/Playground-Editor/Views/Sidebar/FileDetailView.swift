import SwiftUI
import Foundation

struct FileDetailView: View {
    let file: LocalFileItem
    @State private var content: String = ""

    private let fileHelper = FileManagerHelper()

    var body: some View {
        ScrollView {
            TextEditor(text: $content)
                .font(.system(.body, design: .monospaced))
                .padding()
        }
        .navigationTitle(file.url.lastPathComponent)
        .onAppear {
            // Use the refactored helper directly with LocalFileItem
            content = fileHelper.readFile(file) ?? ""
        }
        .onDisappear {
            fileHelper.writeFile(file, content: content)
        }
    }
}
