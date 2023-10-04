//
//  Error.swift
//  CodeScanner
//
//  Created by Manikanta Sirumalla on 04/10/23.
//

import Foundation
import UIKit

public enum CodeScannerError: Error {
    case noCameraAvailable
    case inputNotSupported
    case outputNotSupported
    
    var localizedDescription: String {
        switch self {
        case .noCameraAvailable:
            return "No camera is available on this device."
        case .inputNotSupported:
            return "The camera input is not supported."
        case .outputNotSupported:
            return "The metadata output is not supported."
        }
    }
}
