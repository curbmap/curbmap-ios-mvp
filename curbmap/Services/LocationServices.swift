//
//  LocationServices.swift
//  curbmap
//
//  Copyright © 2018 curbmap. All rights reserved.
//

import Foundation
import MapKit

class LocationServices: NSObject, CLLocationManagerDelegate {
    public static var currentLocation = LocationServices(true)
    private var heading: CLHeading!
    private var lastPosition: CLLocation!
    private var locationManager: CLLocationManager!
    private var following: Bool
    
    private init(_ following: Bool) {
        self.following = following
        self.locationManager = CLLocationManager()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()
        super.init()
        self.locationManager.delegate = self
    }
    
    public func getLocation() -> CLLocation? {
        return locationManager.location
    }
    
    public func getHeading() -> CLHeading? {
        return locationManager.heading
    }
    
    public func setFollowing(follow: Bool) -> Void {
        self.following = follow
    }
    
    public func isFollowing() -> Bool {
        return self.following
    }
    
    internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                    self.locationManager.startUpdatingLocation()
                    self.locationManager.startUpdatingHeading()
                }
            }
        }
    }
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (self.following && manager.location != nil) {
            User.currentUser.setLocation(manager.location!)
        }
    }
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if (manager.location != nil) {
            User.currentUser.setHeading(manager.heading!)
        }
    }
}
