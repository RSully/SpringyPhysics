//
//  SPDragNodeInfo.m
//  SpringyPhysics
//
//  Created by Ryan Sullivan on 4/15/12.
//  Copyright (c) 2012 Freelance Web Developer. All rights reserved.
//

#import "SPDragNodeInfo.h"

@implementation SPDragNodeInfo

@synthesize node, moved;

+(id)infoWithNode:(SPNode*)n {
    return [[self alloc] initWithNode:n];
}

-(id)initWithNode:(SPNode*)n {
    if ((self = [super init])) {
        node = n;
    }
    return self;
}

@end
