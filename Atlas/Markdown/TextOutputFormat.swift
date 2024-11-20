import Splash
import SwiftUI

struct TextOutputFormat: OutputFormat {
    private let theme: Theme

    init(theme: Theme) {
        self.theme = theme
    }

    func makeBuilder() -> Builder {
        Builder(theme: theme)
    }
}

extension TextOutputFormat {
    struct Builder: OutputBuilder {
        private let theme: Theme
        private var accumulatedText: [Text]

        fileprivate init(theme: Theme) {
            self.theme = theme
            accumulatedText = []
        }

        mutating func addToken(_ token: String, ofType type: TokenType) {
            let color = theme.tokenColors[type] ?? theme.plainTextColor
            #if os(iOS)
                accumulatedText.append(Text(token).foregroundColor(.init(uiColor: color)))
            #elseif os(macOS)
                accumulatedText.append(Text(token).foregroundColor(.init(nsColor: color)))
            #endif
        }

        mutating func addPlainText(_ text: String) {
            #if os(iOS)
                accumulatedText.append(Text(text).foregroundColor(.init(uiColor: theme.plainTextColor)))
            #elseif os(macOS)
                accumulatedText.append(Text(text).foregroundColor(.init(nsColor: theme.plainTextColor)))
            #endif
        }

        mutating func addWhitespace(_ whitespace: String) {
            accumulatedText.append(Text(whitespace))
        }

        func build() -> Text {
            accumulatedText.reduce(Text(""), +)
        }
    }
}
