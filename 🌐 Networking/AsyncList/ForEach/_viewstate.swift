//
//  _viewstate.swift
//  ForEach
//
//  Created by Cristian Felipe Patiño Rojas on 01/04/2024.
//

import Foundation

enum ViewState {
    case loading
    case success(MJ)
    case error(String)
    case empty
}

extension ViewState {
    func appending(data: MJ) -> Self {
        if case let .success(mJ) = self {
            let mj = mJ.arrayValue.appending(data)
            return .success(MJ(mj))
        }
        return self
    }
}
