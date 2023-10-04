//
//  CodeDisplayViewController.swift
//  CodeScanner
//
//  Created by Manikanta Sirumalla on 04/10/23.
//

import Foundation
import UIKit
import AVFoundation

class CodeDisplayViewController: UIViewController {
    var codeImageView: UIImageView!
    
    init?(codeMetadataObject: AVMetadataMachineReadableCodeObject, codeImage: UIImage?) {
        super.init(nibName: nil, bundle: nil)
        
        guard let image = codeImage else {
            return nil
        }
        
        codeImageView = UIImageView(image: image)
        codeImageView.contentMode = .scaleAspectFit
        codeImageView.frame = codeMetadataObject.bounds
        
        view.addSubview(codeImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
