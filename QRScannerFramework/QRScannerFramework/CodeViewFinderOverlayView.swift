//
//  CodeViewFinderViewController.swift
//  CodeScanner
//
//  Created by Manikanta Sirumalla on 04/10/23.
//

import Foundation
import UIKit
//
//class CodeViewinderOverlayView: UIView {
//
//    weak var delegate: CodeScannerDelegate?
//
//    var codeType: CodeType = .qrCode {
//        didSet {
//            //updateUIForCodeType()
//            animateMovingLine()
//        }
//    }
//
//    private lazy var closeButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setImage(UIImage(systemName: "xmark"), for: .normal)
//        button.tintColor = .white
//        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
//        return button
//    }()
//
//    @objc private func closeButtonTapped() {
//        delegate?.codeScannerDidClose()
//    }
//
//    private func setupCloseUI() {
//        // Add the close button as a subview
//        addSubview(closeButton)
//
//        // Configure the close button constraints (adjust as needed)
//        closeButton.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16.0),
//            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
//            closeButton.widthAnchor.constraint(equalToConstant: 32.0),
//            closeButton.heightAnchor.constraint(equalToConstant: 32.0)
//        ])
//    }
//
//    override init(frame: CGRect) {
//           super.init(frame: frame)
//           backgroundColor = .clear
//           addSubview(closeButton)
//           animateMovingLine()
//           setupCloseUI()
//       }
//
//
//    let imageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(systemName: "viewfinder") // Default image for QR code
//        imageView.tintColor = .systemBlue // Default tint color for QR code
//        imageView.contentMode = .scaleAspectFit
//        return imageView
//    }()
//
//    private let infoLabel: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .center
//        label.textColor = .white
//        label.font = UIFont.systemFont(ofSize: 16.0)
//        label.text = "Place the QR/Bar code in the frame to scan"
//        return label
//    }()
//
//    private let lineLayer: CAShapeLayer = {
//        let layer = CAShapeLayer()
//        layer.strokeColor = UIColor.systemBlue.cgColor // Default line color for QR code
//        layer.lineWidth = 2.0 // Default line thickness for QR code
//        return layer
//    }()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = .clear
//        addSubview(imageView)
//        addSubview(infoLabel)
//        animateMovingLine()
//
//        // Configure the constraints to center the image view within the overlay view
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
//            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
//            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 2.0), // Adjust the multiplier to control the size
//            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1) // Adjust the multiplier to control the size
//        ])
//
//        // Configure constraints for the label
//        infoLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            infoLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//            infoLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10.0) // Adjust vertical position
//        ])
//
//        // Add the line layer to the view's layer
//        layer.addSublayer(lineLayer)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // Function to animate the moving line
//    func animateMovingLine() {
//        lineLayer.removeAllAnimations() // Remove previous animations
//
//        switch codeType {
//        case .qrCode:
//            // Vertical animation for QR codes
//            let lineHeight: CGFloat = 2.0
//            let verticalRange: CGFloat = imageView.bounds.height - lineHeight
//
//            let animation = CABasicAnimation(keyPath: "position.y")
//            animation.fromValue = lineLayer.position.y
//            animation.toValue = lineLayer.position.y + verticalRange
//            animation.duration = 1.0
//            animation.repeatCount = .greatestFiniteMagnitude
//            lineLayer.add(animation, forKey: "lineAnimation")
//
//        case .barcode:
//            // Horizontal animation for barcodes
//            let lineWidth: CGFloat = 2.0
//            let horizontalRange: CGFloat = imageView.bounds.width - lineWidth
//
//            let animation = CABasicAnimation(keyPath: "position.x")
//            animation.fromValue = lineLayer.position.x
//            animation.toValue = lineLayer.position.x + horizontalRange
//            animation.duration = 1.0
//            animation.repeatCount = .greatestFiniteMagnitude
//            lineLayer.add(animation, forKey: "lineAnimation")
//        }
//    }
//
//    // Update UI based on the code type (QR code or barcode)
////    private func updateUIForCodeType() {
////        switch codeType {
////        case .qrCode:
////            // Update UI for QR codes
////            imageView.image = UIImage(systemName: "viewfinder") // QR code image
////            imageView.tintColor = .systemBlue // QR code tint color
////            lineLayer.strokeColor = UIColor.systemBlue.cgColor // Line color for QR code
////
////        case .barcode:
////            // Update UI for barcodes
////            imageView.image = UIImage(systemName: "barcode") // Barcode image
////            imageView.tintColor = .systemGreen // Barcode tint color
////            lineLayer.strokeColor = UIColor.systemGreen.cgColor // Line color for barcode
////        }
////    }
////
//    // Function to update the info label text
//    func updateInfoLabel(withText text: String) {
//        infoLabel.text = text
//    }
//
//    // Function to present an alert with codeString and appropriate buttons
//    func presentCodeAlert(codeString: String) {
//        let alertController = UIAlertController(title: "Scanned Code", message: codeString, preferredStyle: .alert)
//
//        if let url = URL(string: codeString), UIApplication.shared.canOpenURL(url) {
//            let openURLAction = UIAlertAction(title: "Open URL", style: .default) { _ in
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            }
//            alertController.addAction(openURLAction)
//        }
//
//        let closeAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
//        alertController.addAction(closeAction)
//
//        if let topViewController = UIApplication.shared.keyWindow?.rootViewController?.topmostViewController() {
//            topViewController.present(alertController, animated: true, completion: nil)
//        }
//    }
//
//}


class CodeViewfinderOverlayView: UIView {
    
    weak var delegate: CodeScannerDelegate?
    
    var codeType: CodeType = .qrCode {
        didSet {
            updateUIForCodeType()
            
        }
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "viewfinder")
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.text = "Place the QR/Bar code in the frame to scan"
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func closeButtonTapped() {
        delegate?.codeScannerDidClose()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(imageView)
        addSubview(infoLabel)
        addSubview(closeButton)
        
        // Configure the close button constraints (adjust as needed)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16.0),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            closeButton.widthAnchor.constraint(equalToConstant: 32.0),
            closeButton.heightAnchor.constraint(equalToConstant: 32.0)
        ])
        
        // Configure the constraints to center the image view within the overlay view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 2.0), // Adjust the multiplier to control the size
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1) // Adjust the multiplier to control the size
        ])
        
        // Configure constraints for the label
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            infoLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10.0) // Adjust vertical position
        ])
    }
    
    private func updateUIForCodeType() {
        switch codeType {
        case .qrCode:
            // Update UI for QR codes
            imageView.image = UIImage(systemName: "viewfinder") // QR code image
            imageView.tintColor = .systemBlue // QR code tint color
            //lineLayer.strokeColor = UIColor.systemBlue.cgColor // Line color for QR code
            
        case .barcode:
            // Update UI for barcodes
            imageView.image = UIImage(systemName: "viewfinder.rectangular") // Barcode image
            imageView.tintColor = .systemGreen // Barcode tint color
            //lineLayer.strokeColor = UIColor.systemGreen.cgColor // Line color for barcode
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateInfoLabel(withText text: String) {
        infoLabel.text = text
    }
    
    func presentCodeAlert(codeString: String) {
        let alertController = UIAlertController(title: "Scanned Code", message: codeString, preferredStyle: .alert)
        
        if let url = URL(string: codeString), UIApplication.shared.canOpenURL(url) {
            let openURLAction = UIAlertAction(title: "Open URL", style: .default) { _ in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            alertController.addAction(openURLAction)
        }
        
        let closeAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        alertController.addAction(closeAction)
        
        if let topViewController = UIApplication.shared.keyWindow?.rootViewController?.topmostViewController() {
            topViewController.present(alertController, animated: true, completion: nil)
        }
    }
}

