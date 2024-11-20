import MarkdownUI
import Splash
import SwiftUI

struct SplashCodeSyntaxHighlighter: CodeSyntaxHighlighter {
    private let syntaxHighlighter: SyntaxHighlighter<TextOutputFormat>

    init(theme: Splash.Theme) {
        syntaxHighlighter = SyntaxHighlighter(format: TextOutputFormat(theme: theme))
    }

    func highlightCode(_ content: String, language: String?) -> Text {
        guard let language else  {
            return syntaxHighlighter.highlight(content)
        }

        if language.lowercased() == "swift" {
            return syntaxHighlighter.highlight(content)
        }

        if language.lowercased() == "" {
            return syntaxHighlighter.highlight(content)
        }

        return Text(content)
    }
}

extension CodeSyntaxHighlighter where Self == SplashCodeSyntaxHighlighter {
    static func splash(theme: Splash.Theme) -> Self {
        SplashCodeSyntaxHighlighter(theme: theme)
    }
}
