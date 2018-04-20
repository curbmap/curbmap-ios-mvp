//
//  curbmap_ios_mvpTests.swift
//  curbmap-ios-mvpTests
//
//  Created by Eli Selkin on 3/23/18.
//  Copyright © 2018 Eli Selkin. All rights reserved.
//

import XCTest
@testable import curbmap_ios_mvp

class curbmap_ios_mvpTests: XCTestCase {
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
        login(callback: {(result) in
            XCTAssert(result == 1) // logging in as test user
            logine.fulfill()
        })
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testUserLogout() {
        let logoute = expectation(description: "logout")
        logout(callback: {(result) in
            XCTAssert(result == 1) // logging in as test user
            logoute.fulfill()
        }, retries: 0, retriesMax: 3)
        waitForExpectations(timeout: 15.0, handler: nil)
    }
    
    func testGotLocation() {
        XCTAssert(LocationServices.currentLocation.getLocation() != nil)
    }
}
