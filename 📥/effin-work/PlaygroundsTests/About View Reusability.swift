////
////  About View Reusability.swift
////  PlaygroundsTests
////
////  Created by Cristian Patiño Rojas on 23/11/23.
////
//
//import Foundation
///// #privado -> smartwifi cuidado!
//final class UIImageView {}
//class EnqueuedDeviceListCell {
//    private lazy var handleIcon: UIImageView = {
//        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
//        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
//        imageView.image = UIImage(named: "icHandle")?.withTintColor(.neutralHigh)
//        return imageView
//    }()
//
//    private lazy var contentStackView: UIStackView = {
//        let stackView = UIStackView(arrangedSubviews: [handleIcon])
//        stackView.alignment = .center
//        return stackView
//    }()
//
//    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setUpControlView()
//        setUpAccessibilityIDs()
//    }
//
//    @available(*, unavailable)
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    public var isBeingPrioritized: Bool = false {
//        didSet {
//            handleIcon.isHidden = isBeingPrioritized
//            listCellContentView.subtitleLabel.isHidden = !isBeingPrioritized
//            alpha = isBeingPrioritized
//                ? Constants.Global.alphaMed
//                : Constants.Global.alphaMax
//        }
//    }
//
//    /// Si se quiere que el componente sea reusable, el método configure debería de aceptar tipos primitivos.
//    /// Y la configuración debería de ser hecha en el exterior.
//    /// Aunque, que probabilidades hay de que se necesite reutilizar esta celda ?
//    /// Merece la pena ?
//    /// En un caso como este, un init si que puede ser útil. Para indicar al owner de la vista lo que se necesita para configurarla.
//    func configure(forDevice device: Device, isCurrentPrioritizableDevice: Bool) {
//        listCellContentView.title = isCurrentPrioritizableDevice ? (device.displayName ?? "") + DeviceIds.thisDevice.localized() : device.displayName
//        listCellContentView.titleNumberOfLines = 1
//        listCellContentView.subtitle = LocaleIds.enqueuedProgress.localized()
//        listCellContentView.subtitleLabel.isHidden = true
//
//        let assetImage = UIImage.drawIconInsideCircle(
//            withDeviceType: device.deviceType ?? .computer,
//            imageSize: CGSize(width: 40.0, height: 40.0),
//            sizingMode: .scale(0.65)
//        )
//        listCellContentView.assetType = .image(assetImage ?? UIImage())
//    }
//}
//
//private extension EnqueuedDeviceListCell {
//    func setUpControlView() {
//        listCellContentView.controlView = contentStackView
//    }
//
//    func setUpAccessibilityIDs() {
//        listCellContentView.titleAccessibilityIdentifier = DeviceDetailQA.videocallsDeviceName
//        listCellContentView.subtitleAccessibilityIdentifier = LocaleIds.enqueuedProgress
//    }
//}
//
