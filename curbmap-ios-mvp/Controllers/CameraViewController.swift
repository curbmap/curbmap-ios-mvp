//
//  CameraViewController.swift
//  curbmap-ios-mvp
//
//  Created by Peter Wu on 4/3/18.
//  Copyright © 2018 Eli Selkin. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    
    @IBOutlet weak var caturePreviewView: UIView!
    let cameraController = CameraController()
    
    override func viewDidLoad() {
        func configureCameraController() {
            cameraController.prepare { (error) in
                if let error = error {
                    print(error)
                }
                try? self.cameraController.displayPreview(on: self.caturePreviewView)
            }
        }
        configureCameraController()
    }
    
}


