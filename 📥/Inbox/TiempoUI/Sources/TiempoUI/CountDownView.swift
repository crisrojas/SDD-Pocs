//
//  File.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 09/07/2023.
//

import SwiftUI
import Combine
#if os(iOS)
public struct CountDownView: View {
    
    @StateObject private var manager: CountDownManager
    @StateObject private var getter  = GetterCapturer()
    @Environment(\.scenePhase) var scenePhase
    
    final class GetterCapturer: ObservableObject {
        var getTimerData: (() -> TimePickerView.Data)?
    }
    
    public init(onCountdownEnd: @escaping (Date, Int) -> Void) {
        _manager = StateObject(wrappedValue: CountDownManager(onCountdownEnd: onCountdownEnd))
    }

    
    public var body: some View {
        VStack(spacing: 0) {
            
            
            ZStack {
                if manager.isRunning {
                    progressView.padding()
                } else {
                    picker
                }
            }
            .frame(height: 350)
            
            
            circularButton(
                label: manager.isRunning ? "Stop" : "Launch",
                color: manager.isRunning ? .red : .emerald,
                action
            )
        }
        .animation(.linear, value: manager.isRunning)
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                if manager.remainingSeconds <= 0 {
                    manager.isRunning = false
                    manager.onCountdownEnd()
                }
            case .background: print("Background")
            case .inactive: print("Inactive")
            default: break
            }
        }
    }
    
    var progressView: some View {
        CounterDownProgressView(remaining: Double(manager.remainingSeconds),
                                duration: Double(manager.duration))
        .padding(.horizontal, 16)
        
    }
    
    var picker: some View {
        let picker = TimePickerViewRepresentable()
        let getter = picker.getData
        return picker.onAppear {
            self.getter.getTimerData = getter
        }
    }
    
    func action() {
        if !manager.isRunning {
            guard let values = getter.getTimerData?(), !values.isIdle else {
                return
            }
            
            manager.setDuration(hours: values.hours,
                                minutes: values.minutes,
                                seconds: values.seconds)
        }
       
        manager.isRunning.toggle()
    }
    
    
    func label(_ text: String) -> some View { Text(text).fontWeight(.bold).font(.system(size: 14)) }
    
    func circularButton(label: String, color: WindColor, _ action: @escaping VoidAction) -> some View {
        let size: CGFloat = 75
        return Button {action()} label: {
            ZStack {
                Circle()
                    .foregroundColor(color.c500.opacity(0.3))
                    .overlay(
                        
                        Image(systemName: manager.isRunning ? "stop.fill" : "play.fill")
                            .foregroundColor(manager.isRunning ? color.c300 : color.c400)
                    )
                
                Circle()
                    .stroke(Color.systemBackground, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: size - 5)
                    .frame(height: size - 5)
            }
            .frame(width: size)
            .frame(height: size)
        }
    }
}


extension Color { static let systemBackground = Color(uiColor: .systemBackground) }



struct CountDownView_Previews: PreviewProvider {
    static var previews: some View {
        CountDownView(onCountdownEnd: { _, _ in})
    }
}


#endif

public final class CountDownManager: ObservableObject {
    
    public var startDate: Date?
    public var endDate: Date?
    private var timer: AnyCancellable?
    
    var hours   = 0
    var minutes = 0
    var seconds = 0
    
    var duration: Int {
        let hours = hours * 60 * 60
        let minutes = minutes * 60
        return hours + minutes + seconds
    }
    
    @Published var remainingSeconds = 0
    @Published public var isRunning = false {
        didSet {
            if self.isRunning {self.start()}
            else {self.stop()}
        }
    }
    
    
    private var accumulatedTime: TimeInterval = 0
    
    private let _onCountdownEnd: (Date, Int) -> Void
    func onCountdownEnd() {
        guard let startDate = startDate else { return }
        _onCountdownEnd(startDate, duration)
    }
    
    public init(onCountdownEnd: @escaping (Date, Int) -> Void) {self._onCountdownEnd = onCountdownEnd}
    
    private func getElapsedTime() -> TimeInterval {
        -(self.startDate?.timeIntervalSinceNow ?? 0)+self.accumulatedTime
    }
    
    
    public func getRemainingSeconds() -> Int {
        guard duration != 0 else { return 0 }
        return duration - Int(getElapsedTime())
    }

    
    public func setDuration(hours: Int, minutes: Int, seconds: Int) {
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
        self.remainingSeconds = duration
    }
    
    func reset() -> Void {
        self.accumulatedTime = 0
        self.startDate = nil
        self.isRunning = false
    }
}


// MARK: - CountDown logic
private extension CountDownManager {
    
    func start() {
        startDate = Date()
        
        if let startDate = startDate {
            let duration = Double(duration)
            endDate = startDate.addingTimeInterval(duration)
        }
        
        self.timer?.cancel()
        self.timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.remainingSeconds = self.getRemainingSeconds()
                
                if self.remainingSeconds == 0 {
                    self.onCountdownEnd()
                    self.isRunning = false
                }
            }
    }
    
    func stop() -> Void {
        self.timer?.cancel()
        self.timer = nil
        self.remainingSeconds = 0
        self.startDate = nil
    }
}
