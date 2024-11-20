import Hummingbird
import Shared

struct SummaryController<Context: RequestContext> {
    let service: any SummarizserService

    func addRoutes(to group: RouterGroup<Context>) {
        group.post(use: summarize)
    }

    @Sendable private func summarize(
        _ request: Request,
        context: Context
    ) async throws -> SummaryResponse {
        let input = try await request.decode(
            as: SummaryRequest.self,
            context: context
        )

        context.logger.info("Receive content: \(input.content.prefix(50))")

        let response = try await service.summarizse(input)

        return response
    }

}

extension SummaryResponse: ResponseEncodable {}
