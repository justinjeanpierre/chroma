//
//  BoxView.m
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-01-12.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

#define SHOW_FPS        false
//#define SHOW_TEXTURE    true

#import "BoxView.h"
#import "CC3GLMatrix.h"
#import <CoreMotion/CoreMotion.h>
#import "Structures.h"
#import "PerspectiveBox.h"

@interface BoxView () {
    CMMotionManager *motionManager;
    GLuint vertexBuffer;
    GLuint indexBuffer;

    int frameCount;
}

@property (nonatomic) bool isPerspectiveInsideCube;

@end

@implementation BoxView

#pragma mark - Class methods
+(Class)layerClass {
    return [CAEAGLLayer class];
}

-(void)displayFPSrate {
    NSLog(@"%s ~%d FPS", __func__, frameCount);

    frameCount = 0;
}

-(void)changePerspective:(UIButton *)sender {
    _isPerspectiveInsideCube = !_isPerspectiveInsideCube;
}

#pragma mark - Instance methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupDepthRenderBuffer];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self compileShaders];
        [self setupVBOs];
        [self setupDisplayLink];
        [self setupMotion];

        _floorTexture = [self setupTexture:@"tile_1"];

        frameCount = 0;
        if (SHOW_FPS) {
            [NSTimer scheduledTimerWithTimeInterval:1
                                             target:self
                                           selector:@selector(displayFPSrate)
                                           userInfo:nil
                                            repeats:YES];
        }

        _isPerspectiveInsideCube = NO;
    }

    return self;
}

#pragma mark - OpenGL - run

-(void)render:(CADisplayLink *)displayLink {
    // for fps counter
    frameCount++;

    // clear colours
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);

    CC3GLMatrix *projection = [CC3GLMatrix matrix];
    float h = 4.0f * self.frame.size.height / self.frame.size.width;

    if (_isPerspectiveInsideCube) { // inside box looking out
        [projection populateFromFrustumLeft:-3
                                   andRight:3
                                  andBottom:-6
                                     andTop:2
                                    andNear:4
                                     andFar:12];

        glUniformMatrix4fv(_projectionUniform, 1, 0, projection.glMatrix);

        CC3GLMatrix *modelView = [CC3GLMatrix matrix];
        [modelView populateFromTranslation:CC3VectorMake(0, 0, -4)];
        // use device attitude to rotate box:
        [modelView rotateBy:CC3VectorMake(-57 * motionManager.deviceMotion.attitude.pitch,
                                          -57 * motionManager.deviceMotion.attitude.roll,
                                          -57 * motionManager.deviceMotion.attitude.yaw)];
        [modelView scaleBy:CC3VectorMake(3, 3, 3)];

        glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
    } else { // outside box looking in
        [projection populateFromFrustumLeft:-2
                                   andRight:2
                                  andBottom:-h/2
                                     andTop:h/2
                                    andNear:4
                                     andFar:10];

        glUniformMatrix4fv(_projectionUniform, 1, 0, projection.glMatrix);

        CC3GLMatrix *modelView = [CC3GLMatrix matrix];
        [modelView populateFromTranslation:CC3VectorMake(0, 0, -7)];
        // use device attitude to rotate box:
        [modelView rotateBy:CC3VectorMake(57 * motionManager.deviceMotion.attitude.pitch,
                                          57 * motionManager.deviceMotion.attitude.roll,
                                          -57 * motionManager.deviceMotion.attitude.yaw)];
//        [modelView scaleByZ:self.frame.size.height/self.frame.size.width];

        glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
    }

    glViewport(0, 0, self.frame.size.width, self.frame.size.height);

    glVertexAttribPointer(_positionSlot,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(BoxVertex),
                          0);
    glVertexAttribPointer(_colorSlot,
                          4,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(BoxVertex),
                          (GLvoid *) (sizeof(float) * 3));

    // texture
    glVertexAttribPointer(_textureCoordinateSlot,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(BoxVertex),
                          (GLvoid *)(sizeof(float) * 7));

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _floorTexture);
    glUniform1i(_textureUniform, 0);

    glDrawElements(GL_TRIANGLES,
                   sizeof(BoxIndices)/sizeof(BoxIndices[0]),
                   GL_UNSIGNED_BYTE,
                   0);

    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - OpenGL - setup

-(void)setupLayer {
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = NO;
}

-(void)setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];

    if (!_context) {
        NSLog(@"Failed to initialize context.");
        exit(1);
    }

    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set context.");
        exit(1);
    }
}

-(void)setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

-(void)setupDepthRenderBuffer {
    if (_isPerspectiveInsideCube) {
        return;
    }

    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER,
                          GL_DEPTH_COMPONENT16,
                          self.frame.size.width,
                          self.frame.size.height);
}

-(void)setupFrameBuffer {
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                              GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER,
                              _colorRenderBuffer);

    glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                              GL_DEPTH_ATTACHMENT,
                              GL_RENDERBUFFER,
                              _depthRenderBuffer);
}

-(void)setupVBOs {
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    [PerspectiveBox updateVerticesWithInitialPerspective:BoxVertices];
    glBufferData(GL_ARRAY_BUFFER, sizeof(BoxVertices), BoxVertices, GL_DYNAMIC_DRAW);

    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(BoxIndices), BoxIndices, GL_STATIC_DRAW);
}

-(void)updateBoxWithPoint:(CGPoint3D)newPoint {
    NSLog(@"%s (%.0f, %.0f, %.0f)", __func__, newPoint.x, newPoint.y, newPoint.z);

    // (determine which vertex to update ... ?)
    int vertexSize = sizeof(BoxVertices)/sizeof(BoxVertex); // size of each array within BoxVertices[]
    int vertexIndex = vertexSize * 5;                       // which (0-indexed) point in BoxVertices[]?

    // change to new value
    BoxVertices[0].Position[0] *= newPoint.x;
    BoxVertices[0].Position[1] *= newPoint.y;
    BoxVertices[0].Position[2] *= newPoint.z;

    BoxVertices[1].Position[0] *= newPoint.x;
    BoxVertices[1].Position[1] *= newPoint.y;
    BoxVertices[1].Position[2] *= newPoint.z;

    BoxVertices[2].Position[0] *= newPoint.x;
    BoxVertices[2].Position[1] *= newPoint.y;
    BoxVertices[2].Position[2] *= newPoint.z;

    BoxVertices[3].Position[0] *= newPoint.x;
    BoxVertices[3].Position[1] *= newPoint.y;
    BoxVertices[3].Position[2] *= newPoint.z;

    // update buffer with new data
    glBufferSubData(GL_ARRAY_BUFFER,        // target
                    vertexIndex,            // offset
                    sizeof(BoxVertices),  // size of new data
                    &BoxVertices);        // pointer to new data
}

-(void)updateVertexAtPoint:(CGPoint3D)oldPoint toPoint:(CGPoint3D)newPoint {
    // call this when updating a vertex at a specified 3d-coordinate point
    // to newPoint's 3d coordinates.
    NSLog(@"%s", __func__);
}

-(void)setupDisplayLink {
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self
                                                             selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                      forMode:NSDefaultRunLoopMode];
}

#pragma mark - OpenGL methods - shader

-(GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:shaderName
                                                           ofType:@"glsl"];
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];

    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }

    GLuint shaderHandle = glCreateShader(shaderType);

    const char *shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);

    glCompileShader(shaderHandle);

    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }

    return shaderHandle;
}

-(void)compileShaders {
    GLuint vertexShader = [self compileShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];

    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);

    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }

    glUseProgram(programHandle);

    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);

    _projectionUniform = glGetUniformLocation(programHandle, "Projection");
    _modelViewUniform = glGetUniformLocation(programHandle, "Modelview");

    // texture
    _textureCoordinateSlot = glGetAttribLocation(programHandle, "TextureCoordinateIn");
    glEnableVertexAttribArray(_textureCoordinateSlot);
    _textureUniform = glGetUniformLocation(programHandle, "Texture");
}

-(void)updateTextureWithShaderIndex:(int)shaderIndex {
    NSLog(@"%s", __func__);

    if (shaderIndex != 0) {
        // assumes shaderIndex will not be larger
        // than # of textures in asset catalog
        NSString *tileName = [NSString stringWithFormat:@"tile_%d", shaderIndex];
        _floorTexture = [self setupTexture:tileName];
    }

    // get handle for the program in use
    GLint programHandle;
    glGetIntegerv(GL_CURRENT_PROGRAM, &programHandle);

    // get attached shaders
    GLuint shaders[2];
    GLsizei maxShaderCount = 2;
    GLsizei shaderCount;
    glGetAttachedShaders(programHandle, maxShaderCount, &shaderCount, shaders);

    // detach shaders
    for (int i = (int)shaderCount; i > 0; i--) {
        glDetachShader(programHandle, shaders[i-1]);
        glDeleteShader(i);
    }

    GLuint vertexShader;
    GLuint fragmentShader;

    // compile shaders depending on value of shaderIndex
    if (shaderIndex == 0) {
        vertexShader = [self compileShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
        fragmentShader = [self compileShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];
    } else {
        vertexShader = [self compileShader:@"SimpleVertexTexture" withType:GL_VERTEX_SHADER];
        fragmentShader = [self compileShader:@"SimpleFragmentTexture" withType:GL_FRAGMENT_SHADER];
    }

    // attach the new shaders
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);

    // pass in the colour, position, projection, and texture values
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);

    _projectionUniform = glGetUniformLocation(programHandle, "Projection");
    _modelViewUniform = glGetUniformLocation(programHandle, "Modelview");

    _textureCoordinateSlot = glGetAttribLocation(programHandle, "TextureCoordinateIn");
    glEnableVertexAttribArray(_textureCoordinateSlot);
    _textureUniform = glGetUniformLocation(programHandle, "Texture");
}

#pragma mark - CoreMotion - setup
-(void)setupMotion {
    motionManager = [[CMMotionManager alloc] init];
    [motionManager startDeviceMotionUpdates];
}

#pragma mark - Texture - setup
-(GLuint)setupTexture:(NSString *)fileName {
    CGImageRef image = [UIImage imageNamed:fileName].CGImage;

    if (!image) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }

    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);

    GLubyte *imageData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
    CGContextRef imageContext = CGBitmapContextCreate(imageData,    // void * __nullable data
                                                      width,        // size_t width
                                                      height,       // size_t height
                                                      32,           // size_t bitsPerComponent
                                                      width * 4,    // size_t bytesPerRow
                                                      CGImageGetColorSpace(image),  // CGColorSpaceRef cg_nullable space
                                                      kCGImageAlphaNone|kCGBitmapFloatComponents);  // uint32_t bitmapInfo

    CGContextDrawImage(imageContext, CGRectMake(0, 0, width, height), image);
    CGContextRelease(imageContext);

    GLuint textureName;
    glGenTextures(1, &textureName);
    glBindTexture(GL_TEXTURE_2D, textureName);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 GL_RGBA,
                 (GLsizei)width,
                 (GLsizei)height,
                 0,
                 GL_RGBA,
                 GL_UNSIGNED_BYTE,
                 imageData);

    free(imageData);
    return textureName;
}

@end
