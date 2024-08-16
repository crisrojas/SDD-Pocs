//
//  File.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 09/07/2023.
//

#if os(iOS)
import SwiftUI

struct RingView: View {
    
    @State var isRunning = false
    let progress: Double
    let remainingTime: Double
    let animated: Bool
    
    private let lineWidth: CGFloat = 7
    
    var body: some View {
        Circle()
            .trim(from: 0, to: isRunning ? 0 : progress)
            .stroke(WindColor.amber.c400, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .onAppear { isRunning = animated }
            .animation(.linear(duration: remainingTime), value: isRunning)
    }
}


struct CounterDownProgressView: View {
    
    let remaining: Double
    let duration: Double
    private let lineWidth: CGFloat = 7
    
    private var progress: Double { remaining / duration }
    var label: String {
        Int(remaining).toTimerLabel
    }
    
    var body: some View {
        ZStack {
            Circle().stroke(WindColor.zinc.c700, lineWidth: lineWidth)
            
                RingView(progress: progress, remainingTime: remaining, animated: true)
            
            // When app comes from background and time has ellapsed, it is negative so
            // and its shown briefly, this will prevent that
            if !label.contains("-") {
                Text(label)
                    .font(.system(size: 50))
                    .monospacedDigit()
                    .frame(width: 200)
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
}
#endif
