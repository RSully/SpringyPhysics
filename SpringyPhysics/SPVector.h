//
//  SPVector.h
//  SpringyPhysics
//
//  Created by Ryan Sullivan on 4/15/12.
//  Copyright (c) 2012 Freelance Web Developer. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef struct {
    float x;
    float y;
} SPVector;

SPVector SPVectorMake(float x, float y);
SPVector SPVectorMakePolar(float a, float m);
SPVector SPVectorSum(SPVector v1, SPVector v2);

float SPVectorGetAngle(SPVector vector);
float SPVectorGetMagnitude(SPVector vector);
