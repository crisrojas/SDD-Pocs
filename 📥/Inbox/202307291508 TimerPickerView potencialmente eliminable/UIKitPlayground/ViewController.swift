import UIKit

final class TimePickerView: UIPickerView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        dataSource = self
        delegate   = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let parentSubview = subviews.first(where: { $0.subviews.count > 0})
        parentSubview?.subviews[1].disableScroll()
        parentSubview?.subviews[3].disableScroll()
        parentSubview?.subviews[5].disableScroll()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getValues() -> (hours: Int, minutes: Int, seconds: Int) {
        let hours   = selectedRow(inComponent: 0)
        let minutes = selectedRow(inComponent: 2)
        let seconds = selectedRow(inComponent: 4)
        
        return (hours: hours, minutes: minutes, seconds: seconds)
    }
}

extension UIView {
    func disableScroll() {
        if let scrollView = self as? UIScrollView {
            scrollView.isScrollEnabled = false
        } else {
            for subview in self.subviews {
                subview.disableScroll()
            }
        }
    }
    
}
extension TimePickerView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        let rowLabel = UILabel()
        let descriptionLabel = UILabel()

        rowLabel.text = row.description
        rowLabel.font = UIFont.systemFont(ofSize: 20)

        rowLabel.textAlignment = .right
        descriptionLabel.textAlignment = .left
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
       

        switch component {
        case 1:
            descriptionLabel.text = "hours"
            return descriptionLabel
        case 3:
            descriptionLabel.text = "min"
            return descriptionLabel
        case 5:
            descriptionLabel.text = "s"
            return descriptionLabel
        
        default: return rowLabel
        }
    }
}

extension TimePickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 6 }
    
    func pickerView(_ pickerView: UIPickerView, accessibilityLabelForComponent component: Int) -> String? {
        switch component {
        case 0: return "Hours"
        case 2: return "Minutes"
        case 4: return "Seconds"
        default: return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return 24
        case 2: return 60
        case 4: return 60
        default: return 1
        }
    }
}

class ViewController: UIViewController {
    private let pickerView = TimePickerView()
    private var selectedHours  : Int = 0
    private var selectedMinutes: Int = 0
    private var selectedSeconds: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pickerView)
        
        NSLayoutConstraint.activate([
            pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 24.0)
        ])
    }
    
    @objc private func startButtonTapped() {
       print(pickerView.getValues())
    }
}


extension UIPickerView {
    func disableUIPickerViewComponent(_ componentToDisable: Int) {
        let pickerViews = subviews
        var mainSubview: UIView?
        
        for temp in pickerViews {
            if temp.frame.size.height > 100 {
                mainSubview = temp
                break
            }
        }
        
        if let componentSubview = mainSubview?.subviews {
            if componentSubview.indices.contains(componentToDisable) {
                let subComponentView = componentSubview[componentToDisable].subviews
                if let gestureRecognizers = subComponentView.first?.superview?.gestureRecognizers {
                    for gestureRecognizer in gestureRecognizers {
                        subComponentView.first?.superview?.removeGestureRecognizer(gestureRecognizer)
                    }
                }
            }
        }
    }
}
