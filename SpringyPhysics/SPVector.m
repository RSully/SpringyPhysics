//
//  SPVector.m
//  SpringyPhysics
//
//  Created by Ryan Sullivan on 4/15/12.
//  Copyright (c) 2012 Freelance Web Developer. All rights reserved.
//

#import "SPVector.h"

@implementation SPVector

+(id)vectorWithMagnitude:(CGFloat)mag angle:(CGFloat)theta {
    return [[self alloc] initWithX:(cos(theta)*mag) Y:(sin(theta)*mag)];
}

+(id)vectorWithX:(CGFloat)x y:(CGFloat)y {
    return [[self alloc] initWithX:x Y:y];
}

+(id)vectorByAddingVector:(SPVector*)v1 toVector:(SPVector*)v2 {
    return [[self alloc] initWithX:([v1 x]+[v2 x]) Y:([v1 y]+[v2 y])];
}

-(id)initWithX:(CGFloat)w Y:(CGFloat)h {
    if ((self = [super init])) {
        x = w;
        y = h;
    }
    return self;
}

-(id)vectorByAddingVector:(SPVector*)v {
    return [SPVector vectorByAddingVector:self toVector:v];
}


-(CGFloat)angle {
    return atan2(y, x);
}

-(CGFloat)magnitude {
    return sqrt(pow(x, 2) + pow(y, 2));
}

-(CGFloat)x {
    return x;
}

-(CGFloat)y {
    return y;
}


-(NSString*)description {
    return [NSString stringWithFormat:@"<SPVector x:%f y:%f %p>", x, y, self];
}

@end
