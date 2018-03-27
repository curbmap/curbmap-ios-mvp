//
//  User.swift
//  curbmap
//
//  Copyright © 2017 curbmap. All rights reserved.
//

import Foundation
import MapKit

let currentUser = User(username: "curbmap", password: "TestCurbm@p1");

class User {
    private var username: String
    private var password: String
    private var email: String
    private var loggedIn: Bool
    var remember: Bool
    var token: String?
    var expDate: Date
    var score: Int64
    var badge: [Bool]
    var currentLocation: CLLocation!
    init(username: String, password: String) {
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
        if (Date() < self.expDate) {
            return self.token
        } else {
            updateToken()
            return nil
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
