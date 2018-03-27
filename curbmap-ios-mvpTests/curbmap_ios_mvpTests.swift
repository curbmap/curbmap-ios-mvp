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
        func respondToLogin(result: Int){
            XCTAssert(result == 1) // logging in as test user
        }
        login(callback: respondToLogin)
        // This is an example of a performance test case.
    }
    
    func testUserLogout() {
        func respondToLogout(result: Int){
            // result will actually be a login of test user
            XCTAssert(result == 1);
        }
        logout(callback: respondToLogout, retries: 0, retriesMax: 3)
    }
    
}
