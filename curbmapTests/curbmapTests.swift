//
//  curbmapTests.swift
//  curbmapTests
//
//  Created by Eli Selkin on 10/14/18.
//  Copyright © 2018 curbmap. All rights reserved.
//

import XCTest
@testable import curbmap
class curbmapTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUserLogin() {
        let logine = expectation(description: "login")
        AuthServices.authServicesBroker.login(callback: {(result) in
            XCTAssert(result == 1) // logging in as test user
            let x = User.currentUser.getToken()
            print("TOKEN:", x ?? "")
            logine.fulfill()
        })
        waitForExpectations(timeout: 20.0, handler: nil)
    }
    
    func testUserLogout() {
        let logoute = expectation(description: "logout")
        AuthServices.authServicesBroker.logout(callback: {(result) in
            XCTAssert(result == 1) // logging in as test user
            logoute.fulfill()
        }, retries: 0, retriesMax: 3)
        waitForExpectations(timeout: 15.0, handler: nil)
    }
    
    func testGotLocation() {
        XCTAssert(LocationServices.currentLocation.getLocation() != nil)
    }
}
