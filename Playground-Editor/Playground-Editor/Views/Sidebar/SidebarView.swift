import SwiftUI

struct SidebarView: View {
    @State private var files: [LocalFileItem] = []
    @Binding var selectedFile: LocalFileItem?
    let loadFile: (LocalFileItem) -> Void
    private let fileHelper = FileManagerHelper()

    var body: some View {
        FileListView(files: files, selectedFile: $selectedFile, loadFile: loadFile)
            .onAppear {
                files = fileHelper.buildTree()
            }
            .navigationTitle("Files")
    }
}
