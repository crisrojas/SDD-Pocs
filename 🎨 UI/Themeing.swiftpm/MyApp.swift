import SwiftUI

protocol Initiable {
    init()
}

extension Initiable {
    init(transform: (inout Self) -> Void) {
        var copy = Self.init()
        transform(&copy)
        self = copy
    }
}

struct Theme: Initiable {
    var accentColor = Color.red
}

extension Theme {
    static let light = Theme()
    static let dark  = Theme { $0.accentColor = .yellow }
}

struct Schemer<Content: View>: View {
    @AppStorage("colorScheme") var scheme: ColorScheme?
    @Environment(\.colorScheme) var colorScheme
    var theme: Theme { (scheme ?? colorScheme).theme }
    var content: () -> Content
    var body: some View {
        content()
            .environment(\.theme, theme)
            .preferredColorScheme(scheme)
    }
}

// RawRepresentable conformance so we can persist to UserDefaults:
extension ColorScheme: RawRepresentable {
    public var rawValue: String {
        switch self {
        case .light: return "light"
        case .dark: return "dark"
        default: return "unknown"
        }
    }
    
    public init?(rawValue: String) {
        switch rawValue {
        case "light": self = .light
        case "dark": self = .dark
        default: return nil
        }
    }
}

extension ColorScheme {
    var theme: Theme {
        switch self {
        case .dark: return .dark
        default: return .light
        }
    }
}

struct ThemeProviderKey: EnvironmentKey {
    static var defaultValue: Theme = .light
}


extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeProviderKey.self] }
        set { self[ThemeProviderKey.self] = newValue }
    }
}


@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            Schemer {
                Profile()
            }
        }
    }
}
