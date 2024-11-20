import Foundation
import Shared

struct SummarizeBackend: SummarizserService {
    func summarizse(_ content: String) async throws -> Summary {
        let url = URL(string: "http://localhost:8080/summarizse")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let requestModel = SummaryRequest(content: content)
        request.httpBody = try JSONEncoder().encode(requestModel)

        let (data, _) = try await URLSession.shared.data(for: request)
        let responseModel = try JSONDecoder().decode(SummaryResponse.self, from: data)

        return .init(summary: responseModel.summary, tags: responseModel.tags)
    }
}
