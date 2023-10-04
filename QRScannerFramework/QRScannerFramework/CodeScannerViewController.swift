//
//  CodeScannerViewModel.swift
//  CodeScanner
//
//  Created by Manikanta Sirumalla on 04/10/23.
//

import Foundation
import UIKit
import AVFoundation

public class CodeScannerViewController: UIViewController {
    var captureSession: AVCaptureSession?
    weak var delegate: CodeScannerDelegate?
    var viewfinderOverlayView: CodeViewfinderOverlayView!
    var codeDetected = false
    
//    public required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
    public func startScanning(metadataObjectTypes: [AVMetadataObject.ObjectType]) {
        captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            showError(.noCameraAvailable)
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession!.canAddInput(videoInput) {
                captureSession!.addInput(videoInput)
            } else {
                showError(.inputNotSupported)
                return
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            if captureSession!.canAddOutput(metadataOutput) {
                captureSession!.addOutput(metadataOutput)
            } else {
                showError(.outputNotSupported)
                return
            }
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = metadataObjectTypes
            
            captureSession?.startRunning()
        
        } catch {
            showError(.inputNotSupported)
        }
    }
    
    public func stopScanning() {
        captureSession?.stopRunning()
    }
    
    private func showError(_ error: CodeScannerError) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Error occurred while Scanning!", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
            self.captureSession = nil
        }
    }
}

extension CodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let codeString = metadataObject.stringValue, !codeDetected else { return }
        
        codeDetected = true
        captureSession?.stopRunning()
        
        delegate?.codeScannerDidDetectCode(codeString)
        
        // Change the tint color to green
        viewfinderOverlayView.imageView.tintColor = .systemGreen
        
        // Show an alert with appropriate buttons
        viewfinderOverlayView.presentCodeAlert(codeString: codeString)
        
        viewfinderOverlayView.updateInfoLabel(withText: codeString)
    }
}

