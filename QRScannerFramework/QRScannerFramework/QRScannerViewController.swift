//////
//////  QRScannerViewController.swift
//////  QRCodeScannerFramwork
//////
//////  Created by Manikanta Sirumalla on 25/08/23.
//////
////
//import Foundation
//import UIKit
//import AVFoundation
//
//public protocol QRScannerDelegate: AnyObject {
//    func qrScannerDidDetectCode(_ code: String)
//}
//
//public class QRScannerViewController: UIViewController {
//    
//    public weak var delegate: QRScannerDelegate?
//    private var overlayView: QRScanOverlayView!
//    private var captureSession: AVCaptureSession?
//    
//    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
//        let layer = AVCaptureVideoPreviewLayer(session: captureSession!)
//        layer.frame = view.layer.bounds
//        return layer
//    }()
//    
//    public override func viewDidLoad() {
//        super.viewDidLoad()
//        setupCamera()
//        setupOverlayView()
//    }
//    
//    public override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        startCamera()
//    }
//    
//    public override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        stopCamera()
//    }
//    
//    private func setupOverlayView() {
//        overlayView = QRScanOverlayView(frame: view.bounds)
//        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        view.addSubview(overlayView)
//    }
//
//    private func setupCamera() {
//        captureSession = AVCaptureSession()
//        
//        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
//            showCameraSetupError(.noCameraAvailable)
//            return
//        }
//        
//        do {
//            let videoInput = try AVCaptureDeviceInput(device: captureDevice)
//            if captureSession!.canAddInput(videoInput) {
//                captureSession!.addInput(videoInput)
//            } else {
//                showCameraSetupError(.inputNotSupported)
//                return
//            }
//            
//            let metadataOutput = AVCaptureMetadataOutput()
//            if captureSession!.canAddOutput(metadataOutput) {
//                captureSession!.addOutput(metadataOutput)
//            } else {
//                showCameraSetupError(.outputNotSupported)
//                return
//            }
//            
//            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
//            metadataOutput.metadataObjectTypes = [.qr]
//            
//            view.layer.addSublayer(previewLayer)
//            
//            // Call startCamera on a background thread
//            startCamera()
//            
//        } catch {
//            showCameraSetupError(.inputNotSupported)
//        }
//    }
//
//
//    private func startCamera() {
//        DispatchQueue.global(qos: .userInitiated).async {
//            self.captureSession?.startRunning()
//        }
//    }
//    
//    private func stopCamera() {
//        captureSession?.stopRunning()
//    }
//    
//    private func generateImageFromQRCode(metadataObject: AVMetadataMachineReadableCodeObject) -> UIImage? {
//        // Check if the metadataObject has valid bounds
//        guard metadataObject.bounds != CGRect.zero else {
//            return nil
//        }
//        
//        // Capture a screenshot of the video preview layer
//        if let videoPreviewLayer = previewLayer as? AVCaptureVideoPreviewLayer,
//           let connection = videoPreviewLayer.connection {
//            connection.videoOrientation = .portrait
//            
//            // Convert metadataObject's bounds to the video preview layer's coordinate system
//            let transformedBounds = videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: metadataObject.bounds)
//            
//            // Capture the screenshot within the bounds of the QR code
//            if let screenshot = videoPreviewLayer.screenshot(in: transformedBounds) {
//                return screenshot
//            }
//        }
//        
//        return nil
//    }
//
//
//}
//
//extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
//    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
//        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
//              let _ = metadataObject.stringValue else {
//            return
//        }
//        captureSession?.stopRunning()
//        
//        delegate?.qrScannerDidDetectCode(metadataObject.stringValue ?? "")
//        
//        // Transition to a new view controller to display the QR code and bounding box
//        if let qrCodeDisplayVC = QRDisplayViewController(qrCodeMetadataObject: metadataObject, qrCodeImage: generateImageFromQRCode(metadataObject: metadataObject))
//        {
//          navigationController?.pushViewController(qrCodeDisplayVC, animated: true)
//        }
//    }
//}
//
//extension AVCaptureVideoPreviewLayer {
//    func screenshot(in rect: CGRect) -> UIImage? {
//        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
//        if let context = UIGraphicsGetCurrentContext() {
//            self.render(in: context)
//            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//            
//            // Crop the screenshot to the specified rect
//            if let cgImage = screenshot?.cgImage?.cropping(to: rect) {
//                return UIImage(cgImage: cgImage)
//            }
//        }
//        return nil
//    }
//}
//
//
//extension QRScannerViewController {
//    enum CameraError: Error {
//        case noCameraAvailable
//        case inputNotSupported
//        case outputNotSupported
//        
//        var localizedDescription: String {
//            switch self {
//            case .noCameraAvailable:
//                return "No camera is available on this device."
//            case .inputNotSupported:
//                return "The camera input is not supported."
//            case .outputNotSupported:
//                return "The metadata output is not supported."
//            }
//        }
//    }
//    
//    private func showCameraSetupError(_ error: CameraError) {
//        DispatchQueue.main.async {
//            let ac = UIAlertController(title: "Camera Setup Error", message: error.localizedDescription, preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "OK", style: .default))
//            self.present(ac, animated: true)
//            self.captureSession = nil
//        }
//    }
//}
//
//class QRDisplayViewController: UIViewController {
//    var qrCodeImageView: UIImageView!
//
//    init?(qrCodeMetadataObject: AVMetadataMachineReadableCodeObject, qrCodeImage: UIImage?) {
//        super.init(nibName: nil, bundle: nil)
//
//        guard let image = qrCodeImage else {
//            return nil
//        }
//
//        qrCodeImageView = UIImageView(image: image)
//        qrCodeImageView.contentMode = .scaleAspectFit
//        qrCodeImageView.frame = qrCodeMetadataObject.bounds
//
//        view.addSubview(qrCodeImageView)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
//
//class QRScanOverlayView: UIView {
//    override func draw(_ rect: CGRect) {
//        // Draw a blue frame in the middle of the view
//        let frameRect = CGRect(x: bounds.midX - 100, y: bounds.midY - 100, width: 200, height: 200)
//        let framePath = UIBezierPath(rect: frameRect)
//        UIColor.blue.setStroke()
//        framePath.lineWidth = 2.0
//        framePath.stroke()
//    }
//}
