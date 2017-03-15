//
//  Protocols.h
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-03-15.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

#ifndef Protocols_h
#define Protocols_h

@protocol DisplayTargetProtocol <NSObject>
-(void)updatePreviewWithImage:(UIImage *)newImage;
-(void)updateTrackerBoundingBoxWithRect:(CGRect)newBoundingBox;
-(void)updateContourBoundingBoxWithRect:(CGRect)newBoundingBox;
@end

#endif /* Protocols_h */
