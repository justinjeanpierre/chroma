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
#define BLACK   {0, 0, 0, 0.5}

#define TEXTURE_COORDINATE_MAX  2
#define TEXTURE_COORDINATE_MIN  0

#import "BoxVertex.h"

BoxVertex BoxVertices[] = {
    // Front
    {{1,    -1, 1},      RED,   {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MIN}},
    {{1,    1,  1},      GREEN, {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MAX}},
    {{-1,   1,  1},      BLUE,  {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MAX}},
    {{-1,   -1, 1},      WHITE, {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MIN}},

    // Back
    {{1,    1,  -1},     RED,   {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MIN}},
    {{-1,   -1, -1},     GREEN, {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MAX}},
    {{1,    -1, -1},     BLUE,  {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MAX}},
    {{-1,   1,  -1},     WHITE, {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MIN}},

    // Left
    {{-1,   -1, 1},      RED,   {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MIN}},
    {{-1,   1,  1},      GREEN, {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MAX}},
    {{-1,   1,  -1},     BLUE,  {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MAX}},
    {{-1,   -1, -1},     WHITE, {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MIN}},

    // Right
    {{1,    -1, -1},     RED,   {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MIN}},
    {{1,    1,  -1},     GREEN, {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MAX}},
    {{1,    1,  1},      BLUE,  {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MAX}},
    {{1,    -1, 1},      WHITE, {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MIN}},

    // Top
    {{1,    1,  1},      RED,   {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MIN}},
    {{1,    1,  -1},     GREEN, {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MAX}},
    {{-1,   1,  -1},     BLUE,  {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MAX}},
    {{-1,   1,  1},      WHITE, {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MIN}},

    // Bottom
    {{1,    -1, -1},     RED,   {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MIN}},
    {{1,    -1, 1},      GREEN, {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MAX}},
    {{-1,   -1, 1},      BLUE,  {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MAX}},
    {{-1,   -1, -1},     WHITE, {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MIN}},
};

const GLubyte BoxIndices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,

    // Back
    4, 5, 6,
    4, 5, 7,

    // Left
    8, 9, 10,
    10, 11, 8,

    // Right
    12, 13, 14,
    14, 15, 12,

    // Top
    16, 17, 18,
    18, 19, 16,

    // Bottom
    20, 21, 22,
    22, 23, 20
};

#endif /* Structures_h */
