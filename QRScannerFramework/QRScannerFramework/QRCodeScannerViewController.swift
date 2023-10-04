////
////  QRCodeScanner.swift
////  CodeScanner
////
////  Created by Manikanta Sirumalla on 04/10/23.
////

import AVFoundation
import UIKit

public class QRCodeScannerViewController: CodeScannerViewController {
   
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession!)
        layer.frame = view.layer.bounds
        view.layer.addSublayer(layer)
        return layer
    }()
    
    let overlayView: CodeViewfinderOverlayView = {
        let overlay = CodeViewfinderOverlayView()
        overlay.codeType = .qrCode
        return overlay
    }()
    
//     required init(coder: NSCoder) {
//        super.init(coder: coder)
//    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the overlay view to the view hierarchy
        view.addSubview(overlayView)
    }
    
    private func restartScanning() {
        // Stop the current session and release resources
        captureSession?.stopRunning()
        captureSession = nil
        
        // Setup and start a new scanning session
        startQRScanning()
    }
    
    public func startQRScanning() {
        super.startScanning(metadataObjectTypes: [.qr])
    }
    
    // Transition to a new view controller to display the QR code and bounding box
     private func showCodeDisplayViewController(metadataObject: AVMetadataMachineReadableCodeObject) {
         if let codeDisplayVC = CodeDisplayViewController(codeMetadataObject: metadataObject, codeImage: generateImageFromCode(metadataObject: metadataObject, previewLayer: previewLayer)) {
             navigationController?.pushViewController(codeDisplayVC, animated: true)
         }
     }
    
    // Implement the delegate method to handle code detection
    public override func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let codeString = metadataObject.stringValue, !codeDetected else { return }
        
        codeDetected = true
        captureSession?.stopRunning()
        
        delegate?.codeScannerDidDetectCode(codeString)
        
        // Show the CodeDisplayViewController
        showCodeDisplayViewController(metadataObject: metadataObject)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.restartScanning()
        }
    }
}
