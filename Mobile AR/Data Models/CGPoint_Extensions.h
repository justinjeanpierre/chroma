//
//  CGPoint_CGPoint_Extensions.h
//  Mobile AR
//
//  Created by Justin Jean-Pierre on 2017-02-19.
//  Copyright © 2017 Jean-Pierre Digital. All rights reserved.
//

struct CGPoint3D {
CGFloat x;
CGFloat y;
CGFloat z;
};
typedef struct CGPoint3D CGPoint3D;

CGPoint3D CGPoint3DMake(CGFloat x, CGFloat y, CGFloat z) {
CGPoint3D p;

p.x = x;
p.y = y;
p.z = z;

return p;
}