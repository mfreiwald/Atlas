import MarkdownUI
import Splash
import SwiftUI

private struct MarkdownModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    private var theme: Splash.Theme {
        switch colorScheme {
        case .dark:
            .wwdc17(withFont: .init(size: 16))
        default:
            .sunset(withFont: .init(size: 16))
        }
    }

    func body(content: Content) -> some View {
        content
            .markdownCodeSyntaxHighlighter(SplashCodeSyntaxHighlighter(theme: theme))
    }
}

extension View {
    func markdown() -> some View {
        modifier(MarkdownModifier())
    }
}
