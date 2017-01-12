//
//  PointTests.swift
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-01-04.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

import XCTest

class PointTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreatePoint() {
        let xTestValue: Float = 1.2
        let yTestValue: Float = 3.4
        let zTestValue: Float = 5.6

        let point = Point(x: xTestValue, y: yTestValue, z: zTestValue)

        XCTAssertEqual(point.x, xTestValue)
        XCTAssertEqual(point.y, yTestValue)
        XCTAssertEqual(point.z, zTestValue)
    }
}