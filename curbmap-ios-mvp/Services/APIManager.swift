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
    
    func upLoadImageText(image: UIImage, callBack: @escaping (String?, Error?) -> Void) {
        let urlString = "https://curbmap.com:50003/imageUploadText"
        let headers = ["Authorization": "Bearer \(User.currentUser.getToken()!)"]
        Alamofire.upload(multipartFormData: { (formData) in
            let data = self.processImageData(image: image)
            formData.append(data, withName: "file", fileName: "file.jpg", mimeType: "image/jpeg")
        }, usingThreshold: UInt64.init(), to: urlString, method: .post, headers: headers, encodingCompletion: { (encodingResult) in
            switch encodingResult {
                
            case .success(let upload, _, _):
                upload.responseJSON(completionHandler: { (response) in
                    if let statusCode = response.response?.statusCode {
                        callBack("success status code \(statusCode)", nil)
                    } else {
                        callBack("unable to unwrap status code", nil)
                    }
                })
            case .failure(let encodingError):
                callBack(nil, encodingError)
            }
        })
    }



}

extension APIManager {
    
    private func processImageData(image: UIImage) -> Data {
        let IMAGE_RESIZE_WIDTH_PIXELS: CGFloat = 1080
        let JPEG_IMAGE_COMPRESSION: CGFloat = 0.7
            var imageToUpload = image
            
            // Resize image to if it's greater than 1080 pixels
            let imageResizeWidthPoints = IMAGE_RESIZE_WIDTH_PIXELS / UIScreen.main.scale
            if image.size.width > imageResizeWidthPoints{
                imageToUpload = imageToUpload.resize(scaledToWidth: imageResizeWidthPoints)
            }
            
            // Apply compresion
            // print("File size BEFORE \(Double(image.count)/1024.0/1024.0) MB / Image dimension: \(imageOriginal.size)");
            //print("File size AFTER : \(Double(imageResizeData.count)/1024.0/1024.0) MB / Image dimension: \(imageToUpload.size) \(path)");
            let imageResizeData = UIImageJPEGRepresentation(imageToUpload, JPEG_IMAGE_COMPRESSION)!
            
            return imageResizeData
    }
}

extension UIImage { // resizing image
    
    fileprivate func resize(scaledToWidth i_width: CGFloat) -> UIImage {
        let oldWidth = size.width;
        let scaleFactor = i_width / oldWidth;
        let newSize = CGSize(width: oldWidth * scaleFactor, height: size.height * scaleFactor)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

