//
//  SPMeshView.h
//  SpringyPhysics
//
//  Created by Ryan Sullivan on 4/15/12.
//  Copyright (c) 2012 Freelance Web Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPNode.h"
#import "SPSpring.h"
#import "SPDragNodeInfo.h"

#define kNodeRadius 32.0
#define kSpringRate 1.6
#define kSpringDamp 0.1
#define kNodeMass 1.2
#define kFPS 35.0


@interface SPMeshView : UIView {
    NSMutableArray *nodes;
    NSMutableArray *springs;
    
    NSTimer *animationTimer;
    NSDate *lastAnimation;
    
    SPNode *_tripleTapNode;
    SPNode *_dragNode;
}

-(SPNode*)addNodeToPoint:(CGPoint)pt;
-(NSArray*)springsForNode:(SPNode*)node;

-(CGRect)rectForNode:(SPNode*)node;

-(void)startAnimation;
-(void)stopAnimation;

@end
