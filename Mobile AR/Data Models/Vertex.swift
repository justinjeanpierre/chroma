//
//  Vertex.swift
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-01-04.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

struct Vertex: Equatable {
    var x: Float
    var y: Float
    var z: Float

    init(x: Float, y: Float, z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
}

func == (lhs: Vertex, rhs: Vertex) -> Bool {
    return (lhs.x == rhs.x &&
            lhs.y == rhs.y &&
            lhs.z == rhs.z)
}
