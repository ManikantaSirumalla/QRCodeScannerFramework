//
//  QRScannerFramwork.swift
//  QRCodeScannerFramwork
//
//  Created by Manikanta Sirumalla on 25/08/23.
//

import Foundation

public class QRScannerFramework {
    public static func createQRScannerViewController(delegate: QRScannerDelegate? = nil) -> QRScannerViewController {
        let scannerViewController = QRScannerViewController()
        scannerViewController.delegate = delegate
        return scannerViewController
    }
    
    // Any Other utility methods or functions related to your framework can be added here.
    //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
}
