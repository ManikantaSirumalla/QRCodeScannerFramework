//
//  AVCapturePreviewLayer.swift
//  CodeScanner
//
//  Created by Manikanta Sirumalla on 04/10/23.
//

import AVFoundation
import UIKit

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
