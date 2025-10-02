import Foundation

struct LocalFileItem: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let children: [LocalFileItem]?

    var isDirectory: Bool {
        (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
    }

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

