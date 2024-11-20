import SwiftUI
import SwiftData
import RegexBuilder

struct ContentView: View {
    @State private var url = ""
    @State private var article: Article?

    var body: some View {
        NavigationStack {
            ArticleList()
                .overlay(alignment: .bottom) {
                    UrlInput(url: $url) {
                        self.article = $0
                    }
                    .background(.ultraThinMaterial)
                }
                .navigationTitle("Articles")
                .navigationDestination(item: $article) { article in
                    ArticleOverview(article: article)
                }
                .navigationDestination(for: Article.self) { article in
                    ArticleOverview(article: article)
                }
                .toolbarBackground(Material.thin, for: .navigationBar)
        }
    }
}

struct ArticleOverview: View {
    let article: Article

    var body: some View {
        ArticleView(
            title: article.title ?? String(repeating: "a", count: 25),
            description: article.desc,
            summary: article.summary,
            content: article.content ?? (article.title == nil ? String(repeating: "a", count: 350) : "")
        )
        .redacted(reason: article.title == nil ? [.placeholder] : [])
    }
}


#Preview {
    ContentView()
}
