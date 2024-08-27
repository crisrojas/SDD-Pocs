import Vapor
import JWT


func routes(_ app: Application) throws {
   try app.register(collection: LoginController())
}

struct User: Authenticatable, Content, Codable {
    let email: String
    let password: String
}


struct LoginController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let loginRoutes = routes.grouped("login")
        loginRoutes.post(use: login)
    }

    func login(req: Request) async throws -> AuthCommand {
        let data = try req.content.decode(LoginRequest.self)
        let user = try getUser(email: data.email)

        guard user.password == data.password else {
            throw Abort(.unauthorized)
        }

        let accessToken = try req.jwt.sign(AccessToken(userId: user.email))
        let refreshToken = try req.jwt.sign(RefreshToken(userId: user.email))

        return AuthCommand(accessToken: accessToken, refreshToken: refreshToken)
    }

    private func getUser(email: String) throws -> User {
        let users = try getUsers()
        guard let user = users.first(where: { $0.email == email }) else {
            throw Abort(.notFound)
        }
        return user
    }
    
    func getUsers() throws -> [User] {[]}
}



struct LoginRequest: Content {
    let email: String
    let password: String
}

struct AuthCommand: Content {
    let accessToken: String
    let refreshToken: String
}

struct AccessToken: JWTPayload {
    let userId: String
    let expiration: ExpirationClaim

    init(userId: String) {
        self.userId = userId
        self.expiration = .init(value: Date(timeIntervalSinceNow: 3600)) // 1 hour expiration
    }
    
    func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
}

struct RefreshToken: JWTPayload {
    let userId: String
    let expiration: ExpirationClaim

    init(userId: String) {
        self.userId = userId
        self.expiration = .init(value: Date(timeIntervalSinceNow: 604800)) // 1 week expiration
    }
    
    func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
}
