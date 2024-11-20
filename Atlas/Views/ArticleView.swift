import SwiftUI
import MarkdownUI

struct ArticleView: View {
    let title: String
    let description: String?
    let summary: String?
    let content: String

    @State private var showSummary = false
    @State private var inlineTitleOpacity: Double = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(title)
                    .animation(.default, value: title)
                    .font(.title)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.black.mix(with: .accentColor, by: 0.7))
                    .onScrollVisibilityChange(threshold: 0.1) { isVisible in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            inlineTitleOpacity = isVisible ? 0 : 1
                        }
                    }

                if let summary {
                    summaryView(summary)
                } else {
                    summarizeLoading
                }

                Markdown(content)
                    .markdown()
                    .padding(.top, 16)
                    .animation(.default, value: content)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
        }
//        .toolbar(removing: .title)
//        .navigationTitle(title)
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                Text(title)
//                    .font(.body)
//                    .bold()
//                    .fontDesign(.rounded)
//                    .dynamicTypeSize(.large ... .xxxLarge)
//                    .opacity(inlineTitleOpacity)
//                    .lineLimit(1)
//            }
//        }
        .onChange(of: summary) { oldValue, newValue in
            if oldValue == nil && newValue != nil {
                withAnimation {
                    showSummary = true
                }
            }
        }
    }

    @ViewBuilder
    private func summaryView(_ summary: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            DisclosureGroup(isExpanded: $showSummary) {
                Markdown(summary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
            } label: {
                Text("Summary")
                    .font(.callout)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color.accentColor.mix(with: .gray, by: 0.2).opacity(0.7), in: .rect(cornerRadius: 16))
        .tint(.primary)
    }

    @ViewBuilder
    private var summarizeLoading: some View {
        VStack {
            Label {
                Text("Summarize")
            } icon: {
                Image(systemName: "gearshape")
                    .foregroundStyle(.pink.gradient)
                    .symbolEffect(.rotate)
            }
            .font(.callout)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.accentColor.mix(with: .gray, by: 0.2).opacity(0.7), in: .rect(cornerRadius: 16))
    }
}

// Replace the existing #Preview with the following:
#Preview("Full Content with Summary") {
    ArticleView(
        title: "Best & Worst Burgers at Disneyland",
        description: "A comprehensive guide to burgers in the happiest place on Earth",
        summary: "This article ranks the top 5 best and worst burgers at Disneyland, considering factors such as taste, price, and overall experience.",
        content: "Disneyland is known for its magical experiences, and that includes its food offerings. In this article, we'll explore the best and worst burgers you can find in the park..."
    )
}

#Preview("Content without Summary") {
    ArticleView(
        title: "Hidden Gems of Tomorrowland",
        description: "Discover the lesser-known attractions in Disneyland's futuristic land",
        summary: nil,
        content: "Tomorrowland is full of popular attractions like Space Mountain, but there are several hidden gems that many visitors overlook..."
    )
}

#Preview("Long Title and Description") {
    ArticleView(
        title: "The Comprehensive Guide to Every Single Ride, Attraction, and Show at Disneyland Resort: A Complete Walkthrough from Main Street U.S.A. to Galaxy's Edge",
        description: "An exhaustive exploration of every experience available at Disneyland, including detailed descriptions, wait times, age recommendations, and insider tips for maximizing your enjoyment of each attraction",
        summary: "This guide covers all 53 rides, 47 shows, and 38 unique attractions across Disneyland and Disney California Adventure.",
        content: "Welcome to the most comprehensive guide to Disneyland Resort you'll ever need. In this article, we'll take you through every nook and cranny of the Happiest Place on Earth..."
    )
}

#Preview("Empty Content") {
    ArticleView(
        title: "Coming Soon: New Fantasyland Expansion",
        description: "Exciting updates on the upcoming Fantasyland expansion at Disneyland",
        summary: nil,
        content: ""
    )
}

#Preview {
    ArticleView(
        title: "Best & Worst Burgers at Disneyland",
        description: nil,
        summary: nil,
        content: ""
    )
}
