//
//  File.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 09/07/2023.
//

import SwiftUI
final class TimerManager: ObservableObject {
    
    enum TimerMode {
        case idle
        case running
        
        var started: Bool { self == .running }
        
        var ctaLabel: String {
            switch self {
            case .idle: return "Iniciar"
            case .running: return "Detener"
            }
        }
        
        var ctaColor: WindColor {
            switch self {
            case .idle: return .green
            case .running: return .yellow
            }
        }
    }
    
    @Published var   timerMode = TimerMode.idle
    @Published var secondsLeft = Double.zero
    
    @Published var       hours = 0
    @Published var     minutes = 0
    @Published var     seconds = 0
    
    @Published var startDate: Date?
    @Published var endDate: Date?
    
    
    var contextualAction: VoidAction {
        switch timerMode {
        case    .idle: return { [weak self] in self?._start()}
        case .running: return stop
        }
    }
    
    var totalSeconds: Int {
        let hours = hours * 60 * 60
        let minutes = minutes * 60
        return hours + minutes + seconds
    }
    
    var progress: Double {
        let remaining = Double(secondsLeft)
        let total = Double(totalSeconds)
        let made = total - remaining
        
        return made / total
    }
    
    var hoursLabel  : String {   hours == 1 ?   "hora" : "horas"   }
    var minutesLabel: String { minutes == 1 ? "minuto" : "minutos" }
    
    var timer: Timer?
    var sourceTimer: DispatchSourceTimer!
    
    let queue = DispatchQueue(label: "com.domain.app.timer", qos: .userInteractive)
    
    
    func reset() {
        timerMode = .idle
        secondsLeft = Double(totalSeconds)
        timer?.invalidate()
    }
    
    func stop() {
        timer?.invalidate()
        timerMode = .idle
    }
    
    func resume() { _start(secondsLeft) }
    
    func _start(_ secondsLeft: Double? = nil) {
        timerMode = .running
        start(secondsLeft)
    }
    
    func launch(_ secondsLeft: Double? = nil, granularity g: TimeInterval = 0.1) {
        if let secondsLeft = secondsLeft { self.secondsLeft = secondsLeft }
        else { self.secondsLeft = Double(totalSeconds) }
        timerMode = .running
        sourceTimer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        sourceTimer.schedule(deadline: .now(), repeating: g, leeway: .nanoseconds(0))
        sourceTimer.setEventHandler {
            // do something
            if self.secondsLeft <= 0 {
                self.timerMode = .idle
                self.sourceTimer.cancel()
            }
            
            self.secondsLeft -= g
        }
        sourceTimer.resume()
    }
    
    func start(_ secondsLeft: Double? = nil, granularity g: TimeInterval = 0.1) {
        if let secondsLeft = secondsLeft { self.secondsLeft = secondsLeft }
        else { self.secondsLeft = Double(totalSeconds) }
        
        timerMode = .running
        
        timer = Timer.scheduledTimer(
            withTimeInterval: g,
            repeats: true,
            block: { timer in
                if self.secondsLeft <= 0 {
                    self.timerMode = .idle
                    self.timer?.invalidate()
                }
                
                self.secondsLeft -= g
            })
    }
}
