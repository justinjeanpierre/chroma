//
//  PerspectiveStructure.m
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-03-02.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

#define RED     {1, 0, 0, 0.8}
#define GREEN   {0, 1, 0, 0.3}
#define BLUE    {0, 0, 1, 0.8}
#define WHITE   {1, 1, 1, 0.8}
#define BLACK   {0, 0, 0, 0.5}

#define TEXTURE_COORDINATE_MAX  2
#define TEXTURE_COORDINATE_MIN  0

#import "PerspectiveStructure.h"

@implementation PerspectiveBox

+(void)updateVerticesWithInitialPerspective:(BoxVertex[])src {
    //assume z = 5m, can change to something else
    const float initial_z = 5;

    //if use different screens, then adjust screen width and height according to iphone used
    const float angle_view = 60; //60 degree field of view
    const float screen_width = 720;
    const float screen_height = 1280;

    //get pixel coordinates + width + height of contour. Following values are just assumed
    const float x_topleft = 100;
    const float y_topleft = 250;
    const float width_pixels = 600;
    const float height_pixels = 400;

    //METHOD 1
    // next 4 floats just used as example
    float width_meters = width_pixels * (initial_z * cos(angle_view/2)) / screen_width;
    float height_meters = height_pixels * (initial_z * cos(angle_view/2)) / screen_width;
    float max_width_meters = screen_width * (initial_z * cos(angle_view/2)) / screen_width;
    float max_height_meters = screen_height * (initial_z * cos(angle_view/2)) / screen_width;
    // */

    //METHOD 2
    /*
     float max_width_meters = 2 * tan(angle_view / 2) * initial_z;
     float ratio = screen_width / max_width_meters;
     float max_height_meters = screen_height / ratio;
     float width_meters = width_pixels / ratio;
     float height_meters = height_pixels / ratio;
     // */

    float a = (height_meters / max_height_meters) / 2; //height
    float b = (width_meters / max_width_meters) / 2; //width
//        //front
//        {{b,  -a, 1},      RED,   {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MIN}},
//        {{b,  a,  1},      GREEN, {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MAX}},
//        {{-b, a,  1},      BLUE,  {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MAX}},
//        {{-b, -a, 1},      WHITE, {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MIN}},
    src[0].Position[0] = b;     src[0].Position[1] = -a;
    src[1].Position[0] = b;     src[1].Position[1] = a;
    src[2].Position[0] = -b;    src[2].Position[1] = a;
    src[3].Position[0] = -b;    src[3].Position[1] = -a;

//        //back
//        {{b,  a,  -1},     RED,   {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MIN}},
//        {{-b, -a, -1},     GREEN, {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MAX}},
//        {{b,  -a, -1},     BLUE,  {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MAX}},
//        {{-b, a,  -1},     WHITE, {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MIN}},
    src[4].Position[0] = b;     src[4].Position[1] = a;
    src[5].Position[0] = -b;    src[5].Position[1] = -a;
    src[6].Position[0] = b;     src[6].Position[1] = -a;
    src[7].Position[0] = -b;    src[7].Position[1] = a;

//        // Left
//    {{-1,   -1, 1},      RED,   {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MIN}},
//    {{-1,   1,  1},      GREEN, {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MAX}},
//    {{-1,   1,  -1},     BLUE,  {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MAX}},
//    {{-1,   -1, -1},     WHITE, {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MIN}},
    src[8].Position[0] = -b;    src[8].Position[1] = -a;
    src[9].Position[0] = -b;    src[9].Position[1] = a;
    src[10].Position[0] = -b;   src[10].Position[1] = a;
    src[11].Position[0] = -b;   src[11].Position[1] = -a;

//        //right
//        {{b,  -a, -1},     RED,   {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MIN}},
//        {{b,  a,  -1},     GREEN, {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MAX}},
//        {{b,  a,  1},      BLUE,  {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MAX}},
//        {{b,  -a, 1},      WHITE, {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MIN}},
    src[12].Position[0] = b;    src[12].Position[1] = -a;
    src[13].Position[0] = b;    src[13].Position[1] = a;
    src[14].Position[0] = b;    src[14].Position[1] = a;
    src[15].Position[0] = b;    src[15].Position[1] = -a;

//        // Top
//        {{b,    a,  1},      RED,   {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MIN}},
//        {{b,    a,  -1},     GREEN, {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MAX}},
//        {{-b,   a,  -1},     BLUE,  {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MAX}},
//        {{-b,   a,  1},      WHITE, {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MIN}},
    src[16].Position[0] = b;    src[16].Position[1] = a;
    src[17].Position[0] = b;    src[17].Position[1] = a;
    src[18].Position[0] = -b;   src[18].Position[1] = a;
    src[19].Position[0] = -b;   src[19].Position[1] = a;

//        // Bottom
//        {{b,    -a, -1},     RED,   {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MIN}},
//        {{b,    -a, 1},      GREEN, {TEXTURE_COORDINATE_MAX, TEXTURE_COORDINATE_MAX}},
//        {{-b,   -a, 1},      BLUE,  {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MAX}},
//        {{-b,   -a, -1},     WHITE, {TEXTURE_COORDINATE_MIN, TEXTURE_COORDINATE_MIN}},
    src[20].Position[0] = b;    src[20].Position[1] = -a;
    src[21].Position[0] = b;    src[21].Position[1] = -a;
    src[22].Position[0] = -b;   src[22].Position[1] = -a;
    src[23].Position[0] = -b;   src[23].Position[1] = -a;
}

@end
