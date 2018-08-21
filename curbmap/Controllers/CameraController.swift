//
//  CameraController.swift
//  curbmap
//
//  Created by Peter Wu on 4/3/18.
//  Copyright © 2018 curbmap. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class CameraController: NSObject {
    
    var captureSession: AVCaptureSession?
    var rearCamera: AVCaptureDevice?
    var rearCameraInput: AVCaptureDeviceInput?
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    
    func prepare(callBack: @escaping(Error?)-> Void) {
        
        func createCaptureSession() {
            // 1. create new capture session
            self.captureSession = AVCaptureSession()
        }
        func configureCaptureDevices() throws {
            // 2. discover and configure camera device for input
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.back)
            guard let camera = session.devices.first else {
                throw cameraControllerError.noCameraAvailable
            }
            self.rearCamera = camera
            try rearCamera?.lockForConfiguration()
            rearCamera?.focusMode = .continuousAutoFocus
            rearCamera?.unlockForConfiguration()
        }
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else { throw cameraControllerError.captureSessionIsMissing}
            // 3. Add camera input to capture session
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                if captureSession.canAddInput(self.rearCameraInput!) {
                    captureSession.addInput(self.rearCameraInput!)
                }
            } else {
                throw cameraControllerError.noCameraAvailable
            }
            
        }
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else { throw cameraControllerError.captureSessionIsMissing}
            // 4. Create, configure and add photo output object to capture session.  Then start capture session
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            if captureSession.canAddOutput(self.photoOutput!) {
                captureSession.addOutput(self.photoOutput!)
                captureSession.startRunning()
            }
        }
        
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
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else {
            throw cameraControllerError.captureSessionIsMissing}
        // Creates preview layer from capture session, configuration (portrait and resize), then add to view
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
    
    func cameraViewZoomedBy(zoomFactor: CGFloat) {
        guard let camera = rearCamera  else { return }
        let minVideoZoomFactor = camera.minAvailableVideoZoomFactor
        let maxVideoZoomFactor = camera.maxAvailableVideoZoomFactor
        //        if zoomFactor <= camera.videoZoomFactor {
        // lock then unlock
        try? camera.lockForConfiguration()
        if zoomFactor >= 1.0 {
            camera.ramp(toVideoZoomFactor: zoomFactor < maxVideoZoomFactor ? zoomFactor : maxVideoZoomFactor, withRate: 3.0)
        }
        if zoomFactor <= 1.0 {
            camera.ramp(toVideoZoomFactor: zoomFactor >= minVideoZoomFactor ? zoomFactor : minVideoZoomFactor, withRate: 3.0)
        }
        camera.unlockForConfiguration()
    }
    
    func focusIn(location: CGPoint, in previewView: UIView) {
        let thisFocusPoint = location
        
        print("touch to focus ", thisFocusPoint)
        
        let focus_x = thisFocusPoint.x / previewView.frame.size.width
        let focus_y = thisFocusPoint.y / previewView.frame.size.height
        
        if (rearCamera!.isFocusModeSupported(.autoFocus) && rearCamera!.isFocusPointOfInterestSupported) {
            do {
                try rearCamera?.lockForConfiguration()
                rearCamera?.focusMode = .autoFocus
                rearCamera?.focusPointOfInterest = CGPoint(x: focus_x, y: focus_y)
                
                if (rearCamera!.isExposureModeSupported(.autoExpose) && rearCamera!.isExposurePointOfInterestSupported) {
                    rearCamera?.exposureMode = .autoExpose;
                    rearCamera?.exposurePointOfInterest = CGPoint(x: focus_x, y: focus_y);
                }
                
                rearCamera?.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
    func captureImage(completion: @escaping (UIImage?, Error?)-> Void){
        guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, cameraControllerError.captureSessionIsMissing)
            return
        }
        let settings = AVCapturePhotoSettings()
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            self.photoCaptureCompletionBlock?(nil, error)
        } else if let imageData = photo.fileDataRepresentation() {
            let image = UIImage(data: imageData)
            self.photoCaptureCompletionBlock?(image, nil)
        } else {
            self.photoCaptureCompletionBlock?(nil, cameraControllerError.unknown)
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
