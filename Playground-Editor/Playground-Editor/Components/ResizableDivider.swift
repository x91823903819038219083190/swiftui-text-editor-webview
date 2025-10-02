import SwiftUI

struct ResizableDivider: View {
    @Binding var width: CGFloat
    let maxWidth: CGFloat

    var body: some View {
        Divider()
            .frame(width: 5)
            .background(Color.gray.opacity(0.2))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let newWidth = width - value.translation.width
                        if newWidth > 200, newWidth < maxWidth * 0.8 {
                            width = newWidth
                        }
                    }
            )
            .onHover { hovering in
                if hovering {
                    NSCursor.resizeLeftRight.push()
                } else {
                    NSCursor.pop()
                }
            }
    }
}
