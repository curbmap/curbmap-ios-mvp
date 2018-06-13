//
//  CameraViewController.swift
//  curbmap
//
//  Created by Peter Wu on 4/3/18.
//  Copyright © 2018 curbmap. All rights reserved.
//

import UIKit
import Photos

class CameraViewController: UIViewController {
    
    @IBOutlet weak var caturePreviewView: UIView!
    let cameraController = CameraController()
    var stillImage: UIImage?
    
    override func viewDidLoad() {
        // hide navigation bar
        self.navigationController?.navigationBar.isHidden = true
        
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
    
    @IBAction func cameraButtonDidPressed(_ sender: UIButton) {
        cameraController.captureImage { (image, error) in
            if let error = error {
                print(error)
            } else if let image = image {
                self.stillImage = image
                self.performSegue(withIdentifier: "cameraSegue", sender: sender)
            } else {
                print("unknown error")
            }
        }
    }
    
    // MARK: - Segue -
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let displayViewController = segue.destination as! DisplayViewController
        if let stillImage = stillImage {
            displayViewController.image = stillImage
        } else {
            print("error no stillimage")
        }
    }
    
    
    
}


