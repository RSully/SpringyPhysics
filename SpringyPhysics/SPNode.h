//
//  SPNode.h
//  SpringyPhysics
//
//  Created by Ryan Sullivan on 4/15/12.
//  Copyright (c) 2012 Freelance Web Developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPVector.h"
#import "SPMeshStructures.h"


SPNodeRef SPNodeCreate(CGFloat damp, CGFloat mass, SPMeshView *mesh);
SPNodeRef SPNodeRetain(SPNodeRef node);
void SPNodeRelease(SPNodeRef node);

SPVector SPNodeGetNetForce(SPNodeRef node);
SPVector SPNodeGetDampingForce(SPNodeRef node);

SPVector SPNodeGetVelocity(SPNodeRef node);

void SPNodeAddSpring(SPNodeRef node, SPSpringRef spring);
void SPNodeRemoveSpring(SPNodeRef node, SPSpringRef spring);

//SPNodeRef SPNodeCreate (CGFloat damp, CGPoint pt, CGFloat m) {
//    SPNodeRef node = (SPNodeRef)malloc(sizeof(struct _SPNode));
//    node->field = value;
//    ...
//    node->retainCount = 1;
//    return node;
//}
//and then release would just be like
//void SPNodeRelease(SPNodeRef node) {
//    node->retainCount --;
//    if (node->retainCount = 0) {
//        // release any retained resources, etc.
//        free(node);
//    }

