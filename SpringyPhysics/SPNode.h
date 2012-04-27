//
//  SPNode.h
//  SpringyPhysics
//
//  Created by Ryan Sullivan on 4/15/12.
//  Copyright (c) 2012 Freelance Web Developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPVector.h"

@class SPMeshView;


struct _SPNode {
    int retainCount;
    
    __unsafe_unretained SPMeshView *mesh;
    SPSpringRef *springs;
    int numSprings;
    int numSpringsAllocd;
    
    CGFloat damp;
    CGFloat mass;
    BOOL lockPosition;
    
    CGPoint position;
    SPVector velocity;
};

typedef struct _SPNode * SPNodeRef;


SPNodeRef SPNodeCreate(CGFloat damp, CGFloat mass, SPMeshView *mesh);
void SPNodeRelease(SPNodeRef node);

SPVector SPNodeGetNetForce(SPNodeRef node);

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

