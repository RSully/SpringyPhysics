//
//  SPSpring.m
//  SpringyPhysics
//
//  Created by Ryan Sullivan on 4/15/12.
//  Copyright (c) 2012 Freelance Web Developer. All rights reserved.
//

#import "SPSpring.h"

@implementation SPSpring

+(id)springWithRate:(CGFloat)r node:(SPNode*)n1 node:(SPNode*)n2 {
    return [[self alloc] initWithRate:r node:n1 node:n2];
}

-(id)initWithRate:(CGFloat)r node:(SPNode*)n1 node:(SPNode*)n2 {
    if ((self = [super init])) {
        rate = r;
        node1 = n1;
        node2 = n2;
        initialLength = [self length];
    }
    return self;
}


-(CGFloat)length {
    return sqrt(pow(node2.position.x-node1.position.x, 2) + 
                pow(node2.position.y-node1.position.y, 2));
}

-(CGFloat)rate {
    return rate;
}

-(NSArray*)nodes {
    return [NSArray arrayWithObjects:node1, node2, nil];
}

-(SPVector*)forceForNode:(SPNode*)node {
    return [self springForceForNode:node];
}
-(SPVector*)springForceForNode:(SPNode*)node {
    CGFloat flip = (node == node1) ? -1.0 : 1.0;
    
    CGFloat deltaX = node2.position.x - node1.position.x;
    CGFloat deltaY = node2.position.y - node1.position.y;
    CGFloat deltaLength = [self length] - initialLength;
    return [SPVector vectorWithMagnitude:(flip * -1.0 * rate * deltaLength) 
                                   angle:atan2(deltaY, deltaX)];
}

@end
