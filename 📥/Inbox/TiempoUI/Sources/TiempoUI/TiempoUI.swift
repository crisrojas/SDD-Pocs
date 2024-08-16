
typealias VoidAction = () -> Void

import SwiftUI
//extension UIPickerView {
//    open override var intrinsicContentSize: CGSize {
//        return CGSize(width: UIView.noIntrinsicMetric , height: super.intrinsicContentSize.height)
//    }
//}

extension Int {
    var toTimerLabel: String {
        let h = self / 3600
        let m = (self % 3600) / 60
        let s = (self % 3600) % 60
        return h > 0 ? String(format: "%1d:%02d:%02d", h, m, s) : String(format: "%1d:%02d", m, s)
    }
}

public extension Animation { static let instant = Animation.linear(duration: 0.0001) }

public struct StoppableAnimationModifier<Value: VectorArithmetic>: AnimatableModifier {
    @Binding var binding: Value
    @Binding var paused: Bool
    
    public var animatableData: Value
    
    public init(binding: Binding<Value>,
                paused: Binding<Bool>) {
        _binding = binding
        _paused = paused
        animatableData = binding.wrappedValue
    }
    
    public func body(content: Content) -> some View {
        content
            .onChange(of: paused) { isPaused in
                if isPaused {
                    withAnimation(.instant) {
                        binding = animatableData // the magic happens here
                    }
                }
            }
    }
}
