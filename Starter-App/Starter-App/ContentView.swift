import SwiftUI
import WebKit

struct ContentView: View {
    @State private var files: [LocalFileItem] = []
    @State private var selectedFile: LocalFileItem?
    @State private var code: String = ""
    @State private var sidebarWidth: CGFloat = 220
    @State private var editorWidth: CGFloat = 400
    @State private var sidebarCollapsed: Bool = false

    private let fileManager = FileManager.default
    private let workingFolder: URL

    init() {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = documentsURL.appendingPathComponent("MyProjectFiles")
        self.workingFolder = folder

        if !fileManager.fileExists(atPath: folder.path) {
            try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        print("Working folder path: \(folder.path)")
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                if !sidebarCollapsed {
                    Text("Working folder: \(workingFolder.lastPathComponent)")
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(sidebarCollapsed ? "▶︎" : "◀︎") {
                    sidebarCollapsed.toggle()
                }
                Button("New File") {
                    createNewFile()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)

            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // Sidebar
                    if !sidebarCollapsed {
                        List {
                            OutlineGroup(files, children: \.children) { item in
                                HStack {
                                    Image(systemName: item.iconName)
                                    Text(item.url.lastPathComponent)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                }
                                .contentShape(Rectangle())
                                .background(selectedFile?.id == item.id ? Color.blue.opacity(0.2) : Color.clear)
                                .onTapGesture {
                                    if !item.isDirectory {
                                        selectedFile = item
                                        loadFile(item)
                                    }
                                }
                            }
                        }
                        .frame(width: sidebarWidth)
                        .border(Color.gray)
                    }

                    // Divider: Sidebar ↔ Editor
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 5)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let totalWidth = geometry.size.width
                                    let minSidebar: CGFloat = 100
                                    let maxSidebar: CGFloat = totalWidth - 500
                                    sidebarWidth = min(max(sidebarWidth + value.translation.width, minSidebar), maxSidebar)
                                }
                        )
                        .onHover { hovering in
                            NSCursor.resizeLeftRight.set()
                        }

                    // TextEditor
                    TextEditor(text: $code)
                        .padding(.top, 6)
                        .frame(width: editorWidth)
                        .border(Color.gray)
                        .onChange(of: code) { saveFile() }

                    // Divider: Editor ↔ WebView
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 8)
                        .overlay(
                            Rectangle()
                                .fill(Color.gray.opacity(0.6))
                                .frame(width: 2)
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let totalWidth = geometry.size.width
                                    let minEditor: CGFloat = 100
                                    let minWeb: CGFloat = 300
                                    editorWidth = min(max(editorWidth + value.translation.width, minEditor), totalWidth - sidebarWidth - minWeb)
                                }
                        )
                        .onHover { hovering in
                            NSCursor.resizeLeftRight.set()
                        }

                    // WebView
                    ServerWebView(url: URL(string: "http://127.0.0.1:8080")!)
                        .frame(minWidth: 300)
                }
            }
        }
        .onAppear { loadFiles() }
    }

    // MARK: - File loading
    private func loadFiles() { files = buildTree(at: workingFolder) }

    private func buildTree(at url: URL) -> [LocalFileItem] {
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles]) else {
            return []
        }
        return contents.map { fileURL in
            var isDir: ObjCBool = false
            fm.fileExists(atPath: fileURL.path, isDirectory: &isDir)
            let children = isDir.boolValue ? buildTree(at: fileURL) : nil
            return LocalFileItem(url: fileURL, children: children)
        }
    }

    // MARK: - File content
    private func loadFile(_ file: LocalFileItem) {
        do { code = try String(contentsOf: file.url, encoding: .utf8) }
        catch { print("Failed to load file:", error) }
    }

    private func saveFile() {
        guard let file = selectedFile else { return }
        do { try code.write(to: file.url, atomically: true, encoding: .utf8) }
        catch { print("Failed to save file:", error) }
    }

    private func createNewFile() {
        let fileName = "new_file_\(files.count + 1).txt"
        let newFileURL = workingFolder.appendingPathComponent(fileName)
        try? "".write(to: newFileURL, atomically: true, encoding: .utf8)
        loadFiles()
    }
}

// MARK: - LocalFileItem
struct LocalFileItem: Identifiable {
    let id = UUID()
    let url: URL
    var children: [LocalFileItem]? = nil
    var isDirectory: Bool { (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false }

    var iconName: String {
        if isDirectory { return "folder" }
        switch url.pathExtension.lowercased() {
        case "html": return "chevron.left.slash.chevron.right"
        case "css": return "paintbrush"
        case "js", "jsx": return "curlybraces"
        case "ts": return "t.square"
        case "py": return "terminal"
        default: return "doc.text"
        }
    }
}

// MARK: - WebView wrapper
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







