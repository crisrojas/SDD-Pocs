import SwiftUI

indirect enum Component: Identifiable, Codable {
    case text(Models.Text)
    case background(Modifiers.Background)
    case vStack(Models.VStack)
    
    var id: UUID {
        switch self {
        case .text(let m): m.id
        case .background(let m): m.id
        case .vStack(let m): m.id
        }
    }
    
    @ViewBuilder func view() -> some View {
        switch self {
        case .text(let model):
            Models.Text.ComponentView(model: model)
        case .vStack(let vstack):
            Models.VStack.ComponentView(vstack)
        case .background(let _):
            Text("@todo")
        }
    }
}

protocol Model {
    func render() -> Component
}

enum Modifiers {
    struct Background: Codable {
        let id: UUID
        let content: Component
        let modifierContent: Component
        func render() -> Component {
            .background(self)
        }
    }
}

extension Modifiers.Background {
    struct ComponentView: View {
        let model: Modifiers.Background
        var body: some View {
            model.content.view()
                .background(
                    model.modifierContent .view()
                )
        }
    }
}

enum Models {
    struct Text: Codable {
        let id: UUID = UUID()
        var value: String
        
        init(_ v: String) {
            value = v
        }
        
        func render() -> Component {
            Component.text(self)
        }
    }
}

extension Models.Text {
    struct ComponentView: View {
        let model: Models.Text
        var body: Text {
            Text(model.value)
        }
    }
}

protocol ModelConvertible {
    func asModels() -> [Model]
}

@resultBuilder
enum ModelBuilder {
    static func buildBlock(_ content: ModelConvertible...) -> [Model] {
        Array(
            content.map { element -> [Model] in
                element.asModels()
            }
            .flatMap { $0 }
            .prefix(9)
        )
    }

    static func buildOptional(_ component: ModelConvertible?) -> [Model] {
        return component?.asModels() ?? []
    }

    static func buildEither(first: ModelConvertible) -> [Model] {
        return first.asModels()
    }

    static func buildEither(second: ModelConvertible) -> [Model] {
        return second.asModels()
    }
}

extension Models {
    struct VStack: Identifiable, Model, Codable {
        public let id: UUID
        let alignment: HorizontalAlignment
        let spacing: CGFloat
        let components: [Component]

        public init(
            id: UUID = UUID(),
            alignment: HorizontalAlignment = .center,
            spacing: CGFloat = .zero,
            @ModelBuilder models: @escaping () -> [Model]
        ) {
            self.id = id
            self.alignment = alignment
            self.spacing = spacing
            components = models().map { $0.render() }
        }

        public func render() -> Component {
            Component.vStack(self)
        }
    }
}

extension Models.VStack {
    struct ComponentView: View {
        init(
            _ model: Models.VStack
        ) {
            self.model = model
        }

        private let model: Models.VStack

        var body: some View {
            VStack(alignment: model.alignment, spacing: model.spacing) {
                ForEach(model.components) { component in
                    component.view()
                }
            }
        }
    }
}


extension HorizontalAlignment: Codable {
    enum CodingKeys: String, CodingKey {
        case leading, center, trailing
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .leading:
            try container.encode(CodingKeys.leading.rawValue, forKey: .leading)
        case .trailing:
            try container.encode(CodingKeys.trailing.rawValue, forKey: .trailing)
        default:
            try container.encode(CodingKeys.center.rawValue, forKey: .center)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first

        switch key {
        case .leading:
            self = .leading
        case .center, .none:
            self = .center
        case .trailing:
            self = .trailing
        }
    }
}

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
