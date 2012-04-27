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


SPNodeRef SPNodeCreate(CGFloat damp, CGFloat mass, SPMeshView *mesh) {
    SPNodeRef node = (SPNodeRef)malloc(sizeof(struct _SPNode));
    node->damp = damp;
    node->mass = mass;
    node->mesh = mesh;
    node->springs = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    node->velocity = SPVectorMake(0, 0);
    node->position = CGPointMake(0, 0);
    node->lockPosition = NO;
    node->retainCount = 1;
    return node;
}

void SPNodeRelease(SPNodeRef node) {
    node->retainCount--;
    if (node->retainCount <= 0) {
        CFRelease(node->springs);
        free(node);
    }
}

SPVector SPNodeGetNetForce(SPNodeRef node) {
    SPVector force = SPVectorMake(0.0, 0.0);
    for (int i = 0; i < CFArrayGetCount(node->springs); i++) {
        SPSpringRef spring = CFArrayGetValueAtIndex(node->springs, i);
        force = SPVectorSum(force, SPSpringGetForceForNode(node));
        force = SPVectorSum(force, SPNodeGetDampingForce(node));
    }
    return force;
}

SPVector SPNodeGetDampingForce(SPNodeRef node) {
    return SPVectorMake(-1 * node->damp * node->velocity.x, -1 * node->damp * node->velocity.y);
}

SPVector SPNodeGetVelocity(SPNodeRef node) {
    return node->lockPosition ? SPVectorMake(0, 0) : node->velocity;
}

void SPNodeAddSpring(SPNodeRef node, SPSpringRef spring) {
    if (CFArrayContainsValue(node->springs, 0, spring)) return;
    CFArrayAppendValue(node->springs, spring);
}
void SPNodeRemoveSpring(SPNodeRef node, SPSpringRef spring) {
    while ((CFIndex ind = CFArrayGetFirstIndexOfValue(node->springs, 0, spring))) {
        CFArrayRemoveValueAtIndex(node->springs, ind);
    }
}

