import SwiftData
import Foundation
import OSLog

private let logger = Logger(subsystem: "dev.freiwald.Atlas", category: "Article")

@Model
final class Article: Hashable, Equatable {
    var url: String
    var created: Date
    private(set) var title: String?
    private(set) var desc: String?
    private(set) var summary: String?
    private(set) var content: String?

    @Transient
    let reader: ReaderService = JinaReaderService()
    @Transient
    let summarizer: SummarizserService = OpenAISummarizser()

    init(url: String) {
        self.url = url
        self.created = Date.now
    }

    func load() async {
        await fetch()
        await summarize()
    }

    @MainActor
    func fetch() async {
        logger.info("fetch content for \(self.url)")
        do {
            let dataContent = try await reader.content(of: url)
            logger.info("fetched content for \(self.url)")
            title = dataContent.data.title
            desc = dataContent.data.description
            content = dataContent.data.content
        } catch {
            logger.error("fetch content failed for \(self.url) with error \(error)")
        }
    }

    @MainActor
    func summarize() async {
        guard let content else { return }
        logger.info("summarize content for \(self.url)")
        do {
            let summary = try await summarizer.summarizse(content)
            logger.info("summarized content for \(self.url)")
            self.summary = summary.summary
        } catch {
            logger.error("summarize content failed for \(self.url) with error \(error)")
        }
    }
}
