//
//  APIManager.swift
//  curbmap
//
//  Created by Peter Wu on 4/10/18.
//  Copyright © 2018 curbmap. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage
import OpenLocationCode
import MapKit

class APIManager {
    
    // Singleton for calling on all APIs
    static let shared = APIManager()
    let RSRC_HOSTNAME = "https://curbmap.com:50003/v1"
    // public let RSRC_HOSTNAME = "https://1c4f8969.ngrok.io" // TODO XXX DEBUG
    
    struct DeviceDescription {
        let name: String
        let systemName: String
        let systemVersion: String
        let model: String
        
        init(name: String, systemName: String, systemVersion: String, model: String) {
            self.name = name
            self.systemName = systemName
            self.systemVersion = systemVersion
            self.model = model
        }
        
        func description() -> String {
            return "name: \(name), systemName: \(systemName), systemVersion: \(systemVersion), model: \(model)"
        }
    }
    
    func uploadImage(heading: CLHeading?, location: CLLocation?, deviceDescription: DeviceDescription, image: UIImage, callBack: @escaping(String?, Error?) -> Void) {
        // Convert headings/location data to string
        let headingInString = heading?.trueHeading.description ?? "0.0"
        var olcString: String = ""
        do {
            olcString = try OpenLocationCode.encode(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        } catch {
            callBack("encoding error", error)
        }
        
        // device info
        let deviceDescriptionInString = deviceDescription.description()
        
        // image data/token
        let imageData = self.processImageData(image: image)
        let token = User.currentUser.getToken()!
        
        let urlString = self.RSRC_HOSTNAME + "/image/upload"
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Authorization": "Bearer \(token)"
        ]
        
        Alamofire.upload(multipartFormData: { MultipartFormData in
            // TODO: Eli to include messages in API response on the part of multipart data that failed
            // If Image doesn't pass, error code = 500
            // all required - image is not useful without the attached data
             // pass string of device type
            MultipartFormData.append(deviceDescriptionInString.data(using: String.Encoding.utf8)!, withName: "deviceType")
             // location in olc format-> string of longitude/latitude (not from picture)
            MultipartFormData.append(olcString.data(using: String.Encoding.utf8)!, withName: "olc")
             // heading, degrees from north, like compass - from CLLocation/device (not from picture)
            MultipartFormData.append(headingInString.data(using: String.Encoding.utf8)!, withName: "bearing")
            MultipartFormData.append(imageData, withName: "image", fileName: "file.jpg", mimeType: "image/jpeg")
            
        }, usingThreshold:UInt64.init(), to: urlString, method: .post, headers: headers, encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let uploadRequest, _, _):
                uploadRequest.responseJSON { response in
                    if let statusCode = response.response?.statusCode {
                        switch statusCode {
                        case 200...299:
                            print("success, status code: \(statusCode)")
                            callBack("success", nil)
                        case 400...499:
                            print("Request error, status code: \(statusCode)")
                            callBack("error", NSError(domain: "", code: statusCode, userInfo: nil))
                        default:
                            print("server error, status code: \(statusCode)")
                            callBack("error", NSError(domain: "", code: statusCode, userInfo: nil))
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

