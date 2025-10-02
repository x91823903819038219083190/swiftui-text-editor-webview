import SwiftUI

struct FileListView: View {
    let files: [LocalFileItem]
    @Binding var selectedFile: LocalFileItem?
    let loadFile: (LocalFileItem) -> Void

    var body: some View {
        List(selection: $selectedFile) {
            ForEach(files, id: \.url.path) { file in
                OutlineGroup(file, children: \.children) { item in
                    HStack {
                        Image(systemName: item.iconName)
                        Text(item.url.lastPathComponent)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    .contentShape(Rectangle())
                    .background(selectedFile?.id == item.id ? Color.blue.opacity(0.2) : Color.clear)
                    .onTapGesture {
                        print("Selected file:", item.url.path)
                        if !item.isDirectory {
                            selectedFile = item
                            loadFile(item)
                        }
                    }
                }
            }
        }
        .listStyle(SidebarListStyle())
    }
}






    





