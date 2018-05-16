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
        // Old text made less sense than default text that's there in storyboard.
        // calls API
        if let image = self.image {
            APIManager.shared.upLoadImageText(image: image) { (successMessage, error) in
                if let error = error {
                    print(error)
                } else {
                    print(successMessage!)
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
