import SwiftUI
import Combine

struct CodeEditorView: View {
    @Binding var code: String
    let saveFile: () -> Void
    let fileName: String?

    @State private var saveCancellable: AnyCancellable?
    @State private var lastSavedCode: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            if let name = fileName {
                Text(name)
                    .font(.headline)
                    .padding(.top)
            }

            TextEditor(text: $code)
                .font(.system(.body, design: .monospaced))
                .padding()
                .onChange(of: code) { newValue in
                    guard newValue != lastSavedCode else { return }
                    saveCancellable?.cancel()
                    saveCancellable = Just(newValue)
                        .delay(for: .seconds(1), scheduler: RunLoop.main)
                        .sink { _ in
                            saveFile()
                            lastSavedCode = newValue
                        }
                }
        }
        .onAppear {
            lastSavedCode = code
        }
    }
}

