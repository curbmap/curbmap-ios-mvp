//
//  APIManager.swift
//  curbmap-ios-mvp
//
//  Created by Peter Wu on 4/10/18.
//  Copyright © 2018 curbmap. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage
import OpenLocationCode

class APIManager {
    
    // Singleton for calling on all APIs
    static let shared = APIManager()
    
    func upLoadImageText(image: UIImage, callBack: @escaping (String?, Error?) -> Void) {
//        let imageOlc =
        let imageData = self.processImageData(image: image)
        let token = User.currentUser.getToken()!
        let urlString = "https://curbmap.com:50003/imageUploadText"
//        let headers = ["Authorization": "Bearer \(User.currentUser.getToken()!)"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Authorization": "Bearer \(token)"
        ]
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .full
        dateFormatter.dateStyle = .full
        dateFormatter.timeZone = Calendar.current.timeZone
        Alamofire.upload(multipartFormData: { MultipartFormData in
            // TODO: Eli to include messages in API response on the part of multipart data that failed
            // If Image doesn't pass, error code = 500
            // all required - image is not useful without the attached data
            MultipartFormData.append("ios".data(using: String.Encoding.utf8)!, withName: "device") // pass string of device type
            MultipartFormData.append(token.data(using: .utf8)!, withName: "token") // pass string of token
            MultipartFormData.append("\(dateFormatter.string(from: Date()))".data(using: String.Encoding.utf8)!, withName: "date") // date of local user at the time the API is called
            MultipartFormData.append((TimeZone.current.abbreviation() ?? "").data(using: String.Encoding.utf8)!, withName: "timezone") // time zone of local user
            MultipartFormData.append("imageOLC+".data(using: String.Encoding.utf8)!, withName: "olc") // location -> string of longitude/latitude (not from picture)
            MultipartFormData.append("0.0".data(using: String.Encoding.utf8)!, withName: "bearing") // heading, degrees from north, like compass - from CLLocation/device (not from picture)
            MultipartFormData.append(imageData, withName: "image", fileName: "file.jpg", mimeType: "image/jpeg")
        }, usingThreshold:UInt64.init(), to: urlString, method: .post, headers: headers as! HTTPHeaders, encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let result = response.result.value {
                        if let success = result as? NSDictionary {
                            if let statusCode = response.response?.statusCode {
                                print("success, status code: \(statusCode)")
                                callBack("success", nil)
                            }
                        }
                    }
                }
            case .failure(let encodingError):
                print("failed to send \(encodingError.localizedDescription)")
                callBack("error", encodingError)
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

