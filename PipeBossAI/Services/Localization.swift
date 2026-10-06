import Foundation

enum L10n {
    static let preferenceKey = "pipeboss.preferredLanguage"

    static func language(for selection: String, preferred: [String], available: [String]) -> String {
        if selection != "system" { return available.contains(selection) ? selection : "en" }
        for preference in preferred {
            let locale = Locale(identifier: preference)
            if let exact = available.first(where: { Locale(identifier: $0).identifier == locale.identifier }) {
                return exact
            }
            if let code = locale.languageCode,
               let match = available.first(where: { Locale(identifier: $0).languageCode == code }) {
                return match
            }
        }
        return "en"
    }

    static var currentLanguage: String {
        language(
            for: UserDefaults.standard.string(forKey: preferenceKey) ?? "system",
            preferred: Locale.preferredLanguages,
            available: Bundle.main.localizations.filter { $0 != "Base" }
        )
    }

    static func text(_ source: String, language: String = currentLanguage, bundle: Bundle = .main) -> String {
        guard let path = bundle.path(forResource: language, ofType: "lproj"),
              let localizedBundle = Bundle(path: path) else { return source }
        return localizedBundle.localizedString(forKey: source, value: source, table: "Localizable")
    }

    // Named tokens let translators reorder sentences without changing game data.
    static func format(_ source: String, _ values: [String: String], language: String = currentLanguage) -> String {
        substitute(text(source, language: language), values: values)
    }

    static func substitute(_ template: String, values: [String: String]) -> String {
        let expression = try! NSRegularExpression(pattern: "\\{([a-zA-Z][a-zA-Z0-9_]*)\\}")
        var result = template
        let matches = expression.matches(in: template, range: NSRange(template.startIndex..., in: template))
        for match in matches.reversed() {
            guard let nameRange = Range(match.range(at: 1), in: template),
                  let replacement = values[String(template[nameRange])],
                  let tokenRange = Range(match.range, in: result) else { continue }
            result.replaceSubrange(tokenRange, with: replacement)
        }
        return result
    }
}

#if canImport(SwiftUI)
import SwiftUI

@MainActor
final class LocalizationPreferences: ObservableObject {
    struct Language: Identifiable {
        let id: String
        let name: String
    }

    @Published var selection: String {
        didSet { defaults.set(selection, forKey: L10n.preferenceKey) }
    }
    private let defaults: UserDefaults

    // Only bundled languages belong here; machine-translation drafts stay outside the app.
    let languages = [
        Language(id: "system", name: "Device language"),
        Language(id: "en", name: "English"),
        Language(id: "es", name: "Español (beta)")
    ]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let saved = defaults.string(forKey: L10n.preferenceKey) ?? "system"
        self.selection = ["system", "en", "es"].contains(saved) ? saved : "system"
    }

    var language: String {
        L10n.language(for: selection, preferred: Locale.preferredLanguages, available: ["en", "es"])
    }

    var locale: Locale { Locale(identifier: language) }
}

struct LText: View {
    @Environment(\.locale) private var locale
    let source: String
    let values: [String: String]

    init(_ source: String, values: [String: String] = [:]) {
        self.source = source
        self.values = values
    }

    var body: some View {
        Text(verbatim: L10n.format(source, values, language: locale.identifier))
    }
}

struct LLabel: View {
    @Environment(\.locale) private var locale
    let source: String
    let systemImage: String
    let values: [String: String]

    init(_ source: String, systemImage: String, values: [String: String] = [:]) {
        self.source = source
        self.systemImage = systemImage
        self.values = values
    }

    var body: some View {
        Label {
            Text(verbatim: L10n.format(source, values, language: locale.identifier))
        } icon: {
            Image(systemName: systemImage)
        }
    }
}
#endif
