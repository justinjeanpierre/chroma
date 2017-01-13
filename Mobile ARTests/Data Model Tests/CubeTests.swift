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
    
    func testCreateCubeWithVertices() {
        let vertex1 = Vertex(x: 1.0, y: 1.0, z: 1.0)
        let vertex2 = Vertex(x: 1.0, y: 0.0, z: 1.0)
        let vertex3 = Vertex(x: 0.0, y: 0.0, z: 1.0)
        let vertex4 = Vertex(x: 0.0, y: 1.0, z: 1.0)

        let vertex5 = Vertex(x: 1.0, y: 1.0, z: 0.0)
        let vertex6 = Vertex(x: 1.0, y: 0.0, z: 0.0)
        let vertex7 = Vertex(x: 0.0, y: 0.0, z: 0.0)
        let vertex8 = Vertex(x: 0.0, y: 1.0, z: 0.0)

        let cube = Cube(vertices: [vertex1, vertex2, vertex3, vertex4, vertex5, vertex6, vertex7, vertex8])

        XCTAssertTrue(cube.vertices.count == 8)
    }

    func testDefaultCube() {
        let test_vertex_1 = Vertex(x: 1.0, y: 1.0, z: 1.0)
        let test_vertex_2 = Vertex(x: 1.0, y: 0.0, z: 1.0)
        let test_vertex_3 = Vertex(x: 0.0, y: 0.0, z: 1.0)
        let test_vertex_4 = Vertex(x: 0.0, y: 1.0, z: 1.0)
        let test_vertex_5 = Vertex(x: 1.0, y: 1.0, z: 0.0)
        let test_vertex_6 = Vertex(x: 1.0, y: 0.0, z: 0.0)
        let test_vertex_7 = Vertex(x: 0.0, y: 0.0, z: 0.0)
        let test_vertex_8 = Vertex(x: 0.0, y: 1.0, z: 0.0)

        let cube = Cube().defaultCube()

        XCTAssertEqual(cube.vertex1, test_vertex_1)
        XCTAssertEqual(cube.vertex2, test_vertex_2)
        XCTAssertEqual(cube.vertex3, test_vertex_3)
        XCTAssertEqual(cube.vertex4, test_vertex_4)
        XCTAssertEqual(cube.vertex5, test_vertex_5)
        XCTAssertEqual(cube.vertex6, test_vertex_6)
        XCTAssertEqual(cube.vertex7, test_vertex_7)
        XCTAssertEqual(cube.vertex8, test_vertex_8)
    }
}
