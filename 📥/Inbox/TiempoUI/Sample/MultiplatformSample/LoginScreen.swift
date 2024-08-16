
import SwiftUI
import TiempoUI
import TogglApi

extension String {
    static let apiToken = "api_token_key"
    static let favoritesKey = "favorites_key"
}

struct ProjectListScreen: View {
    
    
    enum ViewState {
        case idle
        case loading
        case success([ApiProject])
        case error(String)
    }
    
    @State private var state: ViewState = .idle
    @Binding var selectedProject: ApiProject?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            switch state {
            case .idle, .loading:
                ProgressView().task {
                    do {
                        let projects = try await ApiProject.getAll()
                        state = .success(projects)
                    } catch {
                        state = .error(error.localizedDescription)
                    }
                }
            case .success(let projects): projectList(projects)
            case .error(let error): Text(error).foregroundColor(.red)
            }
        }
    }
    
    func projectList(_ projects: [ApiProject]) -> some View {
        List(projects) { item in
            HStack {
                Circle().frame(width: 12, height: 12).foregroundColor(Color(hex: item.color))
                Text(item.name)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectedProject = item
                dismiss()
            }
        }
        
    }
}
struct MainView: View {
    @AppStorage(.apiToken) var savedToken: String?
    @State var apiToken: String = ""
    @State var errorMessage: String?
    @State var selectedProject: ApiProject?
    
   @State private var showProjectList = false
    var body: some View {
        VStack {
            if let _ = savedToken {
                if let errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                }
                
                if let selectedProject = selectedProject {
                    HStack {
                        Circle().frame(width: 12, height: 12)
                            .foregroundColor(Color(hex: selectedProject.color))
                        Text(selectedProject.name)
                    }
                    .onTapGesture {
                        showProjectList = true
                    }
                } else {
                    
                    HStack {
                        Circle().frame(width: 12, height: 12).foregroundColor(.gray)
                        Text("Seleccionar projecto")
                    }
                    .onTapGesture {
                        showProjectList = true
                    }
                }
                
                CountDownView(onCountdownEnd: { startDate, duration in
                    guard let selectedProject = selectedProject else {
                        print("Should select project")
                        return
                    }
                    Task {
                        do {
                            try await TogglApi.createEntry(
                                startDate: startDate,
                                duration: duration,
                                workspaceId: selectedProject.workspaceId,
                                projectId: selectedProject.id
                            )
                            sendNotification()
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                })
                .sheet(isPresented: $showProjectList) {
                    ProjectListScreen(selectedProject: $selectedProject)
                }
            } else {
                unloggedView
            }
        }
    }
    
    var unloggedView: some View {
        Form {
            
            Section(header: header, footer: footer, content: content)
            
            if let error = errorMessage {
                Text(error)
                Button(
                    action: { errorMessage = nil},
                    label: { Text("ok") }
                )
            }
            
            
            Section {
                Button(action: saveApiToken, label: {
                    Text("Login")
                })
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    var header: some View {
        Text("Enter your Toggl api key")
    }
    
    var footer: some View {
        Text("You can find your api key on your user account settings")
    }
    
    
    func content() -> some View {
        SecureField("API KEY", text: $apiToken)
    }
    
    
    func saveApiToken() {
        guard !apiToken.isEmpty else {
            errorMessage = "Token shouldn't be empty"
            return
        }
        
        savedToken = apiToken
    }
}


struct LoginScreen: View {
    @State private var apiToken = ""
    var body: some View {
        Form {
            
            Section(header: header, footer: footer, content: content)
            
            Section {
                Button(action: login, label: {
                    Text("Share workout")
                })
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    var header: some View {
        Text("Enter your Toggl api key")
    }
    
    var footer: some View {
        Text("You can find your api key on your user account settings")
    }
    
    func content() -> some View {
        SecureField("API KEY", text: $apiToken)
    }
    
    func login() {
        
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
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
