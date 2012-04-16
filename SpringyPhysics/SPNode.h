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

@interface SPNode : NSObject {
    __weak SPMeshView *mesh;
    
    CGFloat damp;
    CGFloat mass;
    BOOL lockPosition;
    
    CGPoint position;
    SPVector *velocity;
}

+(SPNode*)nodeWithDamp:(CGFloat)dp point:(CGPoint)pt mass:(CGFloat)m;
-(id)initWithDamp:(CGFloat)dp point:(CGPoint)pt mass:(CGFloat)m;

-(SPVector*)netForce;

@property (assign) BOOL lockPosition;
@property (assign) CGPoint position;
@property (assign) CGFloat mass;
@property (nonatomic, strong) SPVector *velocity;
@property (weak) SPMeshView *mesh;

@end
