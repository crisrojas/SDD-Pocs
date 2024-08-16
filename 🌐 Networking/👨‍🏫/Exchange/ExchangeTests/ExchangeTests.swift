//
//  ExchangeTests.swift
//  ExchangeTests
//
//  Created by JimLai on 2020/2/27.
//  Copyright © 2020 stargate. All rights reserved.
//

import XCTest
@testable import Exchange

class ExchangeTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJSON() {
        let j = JSON([P.asks: 3.14])
        assert(j[P.asks].stringValue == "3.14")
        assert(j[P.asks].doubleValue == 3.14)
        assert(j[P.asks].decimalValue == 3.14)
        assert(j[P.asks].intValue == 0)

    }
    

}
