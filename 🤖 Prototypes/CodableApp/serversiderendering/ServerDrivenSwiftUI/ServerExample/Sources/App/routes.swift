import ServerDrivenSwiftUI
import Vapor

func routes(_ app: Application) throws {
    typealias VStack = Models.VStack
    typealias HStack = Models.HStack
    typealias Image  = Models.Image
    typealias Text   = Models.Text
    typealias Button = Models.Button
    
    app.get(":version", "helloworld") { req async throws -> Response in
        renderView {
            VStack(spacing: 20) {
                Image(systemName: "globe")
                    .foregroundColor(.blue)
                    .frame(width: 100)
                    .onTapGesture(
                        .alert(
                            shouldBePresented: true,
                            withMessage: "You tapped on the image"
                        )
                    )
                
                Text("It works!")
                Text("Now, try add models to the view")
                    .font(.footnote, color: .gray)
                Button(action: .reload) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.uturn.left.circle")
                            .frame(width: 20)
                        Text("Reload")
                    }
                }
            }
        }
    }
}

extension Application {
    func get<Content: Model>(_ path: PathComponent..., content: @escaping () -> Content) {
        get(path) { req async throws -> Response in
            let encodedContent = encodedReponse(of: [content().render()])
            return encodedContent
        }
    }
}


func renderView<Content: Model>(_ content: () -> Content) -> Response {
    let encodedContent = encodedReponse(of: [content().render()])
    return encodedContent
}

func encodedReponse<Content: Codable>(of content: Content) -> Response {
    let encoder = JSONEncoder()
    var data: Data?
    do {
        data = try encoder.encode(content)
    } catch let e {
        print("❌", e)
    }
    
    guard let data = data else {
        return Response(status: .internalServerError, headers: ["Content-Type": "application/json"])
    }
    
    return Response(
        status: .ok,
        headers: ["Content-Type": "application/json"],
        body: Response.Body(data: data)
    )
}
