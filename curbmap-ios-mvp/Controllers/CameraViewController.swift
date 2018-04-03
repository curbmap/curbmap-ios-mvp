//
//  CameraViewController.swift
//  curbmap-ios-mvp
//
//  Created by Peter Wu on 4/3/18.
//  Copyright © 2018 Eli Selkin. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class CameraViewController: UIViewController {

    var captureSession: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    
    func prepare(callBack: @escaping(Error?)-> Void) {
        
        func createCaptureSession() {
            // 1. create new capture session
            self.captureSession = AVCaptureSession()
        }
        func configureCaptureDevices() throws {
            
        }
        func configureDeviceInputs() throws {}
        func configurePhotoOutput() throws {}
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            } catch {
                DispatchQueue.main.async {
                    callBack(error)
                }
                return
            }
            DispatchQueue.main.async {
                callBack(nil)
            }
        }
    }

    
    

    
}

enum cameraControllerError: Swift.Error {
    case captureSessionAlreadyRunning
    case captureSessionIsMissing
    case inputsAreInvalid
    case invalidOperation
    case noCameraAvailable
    case unknown
}
