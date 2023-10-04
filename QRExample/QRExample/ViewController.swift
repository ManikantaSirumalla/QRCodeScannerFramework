//
//  ViewController.swift
//  QRExample
//
//  Created by Manikanta Sirumalla on 26/08/23.
//
import UIKit
import QRCodeScannerFrameworkforIphones

class ViewController: UIViewController, QRScannerDelegate {
    // UI Elements
    private let barcodeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let qrCodeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let scanBarcodeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Scan Barcode", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(startBarcodeScanning), for: .touchUpInside)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 20
        return button
    }()
    
    private let scanQRCodeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Scan QR Code", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(startQRCodeScanning), for: .touchUpInside)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 20
        return button
    }()
    
    // QR Code and Barcode Images
    private let qrCodeImage = UIImage(systemName: "qrcode.viewfinder") // Replace with your QR code image
    private let barcodeImage = UIImage(systemName: "barcode.viewfinder") // Replace with your barcode image
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Add barcode image view and button
        view.addSubview(barcodeImageView)
        view.addSubview(scanBarcodeButton)
        
        // Add QR code image view and button
        view.addSubview(qrCodeImageView)
        view.addSubview(scanQRCodeButton)
        
        // Set up constraints for barcode image view and button
        barcodeImageView.translatesAutoresizingMaskIntoConstraints = false
        scanBarcodeButton.translatesAutoresizingMaskIntoConstraints = false
        qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
        scanQRCodeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Barcode Image View
            barcodeImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            barcodeImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            barcodeImageView.widthAnchor.constraint(equalToConstant: 300),
            barcodeImageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Scan Barcode Button
            scanBarcodeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanBarcodeButton.topAnchor.constraint(equalTo: barcodeImageView.bottomAnchor, constant: 20),
            scanBarcodeButton.widthAnchor.constraint(equalToConstant: 200),
            scanBarcodeButton.heightAnchor.constraint(equalToConstant: 50),
            
            // QR Code Image View
            qrCodeImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            qrCodeImageView.topAnchor.constraint(equalTo: scanBarcodeButton.bottomAnchor, constant: 20),
            qrCodeImageView.widthAnchor.constraint(equalToConstant: 300),
            qrCodeImageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Scan QR Code Button
            scanQRCodeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanQRCodeButton.topAnchor.constraint(equalTo: qrCodeImageView.bottomAnchor, constant: 20),
            scanQRCodeButton.widthAnchor.constraint(equalToConstant: 200),
            scanQRCodeButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        // Set barcode and QR code images
        barcodeImageView.image = barcodeImage
        qrCodeImageView.image = qrCodeImage
    }
    
    @objc private func startBarcodeScanning() {
        let barcodeScannerVC = QRScannerFramework.createBarcodeScannerViewController(delegate: self)
        present(barcodeScannerVC, animated: true, completion: nil)
    }
    
    @objc private func startQRCodeScanning() {
        let qrScannerVC = QRScannerFramework.createQRScannerViewController(delegate: self)
        present(qrScannerVC, animated: true, completion: nil)
    }
    
    func qrScannerDidDetectCode(_ code: String) {
        print("Scanned QR Code: \(code)")
    }
    
    func barcodeScannerDidDetectCode(_ code: String) {
        print("Scanned Barcode: \(code)")
    }
    
    func codeScannerDidClose() {
        dismiss(animated: true, completion: nil)
    }
}
