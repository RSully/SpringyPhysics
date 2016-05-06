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
#import <QuartzCore/QuartzCore.h>

#define kNodesAllocd 12
#define kSpringsAllocd 8

#define kNodeRadius 32.0
#define kSpringRate 1.6
#define kSpringDamp 0.2
#define kNodeMass 1.2


@interface SPMeshView : UIView {
    SPNodeRef *nodes;
    int numNodes;
    int numNodesAllocd;
    SPSpringRef *springs;
    int numSprings;
    int numSpringsAllocd;
    
    CADisplayLink *displayLink;
    NSTimer *animationTimer;
    NSDate *lastAnimation;
    
    SPNodeRef _dragNode;
}

-(SPNodeRef)addNodeToPoint:(CGPoint)pt;
-(SPNodeRef)getNodeAtPoint:(CGPoint)pt;
-(CGRect)rectForNode:(SPNodeRef)node;

-(void)addNode:(SPNodeRef)node;
-(void)removeNode:(SPNodeRef)node;
-(void)addSpring:(SPSpringRef)spring;
-(void)removeSpring:(SPSpringRef)spring;

-(void)startAnimation;
-(void)stopAnimation;

@end
