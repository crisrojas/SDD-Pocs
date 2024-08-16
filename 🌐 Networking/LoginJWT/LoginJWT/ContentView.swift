import SwiftUI

extension Collection {
    var isNotEmpty: Bool { !isEmpty }
}


enum ViewState<T> {
    case idle
    case loading
    case success(T)
    case error(String)
}

extension ViewState {
    var isLoading: Bool {
        switch self {
        case .loading: return true
        default: return false
        }
    }
    var errorMessage: String? {
        switch self {
        case .error(let msg): return msg
        default: return nil
        }
    }
    var data: T? {
        switch self {
        case .success(let data): return data
        default: return nil
        }
    }
}


struct RecipeList: View {
    @StateObject var recipes = API.shared.recipes
    var body: some View {
        switch recipes.state {
        case .idle, .loading: loadingView
        case .success(let data): successView(data)
        case .error(let msg): Text(msg)
        }
    }
    
    @ViewBuilder
    func successView(_ data: MJ) -> some View {
        if data.arrayValue.isEmpty { emptyView }
        else { list(data) }
    }
    
    var emptyView: some View {
        VStack {
            Spacer()
            Text("no data found")
            Button("Add") {
            }
            Spacer()
        }
        .overlay(tf, alignment: .bottom)
    }
    
    var tf: AddTextField {
        .init() << {
            $0.add = add
        }
    }
    
    func add(_ title: String) {
        var command = MJ(["title": title])
        let postRequest = recipes.request(.post, command)
        recipes.load(using: postRequest)
    }
    
    func list(_ data: MJ) -> some View { Text("@todo") }
    
    var loadingView: some View {
        ProgressView().onAppear {
            recipes.load()
        }
    }
}


infix operator <<: AdditionPrecedence
func << <T>(lhs: T, rhs: @escaping (inout T) -> Void) -> T {
    var copy = lhs
    rhs(&copy)
    return copy
}

extension View {
    func onTap(perform action: @escaping () -> Void) -> some View {
        Button(action: action, label: {self})
    }
}

extension RecipeList {
    struct AddTextField: View {
        @State var title = ""
        var add: ((String) -> Void)?
        var body: some View {
            HStack {
                TextField("Recipe title", text: $title)
                Spacer()
                Image(systemName: "paperplane.fill")
                    .onTap {
                        add?(title)
                    }
            }
        }
    }
}

final class UserSettings: ObservableObject {
    @Published var isLoggedIn: Bool = false
    
    private var accessToken: String? { UserDefaults.standard.string(forKey: "accessToken") }
    init() {
        isLoggedIn = accessToken == nil
    }
}

let userSettings = UserSettings()

struct LoginForm: View {
    @AppStorage("accessToken") var accessToken: String?
    @AppStorage("refreshToken") var refreshToken: String?
    @EnvironmentObject var settings: UserSettings
    @State var state = ViewState<AuthToken>.idle
    @State var email    = "cristian@rojas.fr"
    @State var password = "1234"
    var body: some View {
        Form {
            TextField("Email", text: $email)
            TextField("Password", text: $password)
            
            HStack {
                Button("Login", action: didTapLogin)
                Spacer()
                if state.isLoading {
                    ProgressView()
                }
            }
            
            if let errorMsg = state.errorMessage {
                Button(errorMsg) {
                    state = .idle
                }
            }
        }
    }
    
    func didTapLogin() {
        guard isValid().0 else {
            state = .error(isValid().1 ?? "Unknown error")
            return
        }
        Task {
            do {
                let data = try await login(email: email, password: password)
                state = .success(data)
                accessToken  = data.accessToken
                refreshToken = data.refreshToken
                settings.isLoggedIn = true
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
    
    func isValid() -> (Bool, String?) {
        if email.isEmpty { return (false, "Email shouldn't be empty") }
        if password.isEmpty { return (false, "Password shouldn't be empty") }
        return (true, nil)
    }
}

struct ContentView: View {
    @StateObject var settings = userSettings
    var body: some View {
        NavigationView {
            if settings.isLoggedIn {
                RecipeList()
            } else {
                LoginForm().environmentObject(settings)
            }
        }
    }
}

