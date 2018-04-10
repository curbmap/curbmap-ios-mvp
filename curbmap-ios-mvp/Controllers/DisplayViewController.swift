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
        
        // calls API
        
    }
    
    // MARK: - User Action
    @IBAction func cameraButtonDidPressed(_ sender: UIButton) {
        // dismiss viewcontroller and go back to camera view
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - API Calls
    
    

}
