/// A description
import ArgumentParser
import Foundation
import Hummingbird
import Logging
import NIOPosix

@main
struct App: AsyncParsableCommand {
    @Option(name: .shortAndLong)
    var hostname: String = "127.0.0.1"

    @Option(name: .shortAndLong)
    var port: Int = 8080

    func run() async throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup.singleton
        let logger = Logger(label: "AtlasBackend")

        let router = Router(context: BasicRequestContext.self)

        router.get("/") { request, context in
            let name = request.uri.queryParameters.get("name") ?? "Swift Meetup Munich"
            return "👋 Hello \(name)! 🚀 \n\nsummarizse Endpoint is not available anymore 😉"
        }

        let (apiKey, resourceName) = try await loadEnv(logger)

        let summarizserService: SummarizserService = OpenAISummarizser(
            resourceName: resourceName,
            apiKey: apiKey
        )

        SummaryController(service: summarizserService).addRoutes(to: router.group("summarizse"))

        let app = Application(
            router: router,
            configuration: .init(
                address: .hostname(hostname, port: port),
                serverName: "AtlasBackend"
            ),
            eventLoopGroupProvider: .shared(eventLoopGroup),
            logger: logger
        )

        try await app.runService()
    }

    private func loadEnv(_ logger: Logger) async throws -> (apiKey: String, resourceName: String) {
        let environment = try await Environment.dotEnv()

        guard let apiKey = environment.get("APIKey")  else {
            fatalError("Environment APIKey required")
        }

        guard let resourceName = environment.get("ResourceName") else {
            fatalError("Environment ResourceName required")
        }

        logger.info("ResourceName: \(resourceName.prefix(17).suffix(17-4))")
        logger.info("APIKey: \(apiKey.prefix(3))")

        return (apiKey: apiKey, resourceName: resourceName)
    }
}
