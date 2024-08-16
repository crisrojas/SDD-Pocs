//
//  Refactorizar interactors.swift
//  Effin
//
//  Created by Cristian Felipe Patiño Rojas on 04/12/2023.
//

import Foundation

protocol Interactor {
    associatedtype SuccessType
    associatedtype ErrorType: Error
    func execute(completion: @escaping (Result<SuccessType, ErrorType>) -> Void)
}

extension Interactor {
    func execute() async throws -> SuccessType {
        return try await withCheckedThrowingContinuation { continuation in
            execute() { result in
                switch result {
                case .success(let resource): continuation.resume(returning: resource)
                case .failure(let error   ): continuation.resume(throwing : error   )
                }
            }
        }
    }
}

