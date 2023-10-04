//
//  generateImageFromCode.swift
//  CodeScanner
//
//  Created by Manikanta Sirumalla on 05/10/23.
//

import Foundation
import UIKit
import AVFoundation

func generateImageFromCode(metadataObject: AVMetadataMachineReadableCodeObject, previewLayer: AVCaptureVideoPreviewLayer) -> UIImage? {
    // Check if the metadataObject has valid bounds
    guard metadataObject.bounds != CGRect.zero else {
        return nil
    }
    
    // Capture a screenshot of the video preview layer
    if let connection = previewLayer.connection {
        connection.videoOrientation = .portrait
        
        // Convert metadataObject's bounds to the video preview layer's coordinate system
        let transformedBounds = previewLayer.layerRectConverted(fromMetadataOutputRect: metadataObject.bounds)
        
        // Capture the screenshot within the bounds of the QR code
//        if let screenshot = previewLayer.screenshot(in: transformedBounds) {
//            return screenshot
//        }
    }
    
    return nil
}
