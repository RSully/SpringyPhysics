//
//  SPDotMeshView.m
//  SpringyPhysics
//
//  Created by Ryan Sullivan on 4/24/12.
//  Copyright (c) 2012 Freelance Web Developer. All rights reserved.
//

#import "SPDotMeshView.h"

@implementation SPDotMeshView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setMultipleTouchEnabled:NO];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        UITapGestureRecognizer *tripleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tripleTap:)];
        UITapGestureRecognizer *quadTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(quadTap:)];
        UITapGestureRecognizer *quintTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(quintTap:)];
        
        [doubleTap setNumberOfTapsRequired:2];
        [doubleTap setNumberOfTouchesRequired:1];
        [doubleTap requireGestureRecognizerToFail:tripleTap];
        [doubleTap requireGestureRecognizerToFail:quadTap];
        [self addGestureRecognizer:doubleTap];
        
        [tripleTap setNumberOfTapsRequired:3];
        [tripleTap setNumberOfTouchesRequired:1];
        [tripleTap requireGestureRecognizerToFail:quadTap];
        [self addGestureRecognizer:tripleTap];
        
        [quadTap setNumberOfTapsRequired:4];
        [quadTap setNumberOfTouchesRequired:1];
        [self addGestureRecognizer:quadTap];
        
        [quintTap setNumberOfTapsRequired:1];
        [quintTap setNumberOfTouchesRequired:5];
        [self addGestureRecognizer:quintTap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panMovement:)];
        [pan setMaximumNumberOfTouches:1];
        [self addGestureRecognizer:pan];
        
//        [self performSelector:@selector(quintTap:) withObject:quintTap afterDelay:0.5];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(ctx, self.bounds);
    
    
    CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 1.0);
    CGContextSetLineWidth(ctx, 5.0);
    for (int i = 0; i < numSprings; i++) {
        SPSpringRef spring = springs[i];
        SPNodeRef node1 = spring->node1;
        SPNodeRef node2 = spring->node2;
        
        CGPoint points[2] = {node1->position, node2->position};
        CGContextStrokeLineSegments(ctx, points, 2);
    }
    
    CGContextSetRGBStrokeColor(ctx, 0.6, 0.6, 0.4, 1.0);
    CGContextSetRGBFillColor(ctx, (70.0/255.0), (70.0/255.0), (65.0/255.0), 1.0);
    for (int i = 0; i < numNodes; i++) {
        SPNodeRef node = nodes[i];
        
        CGContextSaveGState(ctx);
        if (node->lockPosition) {
            CGContextSetRGBFillColor(ctx, 1.0, 0.6, 0.4, 1.0);
        }
        CGContextFillEllipseInRect(ctx, [self rectForNode:node]);
        CGContextRestoreGState(ctx);
        
        if (node == _tripleTapNode) {
            CGContextStrokeEllipseInRect(ctx, [self rectForNode:node]);
        }
    }
}


#pragma - Taps

-(void)doubleTap:(UITapGestureRecognizer*)sender {
    [self addNodeToPoint:[sender locationInView:self]];
}

-(void)tripleTap:(UITapGestureRecognizer*)sender {
    SPNodeRef node = [self getNodeAtPoint:[sender locationInView:self]];
    
    if (node && _tripleTapNode && (node != _tripleTapNode)) {
        BOOL exists = NO;
        
        for (int i = 0; i < numSprings; i++) {
            SPSpringRef spring = springs[i];
            if ((spring->node1 == node || spring->node2 == node) && (spring->node1 == _tripleTapNode || spring->node2 == _tripleTapNode)) {
                exists = YES;
                break;
            }
        }
        
        if (!exists) {
            [self addSpring:SPSpringCreate(kSpringRate, node, _tripleTapNode)];
        }
    }
    _tripleTapNode = node;
}

-(void)quadTap:(UITapGestureRecognizer*)sender {
    SPNodeRef node = [self getNodeAtPoint:[sender locationInView:self]];
    if (!node) return;
    node->lockPosition = !node->lockPosition;
}

-(void)quintTap:(UITapGestureRecognizer*)sender {
    int ltr = 8;
    int ttb = 10;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat sepW = (width - (kNodeRadius*2)) / (ltr - 1);
    CGFloat sepH = (height - (kNodeRadius*2)) / (ttb - 1);
    
    for (int x = 0; x < ltr; x++) {
        for (int y = 0; y < ttb; y++) {
            CGPoint pos = CGPointMake(kNodeRadius+(x*sepW), kNodeRadius+(y*sepH));
            SPNodeRef n = [self addNodeToPoint:pos];
            
            if (x == 0 || y == 0 || x == (ltr-1) || y == (ttb-1)) {
                n->lockPosition = YES;
            }
        }
    }
    
    for (int n = 1; n < numNodes; n++) {
        if (n % (ttb) == 0) continue;
        [self addSpring:SPSpringCreate(kSpringRate, nodes[n], nodes[n-1])];
    }
    for (int n = 1; n < numNodes-(ttb-1); n++) {
        [self addSpring:SPSpringCreate(kSpringRate, nodes[n-1], nodes[(ttb-1)+n])];
    }
}



@end
