//
//  File.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 09/05/2023.
//

import SwiftUI

enum MenuItem: CaseIterable {
    case inbox
    case today
    case planned
    case anytime
    case someDay
    case history
    case trash
    
    var icon: String {
        switch self {
        case .inbox: return "tray.fill"
        case .today: return "star.fill"
        case .planned: return "calendar"
        case .anytime: return "square.stack.3d.up.fill"
        case .someDay: return "archivebox.fill"
        case .history: return "book.closed.fill"
        case .trash: return "trash.fill"
        }
    }
    
    var label: String {
        switch self {
        case .inbox  : return "Entrada"
        case .today  : return "Hoy"
        case .planned: return "Programadas"
        case .anytime: return "En cualquier momento"
        case .someDay: return "Algún día"
        case .history: return "Registro"
        case .trash  : return "Papelera"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .inbox: return .cyan
        case .today: return .yellow
        case .planned: return .pink
        case .anytime: return .teal
        case .someDay: return .brown
        case .history: return .green
        case .trash: return .white
        }
    }
}
