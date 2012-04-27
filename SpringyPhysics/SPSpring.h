//
//  SPSpring.h
//  SpringyPhysics
//
//  Created by Ryan Sullivan on 4/15/12.
//  Copyright (c) 2012 Freelance Web Developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPVector.h"
#import "SPMeshStructures.h"


SPSpringRef SPSpringCreate(float rate, SPNodeRef node1, SPNodeRef node2);
SPSpringRef SPSpringRetain(SPSpringRef spring);
void SPSpringRelease(SPSpringRef spring);

SPVector SPSpringGetForceForNode(SPSpringRef spring, SPNodeRef node);
float SPSpringGetLength(SPSpringRef spring);

