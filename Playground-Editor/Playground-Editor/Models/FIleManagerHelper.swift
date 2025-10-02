import Foundation

struct FileManagerHelper {
    private let fm = FileManager.default
    private let workingFolder: URL

    init(folderName: String = "MyProjectFiles") {
        let documentsURL = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.workingFolder = documentsURL.appendingPathComponent(folderName)

        if !fm.fileExists(atPath: workingFolder.path) {
            try? fm.createDirectory(at: workingFolder, withIntermediateDirectories: true)
        }
        print("Working folder path: \(workingFolder.path)")
    }

    func buildTree(at url: URL? = nil) -> [LocalFileItem] {
        let targetURL = url ?? workingFolder
        guard let contents = try? fm.contentsOfDirectory(
            at: targetURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        let sortedContents = contents.sorted { a, b in
            let aIsDir = (try? a.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            let bIsDir = (try? b.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            if aIsDir == bIsDir {
                return a.lastPathComponent.lowercased() < b.lastPathComponent.lowercased()
            }
            return aIsDir && !bIsDir
        }

        return sortedContents.map { fileURL in
            var isDir: ObjCBool = false
            fm.fileExists(atPath: fileURL.path, isDirectory: &isDir)
            let children = isDir.boolValue ? buildTree(at: fileURL) : nil
            return LocalFileItem(url: fileURL, children: children)
        }
    }

    func readFile(_ file: LocalFileItem) -> String? {
        guard !file.isDirectory else { return nil }
        return try? String(contentsOf: file.url, encoding: .utf8)
    }

    func writeFile(_ file: LocalFileItem, content: String) {
        guard !file.isDirectory else { return }
        try? content.write(to: file.url, atomically: true, encoding: .utf8)
    }
}
