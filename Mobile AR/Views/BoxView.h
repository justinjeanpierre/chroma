//
//  BoxView.h
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-01-12.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import "CGPoint_Extensions.h"

@interface BoxView : UIView {
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    GLuint _colorRenderBuffer;

    GLuint _positionSlot;
    GLuint _colorSlot;
    GLuint _projectionUniform;
    GLuint _modelViewUniform;
    float _currentRotation;
    GLuint _depthRenderBuffer;

    // texture
    GLuint _floorTexture;
    GLuint _textureCoordinateSlot;
    GLuint _textureUniform;
}

-(void)changePerspective:(UIButton *)sender;
-(void)updateBoxWithPoint:(CGPoint3D)newPoint;
-(void)updateVertexAtPoint:(CGPoint3D)oldPoint toPoint:(CGPoint3D)newPoint;
-(void)updateTextureWithShaderIndex:(int)shaderIndex;

-(void)scaleXBy:(float)scaleFactor;
-(void)scaleYBy:(float)scaleFactor;
-(void)scaleZBy:(float)scaleFactor;

@end
