//
//  FeedbackManager.swift
//  ThingsKit
//
//  Created by Cristian Felipe Patiño Rojas on 26/08/2023.
//

import UIKit

final class FeedbackManager {
    let lightFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    

    static let shared = FeedbackManager()
    private init() {}
    
    func generateLightFeedback() {
        lightFeedbackGenerator.impactOccurred(intensity: 1)
    }
}
