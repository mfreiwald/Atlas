import RegexBuilder
import Foundation

struct UrlValidator {
    func validate(_ value: String) -> Bool {
        guard !value.isEmpty else { return false }
        let matcher = Regex {
            Capture {
                One(.url(scheme: .required,
                         user: .optional,
                         password: .optional,
                         host: .required,
                         port: .optional,
                         path: .optional,
                         query: .optional,
                         fragment: .optional))
            }
        }

        return value.firstMatch(of: matcher) != nil
    }
}
