//
//  AuthServices.swift
//  curbmap-ios-mvp
//
//  Created by Eli Selkin on 3/27/18.
//  Copyright © 2018 Eli Selkin. All rights reserved.
//

import Foundation
import Alamofire
import KeychainAccess
import Mixpanel
let AUTH_HOST = "https://curbmap.com"

// MARK: - Login
/*
 Takes a function which expects back a result value passed from the server on attempted login
 Because calls are async we need to use a callback method.
 */
func login(callback: @escaping (_ result: Int)->Void) -> Void {
    let parameters = [
        "username": User.currentUser.getUsername(),
        "password": User.currentUser.getPassword()
    ]
    let headers = [
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    
    Alamofire.request(AUTH_HOST+"/login", method: .post, parameters: parameters, headers: headers).responseJSON { response in
        if let responseDict = response.result.value as? [String: Any] {
            if (responseDict.keys.contains("success")) {
                if (responseDict["success"] as! Int == 1) {
                    Mixpanel.mainInstance().identify(
                        distinctId: Mixpanel.mainInstance().distinctId)
                    Mixpanel.mainInstance().people.set(properties: ["$name": (User.currentUser.getUsername())])
                    processResponse(responseDict, callback: callback)
                } else {
                    // got error
                    callback(responseDict["success"] as! Int)
                }
            }
        }
    }
}


// MARK: - Signup
func signup(callback: @escaping (_ result: Int)->Void) -> Void {
    let parameters = [
        "username": User.currentUser.getUsername(),
        "password": User.currentUser.getPassword(),
        "email": User.currentUser.getEmail()
    ]
    
    let headers = [
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    
    Alamofire.request(AUTH_HOST+"/signup", method: .post, parameters: parameters, headers: headers).responseJSON { response in
        if var json = response.result.value as? [String: Int] {
            callback(json["success"]!)
        }
    }
}

// MARK: - Logout
/*
 It might seem counterintuitive, but the user using the device is never actually logged out on the app.
 This is important so that even on first use the user can upload photos and add lines and do whatever else.
 They won't get points for these things but they will be able to do them because they will have a token
 */
func logout(callback: @escaping (Int)->Void, retries: Int, retriesMax: Int) -> Void {
    if let token = User.currentUser.getToken() {
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request(AUTH_HOST+"/logout", method: .post, parameters: ["X":"y"], headers: headers).responseJSON { response in
            if var json = response.result.value as? [String: Bool] {
                if (json["success"] == true) {
                    User.currentUser.setLoggedIn(false)
                    User.currentUser.setBadge([false])
                    User.currentUser.setUsername("curbmaptest")
                    User.currentUser.setPassword("TestCurbm@p1")
                    User.currentUser.setToken(nil)
                    User.currentUser.setRemember(false)
                    User.currentUser.resetKeychain()
                    login(callback: callback) // log back in as test user
                }
            }
        }
    } else {
        // retry with backoff and max retries
        if (retries + 1 < retriesMax) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(retries), execute: {
                // recursive to a point, with cutoff
                logout(callback: callback, retries: retries + 1, retriesMax: retriesMax)
            })
        }
    }
}
func updateToken() -> Void {
    login(callback: updatedToken)
}

private func updatedToken(_ value: Int) -> Void {
    // Just receives the login value, not sure we need it at this moment unless to detect errors
}

// MARK: - Process response when a user is logged in
private func processResponse(_ responseDict: [String: Any], callback: (_ result: Int)->Void) {
    User.currentUser.setBadge(responseDict["badge"] as! [Bool])
    User.currentUser.setScore((Int64)((responseDict["score"] as! NSString).intValue))
    User.currentUser.setToken(responseDict["token"] as? String)
    User.currentUser.setExpDate(Calendar.current.date(byAdding: .day, value: 1, to: Date())!);
    User.currentUser.setEmail(responseDict["email"] as! String)
    User.currentUser.setLoggedIn(true)
    callback(1)
}
