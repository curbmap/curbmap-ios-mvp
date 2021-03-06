//
//  DisplayViewController.swift
//  curbmap
//
//  Created by Peter Wu on 4/10/18.
//  Copyright © 2018 curbmap. All rights reserved.
//

import UIKit
import MapKit

class DisplayViewController: UIViewController {
    
    @IBOutlet weak var capturedImage: UIImageView!
    @IBOutlet weak var displayMessage: UILabel!
    var image: UIImage?
    var isLocationEnabled = CLLocationManager.locationServicesEnabled(){
        didSet {
            if isLocationEnabled {
                
                currentLocation = LocationServices.currentLocation
            } else {
                print("unable to retrieve location")
            }
        }
    }
    var currentLocation: LocationServices?
    // MARK: - View Config
    override func viewDidLoad() {
        if let image = image {
            capturedImage.image = image
            displayMessage.text = "Uploading signs..."
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // get location/device info of user
        guard let currentLocation = currentLocation else { return }
        let heading = currentLocation.getHeading()
        let location = currentLocation.getLocation()
        let currentDevice = UIDevice.current
        let deviceDescription = APIManager.DeviceDescription(name: currentDevice.name, systemName: currentDevice.systemName, systemVersion: currentDevice.systemVersion, model: currentDevice.model)
        
        if let image = self.image {
            // uploads image and associated location data to server
            APIManager.shared.uploadImage(heading: heading, location: location, deviceDescription: deviceDescription, image: image) { (successMessage, error) in
                if let error = error {
                    print(error)
                    self.displayMessage.text = "Upload Error"
                } else {
                    self.displayMessage.text = "Upload Success!"
                    
                }
            }
        }
    }
    
    // MARK: - User Action
    @IBAction func cameraButtonDidPressed(_ sender: UIButton) {
        // dismiss viewcontroller and go back to camera view
        self.dismiss(animated: true, completion: nil)
    }
}
