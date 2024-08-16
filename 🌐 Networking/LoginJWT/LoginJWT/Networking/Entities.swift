//
//  Entities.swift
//  LoginJWT
//
//  Created by Cristian Felipe Patiño Rojas on 08/04/2024.
//

import Foundation



struct AuthCommand: Codable {
    let email: String
    let password: String
}

struct AuthToken: Codable {
    let accessToken: String
    let refreshToken: String
}
