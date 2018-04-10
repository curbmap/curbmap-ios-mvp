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
    var image: UIImage?
    
    override func viewDidLoad() {
        if let image = image {
            capturedImage.image = image
        }
    }
    
    

}
