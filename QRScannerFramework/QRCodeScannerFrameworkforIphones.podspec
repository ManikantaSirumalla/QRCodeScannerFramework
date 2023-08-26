Pod::Spec.new do |spec|
  spec.name         = "QRCodeScannerFrameworkforIphones"
  spec.version      = "1.0.0"
  spec.summary      = "To scan QRCodes using camera"
  spec.description  = "The QRScannerFramework is a versatile and easy-to-use tool that empowers developers to integrate QR code scanning functionality into their iOS applications seamlessly. With built-in support for AVFoundation and CoreImage, this framework offers high-performance QR code recognition and processing capabilities. Whether you're building an app for ticketing, inventory management, or user authentication, the QRScannerFramework simplifies the process of capturing QR codes from the device's camera and extracting relevant data. Harness the power of this framework to enhance user experiences and streamline data input in your app. Take advantage of its intuitive API and customization options to create QR code scanning solutions tailored to your application's unique requirements."
  spec.homepage     = "https://github.com/ManikantaSirumalla/QRCodeScannerFramework"
  spec.license      = "MIT"
  spec.author       = { "Manikanta Sirumalla" => "Manikanta.sirumalla@icloud.com" }
  spec.platform     = :ios, "14.0"
  spec.source       = { :git => "https://github.com/ManikantaSirumalla/QRCodeScannerFramework.git", :tag => spec.version.to_s }
  spec.source_files = "QRScannerFramework/**/*.{swift}"
  spec.frameworks   = "UIKit", "AVFoundation"
  spec.swift_versions = "5.0"
end

