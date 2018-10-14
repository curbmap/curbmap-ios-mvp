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
    
    @IBOutlet weak var capturePreviewView: UIView! {
        didSet {
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchToZoom(_:)))
            self.capturePreviewView.addGestureRecognizer(pinch)
        }
    }
    
    let cameraController = CameraController()
    var stillImage: UIImage?
    var currentLocation: CLLocation?
    var currentHeading: CLHeading?
    
    override func viewDidLoad() {
        // hide navigation bar
        self.navigationController?.navigationBar.isHidden = true
        
        func configureCameraController() {
            cameraController.prepare { (error) in
                if let error = error {
                    print(error)
                }
                try? self.cameraController.displayPreview(on: self.capturePreviewView)
            }
        }
        configureCameraController()
    }
    
    @IBAction func cameraButtonDidPressed(_ sender: UIButton) {
        if let location = LocationServices.currentLocation.getLocation(), let heading = LocationServices.currentLocation.getHeading() {
            currentLocation = location
            currentHeading = heading
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
        } else {
            let alert = UIAlertController(title: "Location services", message: "Location services are required for photos to have necessary data. If you wish to help make parking easier, allow location services in settings.", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Settings", style: .default) {(_)-> Void in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style:.cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func pinchToZoom(_ pinchGestureRecognizer:UIPinchGestureRecognizer) {
        switch pinchGestureRecognizer.state {
        case .changed:
            cameraController.cameraViewZoomedBy(zoomFactor: pinchGestureRecognizer.scale)
        default: break
        }
    }
    
    // MARK: - Segue -
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let displayViewController = segue.destination as? DisplayViewController {
            displayViewController.image = stillImage
            displayViewController.currentLocation = currentLocation
            displayViewController.currentHeading = currentHeading
        }
    }
    
}


