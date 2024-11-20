import SwiftUI
import SwiftData

struct ArticleList: View {
    @Query(sort: \Article.created, order: .reverse) private var articles: [Article]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        list {
            ForEach(articles) { article in
                ArticleListRow(article: article)
                    .task {
                        guard article.summary == nil else { return }
                        await article.summarize()
                    }
            }
            .onDelete(perform: deleteItems)
            .listRowBackground(Color.clear)
        }
    }

    @ViewBuilder
    private func list<C: View>(@ViewBuilder content: () -> C) -> some View {
        List {
            content()
        }
        .background(Color.accentColor.gradient.opacity(0.7))
        .scrollContentBackground(.hidden)
        .contentMargins(.bottom, 150, for: .automatic)
        .listStyle(.plain)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(articles[index])
                try? modelContext.save()
            }
        }
    }
}
