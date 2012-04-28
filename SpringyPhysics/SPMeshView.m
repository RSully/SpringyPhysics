//
//  SPMeshView.m
//  SpringyPhysics
//
//  Created by Ryan Sullivan on 4/15/12.
//  Copyright (c) 2012 Freelance Web Developer. All rights reserved.
//

#import "SPMeshView.h"

@interface SPMeshView (Private)
@end


@implementation SPMeshView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        numSprings = 0;
        numSpringsAllocd = kSpringsAllocd;
        springs = malloc(numSpringsAllocd * sizeof(SPSpringRef));
        numNodes = 0;
        numNodesAllocd = kNodesAllocd;
        nodes = malloc(numNodesAllocd * sizeof(SPNodeRef));
                
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animate:)];
        displayLink.paused = YES;
        displayLink.frameInterval = 1.0;
        // Should this be NSDefaultRunLoopMode ?
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

-(void)dealloc {
    [displayLink invalidate];
}


-(void)startAnimation {
    displayLink.paused = NO;
}

-(void)stopAnimation {
    displayLink.paused = YES;
}


-(void)animate:(id)sender {
    CGFloat time = [[NSDate date] timeIntervalSinceDate:lastAnimation];
    
    for (int i = 0; i < numNodes; i++) {
        SPNodeRef node = nodes[i];
        SPVector force = SPNodeGetNetForce(node);
        SPVector accel = SPVectorMake(force.x/node->mass, force.y/node->mass);
        node->velocity = SPVectorSum(SPNodeGetVelocity(node), SPVectorMake(accel.x*time, accel.y*time));
    }
    
    for (int i = 0; i < numNodes; i++) {
        SPNodeRef node = nodes[i];
        if (node == _dragNode) continue;
        
        SPVector vel = SPNodeGetVelocity(node);
        node->position = CGPointMake(node->position.x+(vel.x*time), node->position.y+(vel.y*time));
        // This is supposed to bound the nodes to the screen
        //node.position = CGPointMake(MIN(self.bounds.size.width-kNodeRadius, node.position.x), MIN(self.bounds.size.height-kNodeRadius, node.position.y));
        //node.position = CGPointMake(MAX(self.bounds.origin.x+kNodeRadius, node.position.x), MAX(self.bounds.origin.y+kNodeRadius, node.position.y));
    }
    
    [self setNeedsDisplay];
    lastAnimation = [NSDate date];
}


-(void)panMovement:(UIPanGestureRecognizer *)pan {
    CGPoint panPoint = [pan locationInView:self];
    
    if (pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateFailed) {
        _dragNode = nil;
        return;
    }
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        _dragNode = [self getNodeAtPoint:panPoint];
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        _dragNode->position = panPoint;
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        CGPoint vel = [pan velocityInView:self];
        _dragNode->velocity = SPVectorMake(vel.x, vel.y);
        
        _dragNode = nil;
    }
}

#pragma - Helpers

-(SPNodeRef)addNodeToPoint:(CGPoint)pt {
    SPNodeRef node = SPNodeCreate(kSpringDamp, kNodeMass, self);
    node->position = pt;
    [self addNode:node];
    return node;
}

-(void)addNode:(SPNodeRef)node {
    for (int i = 0; i < numNodes; i++) {
        if (nodes[i] == node) return;
    }
    if (numNodes == numNodesAllocd) {
        numNodesAllocd += kNodesAllocd;
        nodes = realloc(nodes, numNodesAllocd * sizeof(SPNodeRef));
    }
    nodes[numNodes++] = SPNodeRetain(node);
}
-(void)removeNode:(SPNodeRef)node {
    for (int i = 0; i < numNodes; i++) {
        SPNodeRef _n = nodes[i];
        if (node == _n) {
            SPNodeRelease(_n);
            numNodes--;
            
            for (int n = i; n < numNodes; n++) {
                nodes[n] = nodes[n+1];
            }
        }
    }
}
-(void)addSpring:(SPSpringRef)spring {
    for (int i = 0; i < numNodes; i++) {
        if (springs[i] == spring) return;
    }
    if (numNodes == numNodesAllocd) {
        numSpringsAllocd += kSpringsAllocd;
        springs = realloc(springs, numSpringsAllocd * sizeof(SPSpringRef));
    }
    springs[numSprings++] = SPSpringRetain(spring);
}
-(void)removeSpring:(SPSpringRef)spring {
    for (int i = 0; i < numSprings; i++) {
        SPSpringRef _s = springs[i];
        if (spring == _s) {
            SPSpringRelease(_s);
            numSprings--;
            
            for (int n = i; n < numSprings; n++) {
                springs[n] = springs[n+1];
            }
        }
    }
}


-(SPNodeRef)getNodeAtPoint:(CGPoint)pt {
    for (int i = 0; i < numNodes; i++) {
        SPNodeRef node = nodes[i];
        CGPathRef path = CGPathCreateWithEllipseInRect([self rectForNode:node], nil);
        if (CGPathContainsPoint(path, nil, pt, NO)) {
            return node;
        }
    }
    return nil;
}


-(CGRect)rectForNode:(SPNodeRef)node {
    return CGRectMake(node->position.x-kNodeRadius, 
                      node->position.y-kNodeRadius, 
                      kNodeRadius*2, kNodeRadius*2);
}


@end
