//
//  SPVector.h
//  SpringyPhysics
//
//  Created by Ryan Sullivan on 4/15/12.
//  Copyright (c) 2012 Freelance Web Developer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPVector : NSObject {
    CGFloat x;
    CGFloat y;
}

-(id)initWithX:(CGFloat)w Y:(CGFloat)h;

+(id)vectorWithMagnitude:(CGFloat)mag angle:(CGFloat)theta;
+(id)vectorWithX:(CGFloat)x y:(CGFloat)y;
+(id)vectorByAddingVector:(id)v1 toVector:(id)v2;

-(id)vectorByAddingVector:(SPVector*)v;

-(CGFloat)angle;
-(CGFloat)magnitude;
-(CGFloat)x;
-(CGFloat)y;

@end
