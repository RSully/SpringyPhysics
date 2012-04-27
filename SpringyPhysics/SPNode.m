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
    
    node->numSpringsAllocd = 8;
    node->numSprings = 0;
    node->springs = malloc(node->numSpringsAllocd * sizeof(SPSpringRef));
    
    node->velocity = SPVectorMake(0, 0);
    node->position = CGPointMake(0, 0);
    node->lockPosition = NO;
    
    node->retainCount = 1;
    return node;
}


SPNodeRef SPNodeRetain(SPNodeRef node) {
    node->retainCount++;
    return node;
}

void SPNodeRelease(SPNodeRef node) {
    node->retainCount--;
    
    if (node->retainCount <= 0) {
        for (int i = 0; i < node->numSprings; i++) {
            SPSpringRelease(node->springs[i]);
        }
        free(node->springs);
        free(node);
    }
}


SPVector SPNodeGetNetForce(SPNodeRef node) {
    SPVector force = SPVectorMake(0.0, 0.0);
    for (int i = 0; i < node->numSprings; i++) {
        SPSpringRef spring = node->springs[i];
        force = SPVectorSum(force, SPSpringGetForceForNode(spring, node));
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
    for (int i = 0; i < node->numSprings; i++) {
        SPSpringRef s = node->springs[i];
        if (spring == s) return;
    }
    
    if (node->numSprings == node->numSpringsAllocd) {
        node->numSpringsAllocd += 6;
        node->springs = realloc(node->springs, node->numSpringsAllocd * sizeof(SPSpringRef));
    }
    node->springs[node->numSprings++] = SPSpringRetain(spring);
}

void SPNodeRemoveSpring(SPNodeRef node, SPSpringRef spring) {
    for (int i = 0; i < node->numSprings; i++) {
        SPSpringRef s = node->springs[i];
        if (spring == s) {
            SPSpringRelease(s);
            node->numSprings--;
            
            for (int n = i; n < node->numSprings; n++) {
                node->springs[n] = node->springs[n+1];
            }
            return;
        }
    }
}

