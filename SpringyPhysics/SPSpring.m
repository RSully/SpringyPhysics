//
//  SPSpring.m
//  SpringyPhysics
//
//  Created by Ryan Sullivan on 4/15/12.
//  Copyright (c) 2012 Freelance Web Developer. All rights reserved.
//

#import "SPSpring.h"
#import "SPNode.h"

SPVector SPSpringGetSpringForceForNode(SPSpringRef spring, SPNodeRef node);


SPSpringRef SPSpringCreate(float rate, SPNodeRef node1, SPNodeRef node2) {
    SPSpringRef spring = (SPSpringRef)malloc(sizeof(struct _SPSpring));
    spring->rate = rate;
    
    spring->node1 = SPNodeRetain(node1);
    spring->node2 = SPNodeRetain(node2);
    SPNodeAddSpring(node1, spring);
    SPNodeAddSpring(node2, spring);
    spring->initalLength = SPSpringGetLength(spring);
    
    spring->retainCount = 1;
    return spring;
}

SPSpringRef SPSpringRetain(SPSpringRef spring) {
    spring->retainCount++;
    return spring;
}

void SPSpringRelease(SPSpringRef spring) {
    spring->retainCount--;
    if (spring->retainCount <= 0) {
        SPNodeRelease(spring->node1);
        SPNodeRelease(spring->node2);
        free(spring);
    }
}


SPVector SPSpringGetForceForNode(SPSpringRef spring, SPNodeRef node) {
    return SPSpringGetSpringForceForNode(spring, node);
}

SPVector SPSpringGetSpringForceForNode(SPSpringRef spring, SPNodeRef node) {
    if (spring->node1 != node && spring->node2 != node) return SPVectorMake(0, 0);
    float flip = (node == spring->node1) ? -1.0 : 1.0;
    float dX = spring->node2->position.x - spring->node1->position.x;
    float dY = spring->node2->position.y - spring->node1->position.y;
    float dL = SPSpringGetLength(spring) - spring->initalLength;
    return SPVectorMakePolar(atan2(dY, dX), (flip * -1.0 * spring->rate * dL));
}

float SPSpringGetLength(SPSpringRef spring) {
    return sqrt(pow(spring->node2->position.x - spring->node1->position.x, 2) +
                pow(spring->node2->position.y - spring->node1->position.y, 2));
}

