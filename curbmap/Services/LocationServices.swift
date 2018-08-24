//
//  LocationServices.swift
//  curbmap
//
//  Copyright © 2018 curbmap. All rights reserved.
//

import Foundation
import CoreLocation
import RxCoreLocation
import RxSwift
import RxCocoa

class LocationServices: NSObject {
    public static var currentLocation = LocationServices(true)
    public var locationManager: CLLocationManager!
    public var lastLocation: CLLocation?
    public var lastHeading: CLHeading?
    private var following: Bool
    var bag = DisposeBag()
    
    private init(_ following: Bool) {
        self.following = following
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()
        
        // Monitor for changes to authorizations
        self.locationManager.rx
            .didChangeAuthorization
            .debug("didChangeAuthorization")
            .subscribe(onNext: { value in
                // If the user was not being followed for locations, turn on
                if ((value.status == .authorizedAlways || value.status == .authorizedWhenInUse) && !self.isFollowing()) {
                    self.setFollowing(follow: true)
                } else if (self.isFollowing()){
                    // If the user was being followed and is not authorized, turn off
                    self.setFollowing(follow: false)
                }
            })
            .disposed(by: bag)
    }
    
    // Enable disable location values from being used by system
    public func setFollowing(follow: Bool) -> Void {
        self.following = follow
        if (!follow) {
            self.locationManager.stopUpdatingLocation()
            self.locationManager.stopUpdatingHeading()
        } else {
            self.locationManager.startUpdatingLocation()
            self.locationManager.startUpdatingHeading()
        }
    }
    
    public func isFollowing() -> Bool {
        return self.following
    }
    
}
