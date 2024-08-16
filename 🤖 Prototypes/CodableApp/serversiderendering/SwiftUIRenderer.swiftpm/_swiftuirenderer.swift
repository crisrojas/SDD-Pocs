import SwiftUI

protocol Requirements: Codable, Hashable {}

//// @todo: alerts, sheets, stepper, tabitem, section, asyncImage
indirect enum Component: Requirements {
    
    // Composed
    case tabView(children: [Component], options: Options)
    case navigationView(children: [Component], options: Options)
    case scrollView(children: [Component], options: Options)
    case list(children: [Component], options: Options)
    case lazyvstack(children: [Component], options: Options)
    case lazyhstack(children: [Component], options: Options)
    case vstack(children: [Component], options: Options)
    case hstack(children: [Component], options: Options)
    case zstack(children: [Component], options: Options)
    case group(children: [Component], options: Options)
    case form(children: [Component], options: Options)

    // Empty
    case spacer
    case divider
    case emptyView

    // Shapes
    case rectangle(options: Options = Options())
    case circle(options: Options = Options())

    // Standalone
    case navigationLink(label: Component, destination: Component, options: Options)
    case label(value: String, systemImage: String, options: Options)
    case text(value: String, options: Options)
    case image(value: String, options: Options)
    case sfSymbol(value: String, options: Options)
    case color(hex: String, options: Options)
    case progressView(options: Options)

    // Controls
    case button(label: Component, options: Options)
    case toggle(isOn: Bool, label: Component, options: Options)
    case slider(value: Double, range: ClosedRange<Double>, options: Options)
    case datePicker(date: Date, options: Options)
    case textField(placeholder: String, value: String, options: Options)
    case secureField(placeholder: String, value: String, options: Options)

    // Custom
    case link(label: Component, url: String, options: Options)
    case asyncView(url: String, options: Options)
    case asyncJSON(url: String, options: Options)
}

extension Component {
    func inject(_ options: Options) -> Component {
        switch self {
        case .tabView(let c, _):
            return .tabView(children: c, options: options)
        case .navigationView(let c, _):
            return .navigationView(children: c, options: options)
        case .scrollView(let c, _):
            return .scrollView(children: c, options: options)
        case .list(let c, _):
            return .list(children: c, options: options)
        case .lazyvstack(let c, _):
            return .lazyvstack(children: c, options: options)
        case .lazyhstack(let c, _):
            return .lazyhstack(children: c, options: options)
        case .vstack(let c, _):
            return .vstack(children: c, options: options)
        case .hstack(let c, _):
            return .hstack(children: c, options: options)
        case .zstack(let c, _):
            return .zstack(children: c, options: options)
        case .group(let c, _):
            return .group(children: c, options: options)
        case .form(let c, _):
            return .form(children: c, options: options)
        default: return self
        }
    }
}


/// MARK: - Views
extension Component {
    @ViewBuilder
    func body() -> some View {
        switch self {
        case .tabView(let c, let o):
            TabView { render(c) }.apply(o)
//        case .asyncView(let url, let o):
//            AsyncView(url).apply(o)
//        case .navigationView(let c, let o):
//            NavigationView { render(c) }.apply(o)
//        case .link(let l, let u, let o):
//            NavigationLink(destination: {AsyncView(u)}, label: {l.body()}).apply(o)
//        case .navigationLink(let l, let d, let o):
//            NavigationLink(destination: d.body(), label: {l.body()}).apply(o)
//        case .lazyhstack(let c, let o):
//            LazyHStack { render(c) }.apply(o)
//        case .lazyvstack(let c, let o):
//            LazyVStack { render(c) }.apply(o)
//        case .vstack(let c, let o):
//            VStack { render(c) }.apply(o)
//        case .hstack(let c, let o):
//            HStack { render(c) }.apply(o)
//        case .zstack(let c, let o):
//            ZStack { render(c) }.apply(o)
//        case .text(let v, let o):
//            Text(v).apply(o)
//        case .spacer:
//            Spacer()
//        case .divider:
//            Divider()
//        case .emptyView:
//            EmptyView()
//        case .sfSymbol(let v, let o):
//            Image(systemName: v).apply(o)
//        case .image(let v, let o):
//            Image(v).apply(o)
//        case .color(let v, let o):
//            Color(hex: v).apply(o)
//        case .scrollView(let c, let o):
//            ScrollView { render(c) }.apply(o)
//        case .group(let c, let o):
//            Group { render(c) }.apply(o)
//        case .label(let v, let si, let o):
//            Label(v, systemImage: si).apply(o)
//        case .rectangle(let o):
//            Rectangle().apply(o)
//        case .circle(let o):
//            Circle().apply(o)
//        case .button(let l, let o):
//            Button(action: {}, label: {l.body()}).apply(o)
//        case .toggle(let on, let l, let o):
//            Toggle(isOn: .constant(on), label: {l.body()}).apply(o)
//        case .form(let c, let o):
//            Form { render(c) }.apply(o)
//        case .slider(let v, let r, let o):
//            Slider(value: .constant(v), in: r, onEditingChanged: {_ in}).apply(o)
//        case .datePicker(let d, let o):
//            DatePicker("@todo", selection: .constant(d)).apply(o)
//        case .list(let c, let o):
//            List { render(c) }.apply(o)
//        case .progressView(let o):
//            ProgressView().apply(o)
//        case .textField(let p, let v, let o):
//            TextField(p, text: .constant(v)).apply(o)
//        case .secureField(let p, let v, let o):
//            SecureField(p, text: .constant(v)).apply(o)
//        case .asyncJSON(let url, let o):
//            AsyncJSON(url: url) { json in Text(json.stringValue) }
//            .apply(o)
        default: Text("hello world")
        }
    }

    private func render(_ objects: [Component]) -> some View {
        ForEach(objects, id: \.self) {$0.body()}
    }
}

extension Component {
    static let jsonEncoder = JSONEncoder()
    static let jsonDecoder = JSONDecoder()

    func prettyPrinted() -> AnyObject? {
        try? encode().string() as AnyObject
    }

    func encode() throws -> Data {
        try Self.jsonEncoder.encode(self)
    }

    func decode(data: Data) throws -> Self {
        try Self.jsonDecoder.decode(Self.self, from: data)
    }
}


extension Edge.Set: Requirements {}

// MARK: - Options
// @todo: aspectRatio,
struct Options: Requirements {

    struct Padding: Requirements {
        let edge: Edge.Set
        let value: CGFloat
        
        static let zero = Self(edge: .all, value: 0)
    }
    
    struct Font {
        enum Weight: Requirements {
            case black
            case bold
            case heavy
            case light
            case medium
            case regular
            case semibold
            case thin
            case ultraLight
            
            func map() -> SwiftUI.Font.Weight {
                switch self {
                case .black: return .black
                case .bold: return .bold
                case .heavy: return .heavy
                case .light: return .light
                case .medium: return .medium
                case .regular: return .regular
                case .semibold: return .semibold
                case .thin: return .thin
                case .ultraLight: return .ultraLight
                }
            }
        }
        
        enum TextStyle: Requirements {
            case body
            case callout
            case caption
            case caption2
            case headline
            case largeTitle
            case subheadline
            case title
            case title2
            case title3
            
            func map() -> SwiftUI.Font.TextStyle {
                switch self {
                case .body: return .body
                case .callout: return .callout
                case .caption: return .caption
                case .caption2: return .caption2
                case .headline: return .headline
                case .largeTitle: return .largeTitle
                case .subheadline: return .subheadline
                case .title: return .title
                case .title2: return .title2
                case .title3: return .title3
                }
            }
        }
        
        enum Design: Requirements {
            case defaultCase
            case monospace
            case rounded
            case serif
            
            func map() -> SwiftUI.Font.Design {
                switch self {
                case .defaultCase: return .default
                case .monospace: return .monospaced
                case .rounded: return .rounded
                case .serif: return .serif
                }
            }
        }
    }

    var background: Component?
    var foregroundColor: String?
    
    var width: CGFloat?
    var height: CGFloat?
    var maxWidth: CGFloat?
    var maxHeight: CGFloat?
    
    var opacity: CGFloat?
    var offset_x: CGFloat?
    var offset_y: CGFloat?
    
    var fontWeight: Font.Weight?
    var fontStyle: Font.TextStyle?
    var fontDesign: Font.Design?
    
    var tabItem: Component?
    var cornerRadius: CGFloat?
    var disabled: Bool?
    var zIndex: CGFloat?
    var padding: Padding?
    var edgesIgnoreSafeArea: Edge.Set?
    var overlay: Component?
}

//// MARK: - Option handling
extension View {
    @ViewBuilder
    func ifLet<T>(_ optional:T?, transform: (Self, T) -> some View) -> some View {
        if let optional {
            transform(self, optional)
        } else {
            self
        }
    }

//    @available(iOS 16.0, *)
    func apply(_ options: Options) -> some View {
        print(#function)
        return self
            .font(.system(options.fontStyle?.map() ?? .body, design: options.fontDesign?.map() ?? .default))
//            .fontWeight(options.fontWeight?.map())
            .frame(width: options.width)
            .frame(height: options.height)
            .frame(maxWidth: options.maxWidth)
            .frame(maxHeight: options.maxHeight)
//            .background(options.background)
            .foregroundColor(Color(hex: options.foregroundColor))
            .opacity(options.opacity ?? 1)
            .cornerRadius(options.cornerRadius ?? 0)
            .padding(
                options.padding?.edge ?? Options.Padding.zero.edge,
                options.padding?.value ?? Options.Padding.zero.value
            )
            .disabled(options.disabled ?? false)
            .offset(x: options.offset_x ?? 0, y: options.offset_y ?? 0)
            .zIndex(options.zIndex ?? 0)
//            .overlay(options.overlay)
//            .ifLet(options.tabItem) { view, tabItem in
//                view.tabItem {
//                    tabItem
//                }
//            }
            .ifLet(options.edgesIgnoreSafeArea) { view, edges in
                view.edgesIgnoringSafeArea(edges)
            }
    }
}

/// MARK: - DSL
protocol ComponentOwner {
    var options: Options {get set}
    var body: Component {get}
}

enum DSL {}
extension DSL {
    struct TabView: ComponentOwner {
        var options = Options()
        let newView: Component

        init(@Builder content: () -> Component) {
            newView = content()
        }

        var body: Component {newView.inject(options)}
        
        @resultBuilder
        struct Builder {
            static func buildBlock(_ components: ComponentOwner...) -> Component {
                Component.tabView(children: components.map{$0.body}, options: Options())
            }
        }
    }
}

extension DSL {
    struct NavigationView: ComponentOwner {
        var options = Options()
        let newView: Component

        init(@Builder content: () -> Component) {
            newView = content()
        }

        var body: Component {newView.inject(options)}
        
        @resultBuilder
        struct Builder {
            static func buildBlock(_ components: ComponentOwner...) -> Component {
                Component.navigationView(children: components.map{$0.body}, options: Options())
            }
        }
    }
}

extension DSL {
    struct ScrollView: ComponentOwner {
        var options = Options()
        let newView: Component

        init(@Builder content: () -> Component) {
            newView = content()
        }

        var body: Component {newView.inject(options)}
        
        @resultBuilder
        struct Builder {
            static func buildBlock(_ components: ComponentOwner...) -> Component {
                Component.scrollView(
                    children: components.map{$0.body},
                    options: Options()
                )
            }
        }
    }
}

extension DSL {
    struct List: ComponentOwner {
        var options = Options()
        let newView: Component

        init(@Builder content: () -> Component) {
            newView = content()
        }

        var body: Component {newView.inject(options)}
        
        @resultBuilder
        struct Builder {
            static func buildBlock(_ components: ComponentOwner...) -> Component {
                Component.list(
                    children: components.map{$0.body},
                    options: Options()
                )
            }
        }
    }
}

extension DSL {
    struct LazyVStack: ComponentOwner {
        var options = Options()
        let newView: Component

        init(@Builder content: () -> Component) {
            newView = content()
        }

        var body: Component {newView.inject(options)}
        
        @resultBuilder
        struct Builder {
            static func buildBlock(_ components: ComponentOwner...) -> Component {
                Component.lazyvstack(
                    children: components.map{$0.body},
                    options: Options()
                )
            }
        }
    }
}

extension DSL {
    struct LazyHStack: ComponentOwner {
        var options = Options()
        let newView: Component

        init(@Builder content: () -> Component) {
            newView = content()
        }

        var body: Component {newView.inject(options)}
        
        @resultBuilder
        struct Builder {
            static func buildBlock(_ components: ComponentOwner...) -> Component {
                Component.lazyhstack(
                    children: components.map{$0.body},
                    options: Options()
                )
            }
        }
    }
}

extension DSL {
    struct VStack: ComponentOwner {
        var options = Options()
        let newView: Component

        init(@Builder content: () -> Component) {
            newView = content()
        }

        var body: Component {newView.inject(options)}
        
        @resultBuilder
        struct Builder {
            static func buildBlock(_ components: ComponentOwner...) -> Component {
                Component.vstack(children: components.map{$0.body}, options: Options())
            }
        }
    }
}

extension DSL {
    struct HStack: ComponentOwner {
        var options = Options()
        let newView: Component

        init(@Builder content: () -> Component) {
            newView = content()
        }

        var body: Component {
            newView.inject(options)
        }
        
        @resultBuilder
        struct Builder {
            static func buildBlock(_ components: ComponentOwner...) -> Component {
                print(#function)
                return Component.hstack(children: components.map{$0.body}, options: Options())
            }
        }
    }
}

extension DSL {
    struct ZStack: ComponentOwner {
        var options = Options()
        let newView: Component

        init(@Builder content: () -> Component) {
            newView = content()
        }

        var body: Component {newView.inject(options)}
        
        @resultBuilder
        struct Builder {
            static func buildBlock(_ components: ComponentOwner...) -> Component {
                Component.zstack(children: components.map{$0.body}, options: Options())
            }
        }
    }
}

extension DSL {
    struct Group: ComponentOwner {
        var options = Options()
        let newView: Component

        init(@Builder content: () -> Component) {
            newView = content()
        }

        var body: Component {newView.inject(options)}
        
        @resultBuilder
        struct Builder {
            static func buildBlock(_ components: ComponentOwner...) -> Component {
                Component.group(
                    children: components.map{$0.body},
                    options: Options()
                )
            }
        }
    }
}

extension DSL {
    struct Form: ComponentOwner {
        var options = Options()
        let newView: Component

        init(@Builder content: () -> Component) {
            newView = content()
        }

        var body: Component {newView.inject(options)}
        
        @resultBuilder
        struct Builder {
            static func buildBlock(_ components: ComponentOwner...) -> Component {
                Component.form(
                    children: components.map{$0.body},
                    options: Options()
                )
            }
        }
    }
}

extension DSL {
    struct NavigationLink: ComponentOwner {
        var options = Options()
        let label: ComponentOwner
        let destination: ComponentOwner

        var body: Component {
            .navigationLink(label: label.body, destination: destination.body, options: options)
        }
    }
}

extension DSL {
    struct Label: ComponentOwner {
        var options = Options()
        let title: String
        let systemImage: String

        var body: Component {
            .label(
                value: title,
                systemImage: systemImage,
                options: options
            )
        }
    }
}

extension DSL {
    struct Spacer: ComponentOwner {
        var options = Options()

        var body: Component {.spacer}
    }

    struct Divider: ComponentOwner {
        var options = Options()

        var body: Component {.divider}
    }

    struct EmptyView: ComponentOwner {
        var options = Options()

        var body: Component {.emptyView}
    }

    struct Rectangle: ComponentOwner {
        var options = Options()

        var body: Component {.rectangle(options: options)}
    }

    struct Circle: ComponentOwner {
        var options = Options()

        var body: Component {.circle(options: options)}
    }

    struct Image: ComponentOwner {
        var options = Options()
        let config: Config

        enum Config {
            case name(String)
            case sfSymbol(String)
        }

        init(_ name: String) { config = .name(name) }
        init(systemName: String) {
            config = .sfSymbol(systemName)
        }

        var body: Component {
            switch config {
            case .name(let name):
                return .image(value: name, options: options)
            case .sfSymbol(let name):
                return .sfSymbol(value: name, options: options)
            }
        }
    }

    struct Button: ComponentOwner {
        var options = Options()
        let label: Component
        var body: Component {
            .button(label: label, options: options)
        }
    }

    struct Toggle: ComponentOwner {
        var options = Options()
        let isOn: Bool
        let label: Component
        var body: Component {
            .toggle(isOn: isOn, label: label, options: options)
        }
    }

    struct DatePicker: ComponentOwner {
        var options = Options()
        let date: Date
        var body: Component {
            .datePicker(date: date, options: options)
        }
    }

    struct ProgressView: ComponentOwner {
        var options = Options()
        var body: Component {
            .progressView(options: options)
        }
    }

    struct TextField: ComponentOwner {
        var options = Options()
        let placeholder: String
        let value: String
        var body: Component {
            .textField(
                placeholder: placeholder,
                value: value,
                options: options
            )
        }
    }

    struct SecureField: ComponentOwner {
        var options = Options()
        let placeholder: String
        let value: String
        var body: Component {
            .secureField(
                placeholder: placeholder,
                value: value,
                options: options
            )
        }
    }

    struct AsyncView: ComponentOwner {
        var options = Options()
        let url: String
        var body: Component {
            .asyncView(url: url, options: options)
        }
    }
    
    struct AsyncJSON: ComponentOwner {
        var options = Options()
        let url: String
        var body: Component {
            .asyncJSON(url: url, options: options)
        }
    }
}

extension DSL {
    struct Link: ComponentOwner {
        var options = Options()
        let url: String
        let label: Component

        init(url: String, label: String) {
            self.url = url
            self.label = .text(value: label, options: options)
        }

        init(url: String, label: ComponentOwner) {
            self.url = url
            self.label = label.body
        }

        var body: Component {
            .link(label: label, url: url, options: options)
        }
    }
}

extension DSL {
    struct Text: ComponentOwner {
        var options = Options()
        let string: String

        init(_ string: String) {
            self.string = string
        }

        var body: Component {
            .text(value: string, options: options)
        }
    }
}

extension DSL {
    struct Color: ComponentOwner {
        let hex: String
        var options = Options()
        var body: Component {.color(hex: hex, options: options)}
    }
}

struct Application {
    typealias NavigationView = DSL.NavigationView
    
    typealias HStack = DSL.HStack
    typealias VStack = DSL.VStack
    typealias ZStack = DSL.ZStack
    typealias LazyVStack = DSL.LazyVStack
    typealias LazyHStack = DSL.LazyHStack
    typealias ScrollView = DSL.ScrollView
    typealias AsyncView = DSL.AsyncView
    typealias AsyncJSON = DSL.AsyncJSON
    
    typealias NavigationLink = DSL.NavigationLink
    typealias TabView = DSL.TabView
    typealias Link = DSL.Link
    typealias Text = DSL.Text
    typealias Color = DSL.Color
    typealias Image = DSL.Image
    typealias Spacer = DSL.Spacer
}

extension JSON {
    
    final class Database: ObservableObject {
        @Published var data: [String: JSON] = [:]
        
        func upsert(_ item: JSON) {
            guard let id = item.id.string else { return }
            data[id] = item
        }
        
        func delete(_ item: JSON) {
            guard let id = item.id.string else { return }
            data[id] = nil
        }
        
        func delete(_ id: String) {
            data[id] = nil
        }
        
    }
   
    static let database = Database()
}


struct MyViews: View {
    @StateObject var observables = JSON.database
    var body: some View {
        Text("hello").environmentObject(observables)
    }
}

enum Action: Codable {
    case persist(JSON)
    
    struct Error: Swift.Error {}
    
    func action() throws {
        switch self {
        case .persist(let json):
            guard let key = json.id.string else { return }
            JSON.database.data[key] = json
        }
    }
}
//// MARK: - Modifiers
///*
// .shadow(color:radius:x:y:)
// .border(_:)
// .border(_:width:)
// .rotationEffect(_:anchor:)
// .rotation3DEffect(_:axis:anchor:anchorZ:perspective:)
// .scaleEffect(_:anchor:)
// .scale3DEffect(_:axis:anchor:perspective:)
// .clipped()
// .mask(_:)
// .contentShape(_:)
// .gesture(_:)
// .onTapGesture { ... }
// .onLongPressGesture { ... }
// .onHover { ... }
// .onAppear { ... }
// .onDisappear { ... }
// .onChange(of:perform:)
// .allowsHitTesting(_:)
// .animation(_:)
// .transition(_:)
// .focusable(_:)
// .id(_:)
// .accessibility(hidden:)
// .accessibility(label:)
// .accessibility(value:)
// .accessibility(addTraits:)
// .accessibility(removeTraits:)
// .accessibility(sortPriority:)
// .accessibilityAction(named:handler:)
// .accessibilityIdentifier(_)*/
extension ComponentOwner {
    func background(_ bg: ComponentOwner) -> ComponentOwner {
        print(#function)
       var copy = self
        copy.options.background = bg.body
        return copy
    }

    func opacitiy(_ value: Double) -> ComponentOwner {
        var copy = self
        copy.options.opacity = value
        return copy
    }

    func frame(width: CGFloat) -> ComponentOwner {
        var copy = self
        copy.options.width = width
        return copy
    }

    func frame(height: CGFloat) -> ComponentOwner {
        var copy = self
        copy.options.height = height
        return copy
    }

    func frame(maxWidth: CGFloat) -> ComponentOwner {
        var copy = self
        copy.options.maxWidth = maxWidth
        return copy
    }

    func frame(maxHeight: CGFloat) -> ComponentOwner {
        var copy = self
        copy.options.maxHeight = maxHeight
        return copy
    }

    func frame(width: CGFloat, height: CGFloat) -> ComponentOwner {
        var copy = self
        copy.options.width = width
        copy.options.height = height
        return copy
    }

    func tabItem(_ item: DSL.Label) -> ComponentOwner {
        var copy = self
        copy.options.tabItem = item.body
        return copy
    }

    func zIndex(_ index: CGFloat) -> ComponentOwner {
        var copy = self
        copy.options.zIndex = index
        return copy
    }

    func cornerRadius(_ value: CGFloat) -> ComponentOwner {
        var copy = self
        copy.options.cornerRadius = value
        return copy
    }

    func disabled(_ bool: Bool) -> ComponentOwner {
        var copy = self
        copy.options.disabled = bool
        return copy
    }

    // @todo: this overrides paddings if used twice
    func padding(_ e: Edge.Set, _ v: CGFloat) -> ComponentOwner {
        var copy = self
        copy.options.padding = .init(edge: e, value: v)
        return copy
    }

    func overlay(_ view: ComponentOwner) -> ComponentOwner {
        DSL.ZStack {
            self
            view
        }
    }
    
    func offset(x: CGFloat) -> ComponentOwner {
        var copy = self
        copy.options.offset_x = x
        return copy
    }
    
    func offset(y: CGFloat) -> ComponentOwner {
        var copy = self
        copy.options.offset_y = y
        return copy
    }
    
    func fontWeight(_ weight: Options.Font.Weight) -> ComponentOwner {
        var copy = self
        copy.options.fontWeight = weight
        return copy
    }
    
    func fontStyle(_ style: Options.Font.TextStyle) -> ComponentOwner {
        var copy = self
        copy.options.fontStyle = style
        return copy
    }
}

// MARK: - Custom Views
struct AsyncView: View {

    @State var state = ViewState.idle

    enum ViewState {
        case idle
        case loading
        case success(Component)
        case error(String)
    }

    let url: URL

    init(_ url: String) {
        self.url = URL(string: url)!
    }

    var body: some View {
        switch state {
        case .idle, .loading: ProgressView().task { await load() }
        case .success(let result): result.body()
        case .error(let error): Text(error)
        }
    }

    static let decoder = JSONDecoder()

    func load() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try Self.decoder.decode(Component.self, from: data)
            state = .success(decoded)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

extension Color {
    init?(hex: String?) {
        guard let hex = hex?.trimmingCharacters(in: CharacterSet.alphanumerics.inverted) else { return nil }
       
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
//
//// MARK: - Helpers
extension Data {
    func string() -> String {
       String(decoding: self, as: UTF8.self)
    }
}


extension DSL.Color {
    static let gray50 = Self(hex: "#f9fafb")
    static let gray100 = Self(hex: "#f3f4f6")
    static let gray200 = Self(hex: "#e5e7eb")
    static let gray300 = Self(hex: "#d1d5db")
    static let gray400 = Self(hex: "#9ca3af")
    static let gray500 = Self(hex: "#6b7280")
    static let gray600 = Self(hex: "#4b5563")
    static let gray700 = Self(hex: "#374151")
    static let gray800 = Self(hex: "#1f2937")
    static let gray900 = Self(hex: "#111827")
    static let red50 = Self(hex: "#fef2f2")
    static let red100 = Self(hex: "#fee2e2")
    static let red200 = Self(hex: "#fecaca")
    static let red300 = Self(hex: "#fca5a5")
    static let red400 = Self(hex: "#f87171")
    static let red500 = Self(hex: "#ef4444")
    static let red600 = Self(hex: "#dc2626")
    static let red700 = Self(hex: "#b91c1c")
    static let red800 = Self(hex: "#991b1b")
    static let red900 = Self(hex: "#7f1d1d")
    static let yellow50 = Self(hex: "#fffbeb")
    static let yellow100 = Self(hex: "#fef3c7")
    static let yellow200 = Self(hex: "#fde68a")
    static let yellow300 = Self(hex: "#fcd34d")
    static let yellow400 = Self(hex: "#fbbf24")
    static let yellow500 = Self(hex: "#f59e0b")
    static let yellow600 = Self(hex: "#d97706")
    static let yellow700 = Self(hex: "#b45309")
    static let yellow800 = Self(hex: "#92400e")
    static let yellow900 = Self(hex: "#78350f")
    static let green50 = Self(hex: "#ecfdf5")
    static let green100 = Self(hex: "#d1fae5")
    static let green200 = Self(hex: "#a7f3d0")
    static let green300 = Self(hex: "#6ee7b7")
    static let green400 = Self(hex: "#34d399")
    static let green500 = Self(hex: "#10b981")
    static let green600 = Self(hex: "#059669")
    static let green700 = Self(hex: "#047857")
    static let green800 = Self(hex: "#065f46")
    static let green900 = Self(hex: "#064e3b")
    static let blue50 = Self(hex: "#eff6ff")
    static let blue100 = Self(hex: "#dbeafe")
    static let blue200 = Self(hex: "#bfdbfe")
    static let blue300 = Self(hex: "#93c5fd")
    static let blue400 = Self(hex: "#60a5fa")
    static let blue500 = Self(hex: "#3b82f6")
    static let blue600 = Self(hex: "#2563eb")
    static let blue700 = Self(hex: "#1d4ed8")
    static let blue800 = Self(hex: "#1e40af")
    static let blue900 = Self(hex: "#1e3a8a")
    static let indigo50 = Self(hex: "#eef2ff")
    static let indigo100 = Self(hex: "#e0e7ff")
    static let indigo200 = Self(hex: "#c7d2fe")
    static let indigo300 = Self(hex: "#a5b4fc")
    static let indigo400 = Self(hex: "#818cf8")
    static let indigo500 = Self(hex: "#6366f1")
    static let indigo600 = Self(hex: "#4f46e5")
    static let indigo700 = Self(hex: "#4338ca")
    static let indigo800 = Self(hex: "#3730a3")
    static let indigo900 = Self(hex: "#312e81")
    static let purple50 = Self(hex: "#f5f3ff")
    static let purple100 = Self(hex: "#ede9fe")
    static let purple200 = Self(hex: "#ddd6fe")
    static let purple300 = Self(hex: "#c4b5fd")
    static let purple400 = Self(hex: "#a78bfa")
    static let purple500 = Self(hex: "#8b5cf6")
    static let purple600 = Self(hex: "#7c3aed")
    static let purple700 = Self(hex: "#6d28d9")
    static let purple800 = Self(hex: "#5b21b6")
    static let purple900 = Self(hex: "#4c1d95")
    static let pink50 = Self(hex: "#fdf2f8")
    static let pink100 = Self(hex: "#fce7f3")
    static let pink200 = Self(hex: "#fbcfe8")
    static let pink300 = Self(hex: "#f9a8d4")
    static let pink400 = Self(hex: "#f472b6")
    static let pink500 = Self(hex: "#ec4899")
    static let pink600 = Self(hex: "#db2777")
    static let pink700 = Self(hex: "#be185d")
    static let pink800 = Self(hex: "#9d174d")
    static let pink900 = Self(hex: "#831843")
}
