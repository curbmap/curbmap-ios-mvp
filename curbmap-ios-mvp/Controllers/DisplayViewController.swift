//
//  DisplayViewController.swift
//  curbmap-ios-mvp
//
//  Created by Peter Wu on 4/10/18.
//  Copyright © 2018 Eli Selkin. All rights reserved.
//

import UIKit

class DisplayViewController: UIViewController {

    @IBOutlet weak var capturedImage: UIImageView!
    @IBOutlet weak var displayMessage: UILabel!
    var image: UIImage?

    // MARK: - View Config
    override func viewDidLoad() {
        if let image = image {
            capturedImage.image = image
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let defaultMessage = "Please wait while we read the sign"
        displayMessage.text = defaultMessage
        
        // get location/device info of user
        let currentLocation = LocationServices.currentLocation
        let heading = currentLocation.getHeading()
        let location = currentLocation.getLocation()
        let currentDevice = UIDevice.current
        let deviceDescription = APIManager.DeviceDescription(name: currentDevice.name, systemName: currentDevice.systemName, systemVersion: currentDevice.systemVersion, model: currentDevice.model)
        
        // calls API to upload image and user info
        if let image = self.image {
            APIManager.shared.upLoadImageText(heading: heading, location: location, deviceDescription: deviceDescription, image: image) { (successMessage, error) in
                if let error = error {
                    // TODO: Show alert to notify user error uploading image
                    print(error)
                } else {
                    // TODO: Show alert to notify user image uploaded successfully
                    print(successMessage!)
                }
            }
        } else {
            // TODO: Show alert to notify user error processing image
        }
    }
    
    // MARK: - User Action
    @IBAction func cameraButtonDidPressed(_ sender: UIButton) {
        // dismiss viewcontroller and go back to camera view
        self.dismiss(animated: true, completion: nil)
    }
    
    
    

}
