//
//  _extensions.swift
//  Movies
//
//  Created by Cristian Felipe Patiño Rojas on 10/04/2024.
//

import Foundation

enum Inset {
    case top
    case bottom
    case left
    case right
}

extension CGFloat {
    static func safeAreaInset(_ inset: Inset) -> Self? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        
        switch inset {
        case .top   : return windowScene.windows.first?.safeAreaInsets.top
        case .bottom: return windowScene.windows.first?.safeAreaInsets.bottom
        case .left  : return windowScene.windows.first?.safeAreaInsets.left
        case .right : return windowScene.windows.first?.safeAreaInsets.right
        }
    }
}

extension Collection {
    var isNotEmpty: Bool { !isEmpty }
}

extension String {
    var tmdbImageURL: URL? {
        return URL(string: "https://image.tmdb.org/t/p/w500\(self)")
    }
}

import SwiftUI

extension String: View {
    public var body: Text { Text(self) }
}

extension URL {
    func appendingQueryItem(_ name: String, value: Any) -> URL {
        var components = URLComponents(string: self.absoluteString)
        components?.queryItems?.append(.init(name: name, value: String(describing: value)))
        return components!.url!
    }
}

extension UIImage {
    func image() -> Image {
        Image(uiImage: self)
    }
}

#if DEBUG
extension Result {
    var data: Success? {
        switch self {
        case .success(let data): return data
        case .failure: return nil
        }
    }
}

extension Result where Success == Data {
    var json: String? {
        guard let data else { return nil }
        return data.asString
    }
}

extension Data {
    var asString: String { String(decoding: self, as: UTF8.self) }
}
#endif

