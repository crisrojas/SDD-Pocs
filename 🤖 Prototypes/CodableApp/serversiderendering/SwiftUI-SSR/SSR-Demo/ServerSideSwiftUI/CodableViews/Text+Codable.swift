import Foundation
import SwiftUI

struct CodableText: View, CodableViewVariant {
    var id: UUID = UUID()
    var alignment: TextAlignment
    var content: String
    var lineLimit: Int?
    
    enum CodingKeys: CodingKey {
        case alignment
        case content
        case lineLimit
    }
    
    public var body: some View {
        Text(content)
            .lineLimit(lineLimit)
            .multilineTextAlignment(alignment)
    }
}
