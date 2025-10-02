import SwiftUI

struct PreviewToggleButton: ToolbarContent {
    @Binding var showPreview: Bool
    @Binding var previewWidth: CGFloat
    @Binding var lastWidth: CGFloat

    var body: some ToolbarContent {
        ToolbarItem {
            Button {
                withAnimation {
                    if showPreview {
                        lastWidth = previewWidth
                        showPreview = false
                    } else {
                        previewWidth = lastWidth
                        showPreview = true
                    }
                }
            } label: {
                Label("Toggle Preview", systemImage: "globe")
            }
        }
    }
}

