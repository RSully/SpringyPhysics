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
        nodes = [NSMutableArray new];
        springs = [NSMutableArray new];
                
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
    
    for (SPNode *node in nodes) {
        SPVector *force = [node netForce];
        SPVector *accel = [SPVector vectorWithX:force.x/node.mass y:force.y/node.mass];
        node.velocity = [node.velocity vectorByAddingVector:[SPVector vectorWithX:accel.x*time y:accel.y*time]];
    }
    
    for (SPNode *node in nodes) {
        if (node == _dragNode) continue;
        
        node.position = CGPointMake(node.position.x+(node.velocity.x*time), node.position.y+(node.velocity.y*time));
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
        _dragNode.position = panPoint;
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        CGPoint vel = [pan velocityInView:self];
        _dragNode.velocity = [SPVector vectorWithX:vel.x y:vel.y];
        
        _dragNode = nil;
    }
}

#pragma - Helpers

-(SPNode*)addNodeToPoint:(CGPoint)pt {
    SPNode *node = [SPNode nodeWithDamp:kSpringDamp point:pt mass:kNodeMass];
    node.mesh = self;
    [nodes addObject:node];
    return node;
}

-(NSArray*)springsForNode:(SPNode*)node {
    NSLog(@"Calling -springsForNode *** Bad on performance");
    
    NSMutableArray *nSprings = [NSMutableArray new];
    for (SPSpring *spring in springs) {
        if ([[spring nodes] containsObject:node]) {
            [nSprings addObject:spring];
        }
    }
    return nSprings;
}

-(SPNode*)getNodeAtPoint:(CGPoint)pt {
    for (SPNode *node in nodes) {
        CGPathRef path = CGPathCreateWithEllipseInRect([self rectForNode:node], nil);
        if (CGPathContainsPoint(path, nil, pt, NO)) {
            return node;
        }
    }
    return nil;
}


-(CGRect)rectForNode:(SPNode*)node {
    return CGRectMake(node.position.x-kNodeRadius, 
                      node.position.y-kNodeRadius, 
                      kNodeRadius*2, kNodeRadius*2);
}


@end
