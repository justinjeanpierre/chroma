//
//  Cube.swift
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-01-04.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

struct Cube: Equatable {
    var vertex1: Vertex
    var vertex2: Vertex
    var vertex3: Vertex
    var vertex4: Vertex
    var vertex5: Vertex
    var vertex6: Vertex
    var vertex7: Vertex
    var vertex8: Vertex

    var vertices: [Vertex]

    init() {
        vertices = []

        let zeroVertex = Vertex(x: 0, y: 0, z: 0)
        vertex1 = zeroVertex
        vertex2 = zeroVertex
        vertex3 = zeroVertex
        vertex4 = zeroVertex
        vertex5 = zeroVertex
        vertex6 = zeroVertex
        vertex7 = zeroVertex
        vertex8 = zeroVertex
    }

    init(vertices: [Vertex]) {
        self.vertices = vertices

        vertex1 = vertices[0]
        vertex2 = vertices[1]
        vertex3 = vertices[2]
        vertex4 = vertices[3]
        vertex5 = vertices[4]
        vertex6 = vertices[5]
        vertex7 = vertices[6]
        vertex8 = vertices[7]
    }

    func defaultCube() -> Cube {
        let defaultVertex1 = Vertex(x: 1.0, y: 1.0, z: 1.0)
        let defaultVertex2 = Vertex(x: 1.0, y: 0.0, z: 1.0)
        let defaultVertex3 = Vertex(x: 0.0, y: 0.0, z: 1.0)
        let defaultVertex4 = Vertex(x: 0.0, y: 1.0, z: 1.0)
        let defaultVertex5 = Vertex(x: 1.0, y: 1.0, z: 0.0)
        let defaultVertex6 = Vertex(x: 1.0, y: 0.0, z: 0.0)
        let defaultVertex7 = Vertex(x: 0.0, y: 0.0, z: 0.0)
        let defaultVertex8 = Vertex(x: 0.0, y: 1.0, z: 0.0)

        let cube = Cube(vertices: [defaultVertex1,
                                defaultVertex2,
                                defaultVertex3,
                                defaultVertex4,
                                defaultVertex5,
                                defaultVertex6,
                                defaultVertex7,
                                defaultVertex8])

        return cube
    }
}

func == (lhs: Cube, rhs: Cube) -> Bool {
    return (lhs.vertex1 == rhs.vertex1 &&
            lhs.vertex2 == rhs.vertex2 &&
            lhs.vertex3 == rhs.vertex3 &&
            lhs.vertex4 == rhs.vertex4 &&
            lhs.vertex5 == rhs.vertex5 &&
            lhs.vertex6 == rhs.vertex6 &&
            lhs.vertex7 == rhs.vertex7 &&
            lhs.vertex8 == rhs.vertex8)
}
