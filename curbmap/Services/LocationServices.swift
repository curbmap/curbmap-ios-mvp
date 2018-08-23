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
        self.locationManager.rx
            .didChangeAuthorization
            .debug("didChangeAuthorization")
            .subscribe(onNext: { value in
                print("A VALUE:", value.status.rawValue) // 2 == OFF, 4 == While using
            })
            .disposed(by: bag)
    }
    public func setFollowing(follow: Bool) -> Void {
        self.following = follow
    }
    
    public func isFollowing() -> Bool {
        return self.following
    }
    
}
