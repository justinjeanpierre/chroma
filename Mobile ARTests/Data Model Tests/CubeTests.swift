//
//  CubeTests.swift
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-01-04.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

import XCTest

class CubeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateCube() {
        let point1 = Point(x: 1.0, y: 1.0, z: 1.0)
        let point2 = Point(x: 1.0, y: 0.0, z: 1.0)
        let point3 = Point(x: 0.0, y: 0.0, z: 1.0)
        let point4 = Point(x: 0.0, y: 1.0, z: 1.0)

        let point5 = Point(x: 1.0, y: 1.0, z: 0.0)
        let point6 = Point(x: 1.0, y: 0.0, z: 0.0)
        let point7 = Point(x: 0.0, y: 0.0, z: 0.0)
        let point8 = Point(x: 0.0, y: 1.0, z: 0.0)

        let cube = Cube(points: [point1, point2, point3, point4, point5, point6, point7, point8])

        XCTAssertTrue(cube.vertices.count == 8)
    }
    
}
