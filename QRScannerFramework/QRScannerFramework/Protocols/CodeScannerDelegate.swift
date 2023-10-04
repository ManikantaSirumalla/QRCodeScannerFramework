//
//  CodeScannerDelegate.swift
//  CodeScanner
//
//  Created by Manikanta Sirumalla on 04/10/23.
//

import Foundation

public protocol CodeScannerDelegate: AnyObject {
    func codeScannerDidDetectCode(_ code: String)
    func codeScannerDidClose()
}

