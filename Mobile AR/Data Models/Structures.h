//
//  Structures.h
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-01-12.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

#ifndef Structures_h
#define Structures_h

#define RED     {1, 0, 0, 0.8}
#define GREEN   {0, 1, 0, 0.3}
#define BLUE    {0, 0, 1, 0.8}
#define WHITE   {1, 1, 1, 0.8}

typedef struct {
    float Position[3];
    float Color[4];
    float TextureCoordinate[2];
} BoxVertex;

BoxVertex BoxVertices[] = {
    {{1,  -1,  0},   RED,   {1, 0}},
    {{1,   1,  0},   RED,   {1, 1}},
    {{-1,  1,  0},   GREEN, {0, 1}},
    {{-1, -1,  0},   GREEN, {0, 0}},
    {{1,  -1, -1},   RED,   {1, 0}},
    {{1,   1, -1},   RED,   {1, 1}},
    {{-1,  1, -1},   GREEN, {0, 1}},
    {{-1, -1, -1},   GREEN, {0, 0}}
};

const GLubyte BoxIndices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 6, 5,
    4, 7, 6,
    // Left
    2, 7, 3,
    7, 6, 2,
    // Right
    0, 4, 1,
    4, 1, 5,
    // Top
    6, 2, 1,
    1, 6, 5,
    // Bottom
    0, 3, 7,
    0, 7, 4
};

#endif /* Structures_h */
