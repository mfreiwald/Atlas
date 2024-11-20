import Foundation
import SwiftOpenAI

protocol SummarizserService {
    func summarizse(_ content: String) async throws -> Summary
}

struct OpenAISummarizser: SummarizserService {
    private let service: any OpenAIService
    private let model: Model

    private let schema: JSONSchemaResponseFormat = {
        let symboflArray = JSONSchema(
            type: .array,
            items: JSONSchema(
                type: .string
            )
        )

        let responseFormatSchema = JSONSchemaResponseFormat(
            name: "summary",
            strict: true,
            schema: JSONSchema(
                type: .object,
                properties: [
                    "summary": JSONSchema(type: .string),
                    "tags": JSONSchema(type: .array, items: .init(type: .string)),
                ],
                required: ["summary", "tags"],
                additionalProperties: false
            )
        )
        return responseFormatSchema
    }()

    init() {
        service = OpenAIServiceFactory.service(
            azureConfiguration: AzureOpenAIConfiguration(
                resourceName: "",
                openAIAPIKey: .apiKey(""),
                apiVersion: "2024-10-01-preview"
            )
        )
        model = .custom("gpt-4o")
    }

    let systemMessage = """
Provide a comprehensive summary of the given text. The summary should cover all the key points and main ideas presented in the original text, while also condensing the information into a concise and easy-to-understand format. Please ensure that the summary includes relevant details and examples that support the main ideas, while avoiding any unnecessary information or repetition. The length of the summary should be appropriate for the length and complexity of the original text, providing a clear and accurate overview without omitting any important information.
"""

    func summarizse(_ content: String) async throws -> Summary {
        let result = try await service.startChat(
            parameters: .init(
                messages: [
                    .init(role: .system, content: .text(systemMessage)),
                    .init(role: .user, content: .text(content))
                ],
                model: model,
                responseFormat: .jsonSchema(schema)
            )
        )
        guard
            let content = result.choices.first?.message.content,
            let data = content.data(using: .utf8)
        else { throw NSError() }
        let decoded = try JSONDecoder().decode(Summary.self, from: data)
        return decoded
    }
}

struct Summary: Decodable {
    let summary: String
    let tags: [String]
}