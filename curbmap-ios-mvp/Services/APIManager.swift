//
//  APIManager.swift
//  curbmap-ios-mvp
//
//  Created by Peter Wu on 4/10/18.
//  Copyright © 2018 Eli Selkin. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class APIManager {
    
    // Singleton for calling on all APIs
    static let shared = APIManager()
    
    func upLoadImage(image: UIImage, callBack: @escaping () -> Void) {
        let urlString = "https://curbmap.com:50003/imageUpload"
        let headers = ["Authorization": "Bearer \(User.currentUser.getToken()!)"]
        
        
        
    }
    
}
