import Vapor
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    let jwtSigner = JWTSigner.hs256(key: "my_secret_key")
    app.jwt.signers.use(jwtSigner, kid: "my_secret_id")
    


    // register routes
    try routes(app)
}

