//
//  File.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 09/07/2023.
//

#if os(iOS)
import SwiftUI
public final class TimePickerView: UIPickerView {
    
    static let labelPaddingLeft = 12.0
    static let labelWidth       = 30.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        dataSource = self
        delegate   = self
    }
    
    private lazy var hoursLabel: UILabel = {
        let label = makeDefaultLabel()
        label.text = "horas"
        return label
    }()
    
    private lazy var minutesLabel: UILabel = {
        let label = makeDefaultLabel()
        label.text = "minutos"
        return label
    }()
    
    private lazy var secondsLabel: UILabel = {
        let label = makeDefaultLabel()
        label.text = "s"
        return label
    }()
    
    
    func makeDefaultLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let parentSubview = subviews[0]
        let overlayView   = subviews[1]

        if let componentWidth = (parentSubview.subviews[0].findFirstPickerLabelInViewHierarchy())?.frame.width {
            let labelWidth = TimePickerView.labelWidth
            let leftPadding = TimePickerView.labelPaddingLeft
            let additionalPadding = 4.0
            overlayView.addSubview(hoursLabel)
            overlayView.addSubview(minutesLabel)
            overlayView.addSubview(secondsLabel)
            let spaceBetween = (overlayView.frame.width - componentWidth * 3) / 2
            NSLayoutConstraint.activate([
                hoursLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                minutesLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                secondsLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                hoursLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: leftPadding + labelWidth + additionalPadding),
                minutesLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: leftPadding + componentWidth + labelWidth + spaceBetween + additionalPadding),
                secondsLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: leftPadding + componentWidth * 2 + labelWidth + spaceBetween * 2 + additionalPadding)
            ])
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct Data {
        let hours: Int
        let minutes: Int
        let seconds: Int
        
        var isIdle: Bool {
            hours == 0 && minutes == 0 && seconds == 0
        }
        
    }
    
    func getData() -> Data {
        let hours   = selectedRow(inComponent: 0)
        let minutes = selectedRow(inComponent: 1)
        let seconds = selectedRow(inComponent: 2)
        
        return .init(hours: hours, minutes: minutes, seconds: seconds)
    }
}

// MARK: - Utilities
extension UIView {
    func findFirstPickerLabelInViewHierarchy() -> TimePickerView.PickerLabelView? {
        if let label = self as? TimePickerView.PickerLabelView {
            return label
        }
        
        for subview in self.subviews {
            if let label = subview.findFirstPickerLabelInViewHierarchy() {
                return label
            }
        }
        
        return nil
    }
}


// MARK: - PickerLabel
extension TimePickerView {
    /// View that holds the picker UILabel.
    /// Needed for retrieving component and dynamically calculate width through  findFirstPickerLabelInViewHierarchy method
    final class PickerLabelView: UIView {
        private lazy var label: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 22)
            label.textAlignment = .right
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        /// Setup label with constraints
        /// - width anchor: Needed for right alignment to be visible. Otherwise shorter labels, like "0" will be centered and alignment wouldn't be noticeable
        /// - leading padding: Needed pining label to the left, as using a single UILable in UIPicker would pin it to the center
        func setup() {
            addSubview(label)
            NSLayoutConstraint.activate([
                label.centerYAnchor.constraint(equalTo: centerYAnchor),
                label.widthAnchor.constraint(equalToConstant: TimePickerView.labelWidth),
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: TimePickerView.labelPaddingLeft)
            ])
        }
        
        func setLabelText(_ title: String) {
            label.text = title
        }
    }
}

// MARK: - PickerDelegate
extension TimePickerView: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = PickerLabelView()
        view.setLabelText(row.description)
        return view
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            let newText = (row == 1) ? "hora" : "horas"
            animateLabelChange(for: hoursLabel, newText: newText)
        case 1:
            let newText = (row == 1) ? "minuto" : "minutos"
            animateLabelChange(for: minutesLabel, newText: newText)
        default: break
        }
    }

    private func animateLabelChange(for label: UILabel, newText: String) {
        UIView.transition(with: label, duration: 0.3, options: .transitionCrossDissolve, animations: {
            label.text = newText
        }, completion: nil)
    }
}

// MARK: - PickerDataSource
extension TimePickerView: UIPickerViewDataSource {
    
  
    public func numberOfComponents(in pickerView: UIPickerView) -> Int { 3 }
    
    func pickerView(_ pickerView: UIPickerView, accessibilityLabelForComponent component: Int) -> String? {
        switch component {
        case 0: return "Hours"
        case 1: return "Minutes"
        case 2: return "Seconds"
        default: return nil
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return 24
        case 1: return 60
        case 2: return 60
        default: return 1
        }
    }
}

public struct TimePickerViewRepresentable: UIViewRepresentable {
    
    public let view = TimePickerView()
    
    public init() {}
    public func makeUIView(context: Context) -> some TimePickerView {
        return view
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {}
    
    func getData() -> TimePickerView.Data {
        view.getData()
    }
}
#endif
