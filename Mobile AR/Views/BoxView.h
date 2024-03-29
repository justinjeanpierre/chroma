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

-(void)updateTextureWithShaderIndex:(int)shaderIndex;
-(void)changePerspective:(UIButton *)sender;
-(void)scaleXBy:(float)scaleFactor;
-(void)scaleYBy:(float)scaleFactor;
-(void)scaleZBy:(float)scaleFactor;
-(void)scaleXAxis:(float)xAxisScale yAxis:(float)yAxisScale zAxis:(float)zAxisScale;
-(void)enableOrientationScaling;

@end
