//
//  User.swift
//  curbmap
//
//  Copyright © 2017 curbmap. All rights reserved.
//

import Foundation
import Alamofire
import KeychainAccess
import MapKit
import Mixpanel

class User {
    let keychain = Keychain(service: "com.curbmap.keys")
    var username: String = "curbmaptest"
    var password: String = "TestCurbm@p1"
    var res_host = "https://curbmap.com:50003"
    var auth_host = "https://curbmap.com"
    var email: String
    var loggedIn: Bool = false
    var remember: Bool = false
    var token: String?
    var exp_date: Date
    var score: Int64
    var badge: [Bool]!
    var currentLocation: CLLocation!
    init(username: String, password: String) {
        self.username = username
        self.password = password
        self.loggedIn = false
        self.badge = [Bool]()
        self.score = 0
        self.token = ""
        self.exp_date = Date()
        self.email = ""
    }
    func set_location(location: CLLocation) {
        self.currentLocation = location
    }
    func get_location() -> CLLocation? {
        return self.currentLocation
    }
    func set_badge(badge: [Bool]) {
        self.badge = badge
    }
    func get_badge() -> [Bool]{
        return self.badge
    }
    func set_score(score: Int64) {
        self.score = score
    }
    func get_score() -> Int64 {
        return self.score
    }
    func set_exp_date(date: Date) {
        self.exp_date = date
    }
    func get_exp_date() -> Date {
        return self.exp_date
    }
    func set_username(username: String) {
        self.username = username
    }
    func get_username() -> String {
        return self.username
    }
    func set_password(password: String) -> Void {
        self.password = password
    }
    func set_remember(remember: Bool) -> Void {
        self.remember = remember
    }
    func get_password() -> String {
        return self.password
    }
    func set_email(email:String) {
        self.email = email
    }
    func get_email() -> String {
        return self.email
    }
    func set_token(token: String?) -> Void {
        self.token = token;
    }
    func get_token() -> String? {
        if (Date() < self.exp_date) {
            return self.token
        } else {
            self.update_token()
            return nil
        }
    }
    func update_token() -> Void {
        self.login(callback: updated_token)
    }
    func updated_token(result: Int) {
    }
    
    // MARK: - Login
    func login(callback: @escaping (_ result: Int)->Void) -> Void {
        let parameters = [
            "username": self.username,
            "password": self.password
        ]
        if (self.username == "" || self.password == "") {
            callback(0)
            return
        }
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request(self.auth_host+"/login", method: .post, parameters: parameters, headers: headers).responseJSON { [weak self] response in
            guard self != nil else { return }
            if let response_dict = response.result.value as? [String: Any] {
                if (response_dict.keys.contains("success")) {
                    if (response_dict["success"] as! Int == 1) {
                        Mixpanel.mainInstance().identify(
                            distinctId: Mixpanel.mainInstance().distinctId)
                        Mixpanel.mainInstance().people.set(properties: ["$name": (self?.get_username())!])
                        self?.processResponse(response_dict: response_dict, callback: callback)
                    } else {
                        // got error
                        callback(response_dict["success"] as! Int)
                    }
                }
            }
        }
    }
    
    // MARK: - Signup
    func signup(callback: @escaping (_ result: Int)->Void) -> Void {
        let parameters = [
            "username": self.username,
            "password": self.password,
            "email": self.email
        ]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request(self.auth_host+"/signup", method: .post, parameters: parameters, headers: headers).responseJSON { [weak self] response in
            guard self != nil else { return }
            if var json = response.result.value as? [String: Int] {
                callback(json["success"]!)
            }
        }
    }
    
    // MARK: - Logout
    func logout(callback: @escaping (Int)->Void, retries: Int, retriesMax: Int) -> Void {
        if let token = self.get_token() {
            print("TOKEN: \(token)")
            let headers = [
                "Authorization": "Bearer \(token)"
            ]
            Alamofire.request(self.auth_host+"/logout", method: .post, parameters: ["X":"y"], headers: headers).responseJSON { [weak self] response in
                if var json = response.result.value as? [String: Bool] {
                    if (json["success"] == true) {
                        self?.loggedIn = false
                        self?.set_badge(badge: [false])
                        self?.set_username(username: "curbmaptest")
                        self?.set_password(password: "TestCurbm@p1")
                        self?.set_token(token: nil)
                        self?.set_remember(remember: false)
                        try? self?.keychain.removeAll()
                        self?.login(callback: callback) // log back in as test user
                    }
                }
            }
        } else {
            // retry with backoff and max retries
            if (retries + 1 < retriesMax) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(retries), execute: {
                    self.logout(callback: callback, retries: retries + 1, retriesMax: retriesMax)
                })
            }
        }
    }
    
    // MARK: - Process response when a user is logged in
    func processResponse(response_dict: [String: Any], callback: (_ result: Int)->Void) {
        self.set_badge(badge: response_dict["badge"] as! [Bool])
        self.set_score(score: (Int64)((response_dict["score"] as! NSString).intValue))
        self.set_token(token: response_dict["token"] as? String)
        self.set_exp_date(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!);
        self.set_email(email: response_dict["email"] as! String)
        self.loggedIn = true
        callback(1)
    }
    
    func isLoggedIn() -> Bool {
        return self.loggedIn;
    }
}

