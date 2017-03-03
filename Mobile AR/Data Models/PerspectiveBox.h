//
//  PerspectiveStructure.h
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-03-02.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoxVertex.h"

@interface PerspectiveBox : NSObject

+(void)updateVerticesWithInitialPerspective:(BoxVertex[])sourceVertices;

@end
