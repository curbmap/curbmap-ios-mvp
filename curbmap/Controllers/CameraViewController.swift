//
//  CameraViewController.swift
//  curbmap
//
//  Created by Peter Wu on 4/3/18.
//  Copyright © 2018 curbmap. All rights reserved.
//

import UIKit
import Photos
import RxCoreLocation
import RxSwift
import RxCocoa

class CameraViewController: UIViewController {
    
    @IBOutlet weak var capturePreviewView: UIView! {
        didSet {
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchToZoom(_:)))
            self.capturePreviewView.addGestureRecognizer(pinch)
        }
    }
    
    let cameraController = CameraController()
    let bag = DisposeBag()
    var stillImage: UIImage?
    var cameraLocationAvailable = Variable<Bool>(false);
    var currentLocation: CLLocation?
    var currentHeading: CLHeading?
    override func viewDidLoad() {
        // start getting location
        LocationServices.currentLocation.locationManager.rx
            .didUpdateLocations
            .debug("didUpdateLocations")
            .subscribe(onNext: {value in
                self.currentLocation = value.locations.last;
                if let heading = self.currentHeading {
                    self.cameraLocationAvailable.value = true
                } else {
                    self.cameraLocationAvailable.value = false
                }
            }).disposed(by: bag)
        LocationServices.currentLocation.locationManager.rx
            .didUpdateHeading
            .debug("didUpdateHeading")
            .subscribe(onNext: {value in
                self.currentHeading = value.newHeading
                if let location = self.currentLocation {
                    self.cameraLocationAvailable.value = true
                } else {
                    self.cameraLocationAvailable.value = false
                }
            }).disposed(by: bag)
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
        cameraLocationAvailable.asObservable().subscribe(onNext: {value in
            // it starts as false, so any next value will be true
            if (value == true) { // just explicit test
                // camera has location and heading!
                self.cameraController.captureImage { (image, error) in
                    if let error = error {
                        print(error)
                    } else if let image = image {
                        self.stillImage = image
                        DispatchQueue.main.async {
                          self.performSegue(withIdentifier: "cameraSegue", sender: sender)
                        }
                    } else {
                        print("unknown error")
                    }
                }
            }
        }).dispose()
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


