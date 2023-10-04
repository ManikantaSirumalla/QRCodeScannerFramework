//
//  QRScannerViewController.swift
//  QRCodeScannerFramwork
//
//  Created by Manikanta Sirumalla on 25/08/23.
//
import Foundation
import UIKit
import AVFoundation

public protocol QRScannerDelegate: AnyObject {
    func qrScannerDidDetectCode(_ code: String)
    func barcodeScannerDidDetectCode(_ code: String)
    func codeScannerDidClose()
}

public class QRScannerViewController: UIViewController {
    private var codeDetected = false
    public weak var delegate: QRScannerDelegate?
    private var captureSession: AVCaptureSession?
    //private var viewfinderOverlayView: QRViewfinderOverlayView!
    private var viewfinderOverlayView: BarCodeViewfinderOverlayView!
    
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession!)
        layer.frame = view.layer.bounds
        return layer
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
    
    private func setupCloseUI() {
        // Add the close button as a subview
        view.addSubview(closeButton)
        
        // Configure the close button constraints (adjust as needed)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            closeButton.widthAnchor.constraint(equalToConstant: 32.0),
            closeButton.heightAnchor.constraint(equalToConstant: 32.0)
        ])
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
        setupCloseUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Create and add the viewfinder overlay
        viewfinderOverlayView = BarCodeViewfinderOverlayView(frame: CGRect(x: (view.bounds.width - 200) / 2, y: (view.bounds.height - 200) / 2, width: 200, height: 200))
        view.addSubview(viewfinderOverlayView)
        
        // Start the animation for the moving line
        viewfinderOverlayView.animateMovingLine()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startCamera()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCamera()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            showCameraSetupError(.noCameraAvailable)
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession!.canAddInput(videoInput) {
                captureSession!.addInput(videoInput)
            } else {
                showCameraSetupError(.inputNotSupported)
                return
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            if captureSession!.canAddOutput(metadataOutput) {
                captureSession!.addOutput(metadataOutput)
            } else {
                showCameraSetupError(.outputNotSupported)
                return
            }
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = [.qr, .ean13, .code128]
            
            view.layer.addSublayer(previewLayer)
            
            // Call startCamera on a background thread
            startCamera()
            
        } catch {
            showCameraSetupError(.inputNotSupported)
        }
    }
    
    
    private func restartScanning() {
        // Stop the current session and release resources
        captureSession?.stopRunning()
        captureSession = nil
        
        // Setup and start a new scanning session
        setupCamera()
        startCamera()
    }
    
    
    private func startCamera() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.startRunning()
        }
    }
    
    private func stopCamera() {
        captureSession?.stopRunning()
    }
    
    private func generateImageFromQRCode(metadataObject: AVMetadataMachineReadableCodeObject) -> UIImage? {
        // Check if the metadataObject has valid bounds
        guard metadataObject.bounds != CGRect.zero else {
            return nil
        }
        
        // Capture a screenshot of the video preview layer
        if let videoPreviewLayer = previewLayer as? AVCaptureVideoPreviewLayer,
           let connection = videoPreviewLayer.connection {
            connection.videoOrientation = .portrait
            
            // Convert metadataObject's bounds to the video preview layer's coordinate system
            let transformedBounds = videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: metadataObject.bounds)
            
            // Capture the screenshot within the bounds of the QR code
            if let screenshot = videoPreviewLayer.screenshot(in: transformedBounds) {
                return screenshot
            }
        }
        
        return nil
    }
    
    
}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let codeString = metadataObject.stringValue,
              !codeDetected else {
            return
        }
        
        codeDetected = true // Set the flag to true
        
        captureSession?.stopRunning()
        
        if metadataObject.type == .qr {
            delegate?.qrScannerDidDetectCode(codeString)
        } else if metadataObject.type == .ean13 || metadataObject.type == .code128 {
            delegate?.barcodeScannerDidDetectCode(codeString)
        }
        // Transition to a new view controller to display the QR code and bounding box
        if let qrCodeDisplayVC = CodeDisplayViewController(codeMetadataObject: metadataObject, codeImage: generateImageFromQRCode(metadataObject: metadataObject)) {
            navigationController?.pushViewController(qrCodeDisplayVC, animated: true)
        }
        
        // Change the tint color to green
        viewfinderOverlayView.imageView.tintColor = .systemGreen
        
        // Show an alert with appropriate buttons
        viewfinderOverlayView.presentCodeAlert(codeString: codeString)
        
        viewfinderOverlayView.updateInfoLabel(withText: codeString)
        
        // Setup and start a new scanning session after a brief delay (to allow for UI transition)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.setupCamera()
            self?.startCamera()
        }
        
    }
}

extension AVCaptureVideoPreviewLayer {
    func screenshot(in rect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            self.render(in: context)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // Crop the screenshot to the specified rect
            if let cgImage = screenshot?.cgImage?.cropping(to: rect) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}


extension QRScannerViewController {
    enum CameraError: Error {
        case noCameraAvailable
        case inputNotSupported
        case outputNotSupported
        
        var localizedDescription: String {
            switch self {
            case .noCameraAvailable:
                return "No camera is available on this device."
            case .inputNotSupported:
                return "The camera input is not supported."
            case .outputNotSupported:
                return "The metadata output is not supported."
            }
        }
    }
    
    private func showCameraSetupError(_ error: CameraError) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Camera Setup Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
            self.captureSession = nil
        }
    }
}

class QRViewfinderOverlayView: UIView {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "viewfinder") // Replace with the system image name you want to use
        imageView.tintColor = .systemBlue // Customize the tint color if needed
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.text = "Place the QR code in the frame to scan"
        return label
    }()
    
    private let lineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.systemBlue.cgColor // Line color
        layer.lineWidth = 2.0 // Line thickness
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(imageView)
        addSubview(infoLabel)
        animateMovingLine()
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
        
        // Add the line layer to the view's layer
        layer.addSublayer(lineLayer)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Function to animate the moving line
    func animateMovingLine() {
        // Define the line's height and vertical movement range
        let lineHeight: CGFloat = 2.0
        let verticalRange: CGFloat = imageView.bounds.height - lineHeight
        
        // Create an animation for the line's position
        let animation = CABasicAnimation(keyPath: "position.y")
        animation.fromValue = lineLayer.position.y
        animation.toValue = lineLayer.position.y + verticalRange
        animation.duration = 1.0
        animation.repeatCount = .greatestFiniteMagnitude
        lineLayer.add(animation, forKey: "lineAnimation")
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

class BarCodeViewfinderOverlayView: UIView {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "viewfinder.rectangular") // Replace with the system image name you want to use
        imageView.tintColor = .systemBlue // Customize the tint color if needed
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.text = "Place the bar code in the frame to scan"
        return label
    }()
    
    private let lineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.systemBlue.cgColor // Line color
        layer.lineWidth = 2.0 // Line thickness
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(imageView)
        addSubview(infoLabel)
        animateMovingLine()
        // Configure the constraints to center the image view within the overlay view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 4.0), // Adjust the multiplier to control the width
               imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3) // Adjust the multiplier to control the height
        ])
        
        // Configure constraints for the label
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            infoLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10.0) // Adjust vertical position
        ])
        
        // Add the line layer to the view's layer
        layer.addSublayer(lineLayer)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Function to animate the moving line
    func animateMovingLine() {
        // Define the line's height and vertical movement range
        let lineHeight: CGFloat = 2.0
        let verticalRange: CGFloat = imageView.bounds.height - lineHeight
        
        // Create an animation for the line's position
        let animation = CABasicAnimation(keyPath: "position.y")
        animation.fromValue = lineLayer.position.y
        animation.toValue = lineLayer.position.y + verticalRange
        animation.duration = 1.0
        animation.repeatCount = .greatestFiniteMagnitude
        lineLayer.add(animation, forKey: "lineAnimation")
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

//class CodeViewfinderOverlayView: UIView {
//    enum CodeType {
//        case qrCode
//        case barcode
//    }
//
//    var codeType: CodeType = .qrCode {
//        didSet {
//            updateUIForCodeType()
//            animateMovingLine()
//        }
//    }
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
//        label.text = "Place the QR code in the frame to scan"
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
//    private func updateUIForCodeType() {
//        switch codeType {
//        case .qrCode:
//            // Update UI for QR codes
//            imageView.image = UIImage(systemName: "viewfinder") // QR code image
//            imageView.tintColor = .systemBlue // QR code tint color
//            lineLayer.strokeColor = UIColor.systemBlue.cgColor // Line color for QR code
//
//        case .barcode:
//            // Update UI for barcodes
//            imageView.image = UIImage(systemName: "viewfinder") // Barcode image
//            imageView.tintColor = .systemBlue// Barcode tint color
//            lineLayer.strokeColor = UIColor.systemGreen.cgColor // Line color for barcode
//        }
//    }
//
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

class CodeDisplayViewController: UIViewController {
    var codeImageView: UIImageView!
    
    init?(codeMetadataObject: AVMetadataMachineReadableCodeObject, codeImage: UIImage?) {
        super.init(nibName: nil, bundle: nil)
        
        guard let image = codeImage else {
            return nil
        }
        
        codeImageView = UIImageView(image: image)
        codeImageView.contentMode = .scaleAspectFit
        codeImageView.frame = codeMetadataObject.bounds
        
        view.addSubview(codeImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIViewController {
    func topmostViewController() -> UIViewController {
        if let presentedViewController = presentedViewController {
            return presentedViewController.topmostViewController()
        }
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topmostViewController() ?? navigationController
        }
        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topmostViewController() ?? tabBarController
        }
        return self
    }
}
