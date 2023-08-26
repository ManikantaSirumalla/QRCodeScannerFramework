//
//  ViewController.swift
//  QRExample
//
//  Created by Manikanta Sirumalla on 26/08/23.
//

import UIKit
import QRCodeScannerFrameworkforIphones

class ViewController: UIViewController, QRScannerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let qrScannerVC = QRScannerFramework.createQRScannerViewController(delegate: self)
        present(qrScannerVC, animated:true, completion: nil)
        
    }
    
    func qrScannerDidDetectCode(_ code: String) {
        print("Scanned QR Code: \(code)")
    }
}

