import SwiftUI

struct ArticleListRow: View {
    let article: Article

    var body: some View {
        NavigationLink(value: article, label: {
            label
        })
        .tint(.primary)
    }

    @ViewBuilder
    private var label: some View {
        VStack(alignment: .leading) {
            Text(article.title ?? "Title loading...")
                .font(.headline)

            Text(article.summary ?? article.desc ?? "")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .lineLimit(1)
    }
}
