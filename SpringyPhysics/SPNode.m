//
//  SPNode.m
//  SpringyPhysics
//
//  Created by Ryan Sullivan on 4/15/12.
//  Copyright (c) 2012 Freelance Web Developer. All rights reserved.
//

#import "SPNode.h"
#import "SPSpring.h"
#import "SPMeshView.h"

@implementation SPNode

@synthesize lockPosition, position, mass, velocity, mesh, springs;

+(SPNode*)nodeWithDamp:(CGFloat)dp point:(CGPoint)pt mass:(CGFloat)m {
    return [[self alloc] initWithDamp:dp point:pt mass:m];
}

-(id)initWithDamp:(CGFloat)dp point:(CGPoint)pt mass:(CGFloat)m {
    if ((self = [super init])) {
        springs = [NSMutableArray new];
        position = pt;
        mass = m;
        lockPosition = NO;
        damp = dp;
        velocity = [SPVector vectorWithX:0.0 y:0.0];
    }
    return self;
}

-(SPVector*)netForce {
    SPVector *force = [SPVector vectorWithX:0.0 y:0.0];
    //NSArray *springs = [mesh springsForNode:self];
    for (SPSpring *spring in springs) {
        force = [force vectorByAddingVector:[spring forceForNode:self]];
        force = [force vectorByAddingVector:[self dampingForce]];
    }
    return force;
}

-(SPVector*)dampingForce {
    CGFloat dampX = -1 * damp * velocity.x;
    CGFloat dampY = -1 * damp * velocity.y;
    return [SPVector vectorWithX:dampX y:dampY];
}


-(SPVector*)velocity {
    return lockPosition ? [SPVector vectorWithX:0.0 y:0.0] : velocity;
}



-(void)addSpring:(SPSpring *)spr {
    if ([spr isKindOfClass:[SPSpring class]] && ![springs containsObject:spr]) {
        [springs addObject:spr];
    }
}

-(void)removeSpring:(SPSpring *)spr {
    if ([springs containsObject:spr]) {
        [springs removeObject:spr];
    }
}

@end
