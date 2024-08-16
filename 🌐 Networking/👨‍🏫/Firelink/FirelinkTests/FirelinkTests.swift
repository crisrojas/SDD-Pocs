//
//  DevTemplateTests.swift
//  DevTemplateTests
//
//  Created by Raistlin on 2017/12/13.
//  Copyright © 2017年 jimlai. All rights reserved.
//

import XCTest
import Nimble
import SwiftyJSON
@testable import Firelink

class DevTemplateTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAPI() {
        var hasNewData = false
        api.test.load().onNewData { e in
            dp(e.json)
            hasNewData = true
        }
        expect(hasNewData).toEventually(beTrue(), timeout: 5)
    }

    func testPost() {
        let pj = JSON([P.test: "test"] as PJ)
        dp(pj)
        var completed = false
        api.test.post(pj).onCompletion { e in
            dp(e)
            completed = true
        }
        expect(completed).toEventually(beTrue(), timeout: 5)
    }

    func testNestedJSON() {
        let pj = [P.test: [P.none: 456]] as PJ
        dp(pj)
    }
}

