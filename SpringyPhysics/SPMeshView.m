//
//  SPMeshView.m
//  SpringyPhysics
//
//  Created by Ryan Sullivan on 4/15/12.
//  Copyright (c) 2012 Freelance Web Developer. All rights reserved.
//

#import "SPMeshView.h"


@implementation SPMeshView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        nodes = [NSMutableArray new];
        springs = [NSMutableArray new];
        
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
        
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animate:)];
        displayLink.paused = YES;
        displayLink.frameInterval = 1.0;
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return self;
}

-(void)startAnimation {
    displayLink.paused = NO;
}

-(void)stopAnimation {
    displayLink.paused = YES;
}

-(void)animate:(id)sender {
    CGFloat time = [[NSDate date] timeIntervalSinceDate:lastAnimation];
    NSDate *tt1 = [NSDate date];
    
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
    NSTimeInterval tt2 = [[NSDate date] timeIntervalSinceDate:tt1];
    NSLog(@"Took %f to calculate", tt2);
    
    [self setNeedsDisplay];
    lastAnimation = [NSDate date];
}


-(SPNode*)addNodeToPoint:(CGPoint)pt {
    SPNode *node = [SPNode nodeWithDamp:kSpringDamp point:pt mass:kNodeMass];
    node.mesh = self;
    [nodes addObject:node];
    return node;
}

-(NSArray*)springsForNode:(SPNode*)node {
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

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(ctx, self.bounds);
    
    
    CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 1.0);
    CGContextSetLineWidth(ctx, 5.0);
    for (int i = 0; i < [springs count]; i++) {
        SPSpring *spring = [springs objectAtIndex:i];
        NSArray *sNodes = [[spring nodes] allObjects];
        SPNode *node1 = [sNodes objectAtIndex:0];
        SPNode *node2 = [sNodes objectAtIndex:1];
        
        CGPoint points[2] = {node1.position, node2.position};
        CGContextStrokeLineSegments(ctx, points, 2);
    }
    
    CGContextSetRGBStrokeColor(ctx, 0.6, 0.6, 0.4, 1.0);
    CGContextSetRGBFillColor(ctx, (70.0/255.0), (70.0/255.0), (65.0/255.0), 1.0);
    for (int i = 0; i < [nodes count]; i++) {
        SPNode *node = [nodes objectAtIndex:i];
        
        CGContextSaveGState(ctx);
        if (node.lockPosition) {
            CGContextSetRGBFillColor(ctx, 1.0, 0.6, 0.4, 1.0);
        }
        CGContextFillEllipseInRect(ctx, [self rectForNode:node]);
        CGContextRestoreGState(ctx);
        
        if (node == _tripleTapNode) {
            CGContextStrokeEllipseInRect(ctx, [self rectForNode:node]);
        }
    }
}



-(void)doubleTap:(UITapGestureRecognizer*)sender {
    [self addNodeToPoint:[sender locationInView:self]];
}

-(void)tripleTap:(UITapGestureRecognizer*)sender {
    SPNode *node = [self getNodeAtPoint:[sender locationInView:self]];
    
    if (node && _tripleTapNode && (node != _tripleTapNode)) {
        BOOL exists = NO;
        
        for (SPSpring *spring in springs) {
            if ([[spring nodes] containsObject:node] && [[spring nodes] containsObject:_tripleTapNode]) {
                exists = YES;
                break;
            }
        }
        
        if (!exists) {
            [springs addObject:[SPSpring springWithRate:kSpringRate node:node node:_tripleTapNode]];
        }
    }
    _tripleTapNode = node;
}

-(void)quadTap:(UITapGestureRecognizer*)sender {
    SPNode *node = [self getNodeAtPoint:[sender locationInView:self]];
    node.lockPosition = !node.lockPosition;
}

-(void)quintTap:(UITapGestureRecognizer*)sender {
    [nodes removeAllObjects];
    [springs removeAllObjects];
    
    int ltr = 8;
    int ttb = 10;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat sepW = (width - (kNodeRadius*2)) / (ltr - 1);
    CGFloat sepH = (height - (kNodeRadius*2)) / (ttb - 1);
    
    for (int x = 0; x < ltr; x++) {
        for (int y = 0; y < ttb; y++) {
            CGPoint pos = CGPointMake(kNodeRadius+(x*sepW), kNodeRadius+(y*sepH));
            SPNode *n = [self addNodeToPoint:pos];
            
            if (x == 0 || y == 0 || x == (ltr-1) || y == (ttb-1)) {
                n.lockPosition = YES;
            }
        }
    }
    
    for (int n = 1; n < [nodes count]; n++) {
        if (n % (ttb) == 0) continue;
        [springs addObject:[SPSpring springWithRate:kSpringRate node:[nodes objectAtIndex:n] node:[nodes objectAtIndex:n-1]]];
    }
    for (int n = 1; n < [nodes count]-(ttb-1); n++) {
        [springs addObject:[SPSpring springWithRate:kSpringRate node:[nodes objectAtIndex:n-1] node:[nodes objectAtIndex:(ttb-1)+n]]];
    }
}



-(void)panMovement:(UIPanGestureRecognizer *)pan {
    CGPoint panPoint = [pan locationInView:self];
    
    if (pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateFailed) {
        _dragNode = nil;
        return;
    }
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        _dragNode = [self getNodeAtPoint:panPoint];
        //NSLog(@"%@ / %@", _dragNode, NSStringFromCGPoint(panPoint));
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        //lastTouchPoint = panPoint;
        //lastTouchTime = [[NSDate date] timeIntervalSince1970];
        
        _dragNode.position = panPoint;
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        CGPoint vel = [pan velocityInView:self];
        //NSTimeInterval timeDiff = [[NSDate date] timeIntervalSince1970] - lastTouchTime;
        
        _dragNode.velocity = [SPVector vectorWithX:vel.x y:vel.y];
        
        _dragNode = nil;
    }
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    
//    _dragNode =  [self getNodeAtPoint:[touch locationInView:self]];
//    if (!_dragNode) return;
//    
//    _dragNode.velocity = [SPVector vectorWithX:0.0 y:0.0];
//}
//
//-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    _dragNode = nil;
//}
//
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    
//    NSTimeInterval timeDiff = touch.timestamp - lastTouchTime;
//    CGPoint loc = [touch locationInView:self];
//    CGPoint pLoc = lastTouchPoint;
//    
//    _dragNode.velocity = [SPVector vectorWithX:(loc.x-pLoc.x)/timeDiff y:(loc.y-pLoc.y)/timeDiff];
//    
//    _dragNode = nil;
//    NSLog(@"-touchesEnded");
//}
//
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    SPNode *node = _dragNode;
//    
//    if (time > 0) {
//        node.position = [touch locationInView:self];
//    }
//    lastTouchTime = touch.timestamp;
//    lastTouchPoint = node.position;
//}

@end
