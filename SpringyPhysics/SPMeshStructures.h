//
//  SPMeshStructures.h
//  SpringyPhysics
//
//  Created by Ryan Sullivan on 4/27/12.
//  Copyright (c) 2012 Freelance Web Developer. All rights reserved.
//

#ifndef SpringyPhysics_SPMeshStructures_h
#define SpringyPhysics_SPMeshStructures_h

@class SPMeshView;
typedef struct _SPNode *SPNodeRef;
typedef struct _SPSpring *SPSpringRef;

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

struct _SPSpring {
    int retainCount;
    
    float rate;
    float initalLength;
    
    SPNodeRef node1;
    SPNodeRef node2;
};


#endif
