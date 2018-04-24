//
//  User.swift
//  curbmap
//
//  Copyright © 2017 curbmap. All rights reserved.
//
import Foundation
import KeychainAccess
import MapKit

class User : NSObject {
    public static let currentUser = User(username: "curbmaptest", password: "TestCurbm@p1");
    private var keychain = Keychain(accessGroup: "curbmap")
    private var username: String
    private var password: String
    private var email: String
    private var loggedIn: Bool
    private var remember: Bool
    private var token: String?
    private var expDate: Date
    private var score: Int64
    private var badge: [Bool]
    private var currentLocation: CLLocation?
    private var currentHeading: CLHeading?
    private init(username: String, password: String) {
        self.username = username
        self.password = password
        self.remember = false
        self.loggedIn = false
        self.badge = [Bool]()
        self.score = 0
        self.token = ""
        self.expDate = Date()
        self.email = ""
    }
    func setLocation(_ location: CLLocation) {
        self.currentLocation = location
    }
    func getLocation() -> CLLocation? {
        return self.currentLocation
    }
    func setHeading(_ heading: CLHeading) {
        self.currentHeading = heading
    }
    func getHeading() -> CLHeading? {
        return self.currentHeading
    }
    func setBadge(_ badge: [Bool]) {
        self.badge = badge
    }
    func getBadge() -> [Bool]{
        return self.badge
    }
    func setScore(_ score: Int64) {
        self.score = score
    }
    func getScore() -> Int64 {
        return self.score
    }
    func setExpDate(_ date: Date) {
        self.expDate = date
    }
    func getExpDate() -> Date {
        return self.expDate
    }
    func setUsername(_ username: String) {
        self.username = username
    }
    func getUsername() -> String {
        return self.username
    }
    func setPassword(_ password: String) -> Void {
        self.password = password
    }
    func getPassword() -> String {
        return self.password
    }
    func setRemember(_ remember: Bool) -> Void {
        self.remember = remember
    }
    func isRemember() -> Bool {
        return self.remember;
    }
    func setEmail(_ email:String) {
        self.email = email
    }
    func getEmail() -> String {
        return self.email
    }
    func setToken(_ token: String?) -> Void {
        self.token = token;
    }
    func getToken() -> String? {
//        if (Date() < self.expDate) {
            return self.token
//        } else {
//            AuthServices.authServicesBroker.updateToken()
//            return nil
//        }
    }
    func resetKeychain() -> Void {
        try? self.keychain.removeAll()
    }
    /*
     If there was a user stored the User instance now has that value if returned true
     otherwise the user is still curbmaptest
     */
    func getUserFromKeychain() -> Bool {
        if let username = try? self.keychain.get("username") {
            if let password = try? self.keychain.get("password") {
                // not sure why it still needs unwrapping, but it does
                self.username = username!
                self.password = password!
                return true
            }
        }
        return false
    }
    /*
     If maybe after successful login and user wishes information to be stored,
     we can store those values in the keychain
     */
    func storeUserToKeychain() -> Bool {
        do {
            try self.keychain.set(self.username, key: "username")
            try self.keychain.set(self.password, key: "password")
            return true
        } catch {
            return false
        }
    }
    func setLoggedIn(_ status: Bool) -> Void {
        self.loggedIn = status
    }
    // the odd one out
    func isLoggedIn() -> Bool {
        return self.loggedIn
    }
}
