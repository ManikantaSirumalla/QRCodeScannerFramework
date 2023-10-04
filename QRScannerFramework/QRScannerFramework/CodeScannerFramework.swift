//
//  QRScannerFramwork.swift
//  QRCodeScannerFramwork
//
//  Created by Manikanta Sirumalla on 25/08/23.
//

import Foundation

public class CodeScannerFramework {
    public static func createQRScannerViewController(delegate: CodeScannerDelegate? = nil) -> QRCodeScannerViewController {
        let scannerViewController = QRCodeScannerViewController()
        scannerViewController.delegate = delegate
        return scannerViewController
    }
    
    public static func createBarcodeScannerViewController(delegate: CodeScannerDelegate? = nil) -> BarcodeScannerViewController {
        let scannerViewController = BarcodeScannerViewController()
        scannerViewController.delegate = delegate
        return scannerViewController
    }
    
    // Any Other utility methods or functions related to your framework can be added here.
    
    //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
}
