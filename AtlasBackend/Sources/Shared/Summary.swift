public struct SummaryRequest: Sendable, Codable {
    public let content: String

    public init(content: String) {
        self.content = content
    }
}

public struct SummaryResponse: Sendable, Codable {
    public let summary: String
    public let tags: [String]

    package init(summary: String, tags: [String]) {
        self.summary = summary
        self.tags = tags
    }
}
