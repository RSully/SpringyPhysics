//
//  SPVector.m
//  SpringyPhysics
//
//  Created by Ryan Sullivan on 4/15/12.
//  Copyright (c) 2012 Freelance Web Developer. All rights reserved.
//

#import "SPVector.h"



SPVector SPVectorMake(float x, float y) {
    SPVector vector;
    vector.x = x;
    vector.y = y;
    return vector;
}

SPVector SPVectorMakePolar(float a, float m) {
    return SPVectorMake(cos(a)*m, sin(a)*m);
}


SPVector SPVectorSum(SPVector v1, SPVector v2) {
    return SPVectorMake(v1.x + v2.x, v1.x + v2.x);
}


float SPVectorGetAngle(SPVector vector) {
    return atan2(vector.y, vector.x);
}

float SPVectorGetMagnitude(SPVector vector) {
    return sqrt(pow(vector.x, 2) + pow(vector.y, 2));
}
