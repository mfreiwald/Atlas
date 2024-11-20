import SwiftUI

struct UrlInput: View {
    @Binding var url: String
    var openArticle: (Article) -> Void

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext

    private var isUrlValid: Bool {
        UrlValidator().validate(url)
    }

    var body: some View {
        inputOverlay
            .onChange(of: scenePhase, initial: true) { oldValue, newValue in
                guard newValue == .active else { return }
                paste()
            }
    }

    @ViewBuilder
    private var inputOverlay: some View {
        VStack(spacing: 6) {
            Color.accentColor.mix(with: .black, by: 0.1)
                .frame(height: 1)

            input
                .padding()
        }
    }

    @ViewBuilder
    private var input: some View {
        VStack(spacing: 20) {
            urlTextField
                .font(.callout)

            Button {
                load()
            } label: {
                Label("Load", systemImage: "wand.and.rays")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .disabled(!isUrlValid)
        }
    }

    @ViewBuilder
    var urlTextField: some View {
        HStack {
            TextField("URL", text: $url)
                .padding(8)
                .background(Color.secondary.opacity(0.2), in: .rect(cornerRadius: 8))
                .textContentType(.URL)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onSubmit {
                    load()
                }

            Button(action: paste) {
                Label("Paste", systemImage: "doc.on.clipboard")
                    .labelStyle(.iconOnly)
            }
            .tint(Color.accentColor)
        }
    }

    private func paste() {
        guard let paste = UIPasteboard.general.string else { return }
        guard UrlValidator().validate(paste) else { return }
        self.url = paste
    }

    @MainActor
    private func load() {
        guard UrlValidator().validate(url) else { return }

        let article = Article(url: url)
        Task {
            await article.load()
        }
        modelContext.insert(article)
        try? modelContext.save()
        openArticle(article)
        url = ""
    }
}

#Preview {
    @Previewable @State var url: String = ""
    ArticleList()
        .overlay(alignment: .bottom) {
            UrlInput(url: $url) { _ in }
                .background(.ultraThinMaterial)
        }
}
