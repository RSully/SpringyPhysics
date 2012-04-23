//
//  SPSpring.h
//  SpringyPhysics
//
//  Created by Ryan Sullivan on 4/15/12.
//  Copyright (c) 2012 Freelance Web Developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPNode.h"
#import "SPVector.h"

@interface SPSpring : NSObject {
    CGFloat rate;
    CGFloat initialLength;
    
    SPNode *node1;
    SPNode *node2;
}

+(id)springWithRate:(CGFloat)r node:(SPNode*)n1 node:(SPNode*)n2;
-(id)initWithRate:(CGFloat)r node:(SPNode*)n1 node:(SPNode*)n2;

-(CGFloat)length;
-(CGFloat)rate;
-(NSSet *)nodes;
-(SPVector*)forceForNode:(SPNode*)node;
-(SPVector*)springForceForNode:(SPNode*)node;

@end
