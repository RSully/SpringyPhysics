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
        
        _dragNodes = [NSMutableDictionary new];
        [self setMultipleTouchEnabled:YES];
        
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
        
        //[self performSelector:@selector(quintTap:) withObject:nil afterDelay:0.1];
    }
    return self;
}

-(void)startAnimation {
    if (animationTimer) return;
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/kFPS) target:self selector:@selector(animate:) userInfo:nil repeats:YES];
}

-(void)stopAnimation {
    [animationTimer invalidate];
    animationTimer = nil;
}

-(void)animate:(id)sender {
//    CGFloat time = 1.0/kFPS;
    CGFloat time = [[NSDate date] timeIntervalSinceDate:lastAnimation];
    
    for (SPNode *node in nodes) {
        SPVector *force = [node netForce];
        SPVector *accel = [SPVector vectorWithX:force.x/node.mass y:force.y/node.mass];
        node.velocity = [node.velocity vectorByAddingVector:[SPVector vectorWithX:accel.x*time y:accel.y*time]];
    }
    for (SPNode *node in nodes) {
        if ([[[_dragNodes allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [(SPDragNodeInfo*)evaluatedObject node] == node;
        }]] count] > 0) continue;
        
        node.position = CGPointMake(node.position.x+(node.velocity.x*time), node.position.y+(node.velocity.y*time));
        node.position = CGPointMake(MIN(self.bounds.size.width-kNodeRadius, node.position.x), MIN(self.bounds.size.height-kNodeRadius, node.position.y));
        node.position = CGPointMake(MAX(self.bounds.origin.x+kNodeRadius, node.position.x), MAX(self.bounds.origin.y+kNodeRadius, node.position.y));
    }
    
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
        SPNode *node1 = [[spring nodes] objectAtIndex:0];
        SPNode *node2 = [[spring nodes] objectAtIndex:1];
        
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


-(NSString*)infoKeyForObject:(id)obj {
    return [NSString stringWithFormat:@"%p", obj];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    SPNode *node =  [self getNodeAtPoint:[touch locationInView:self]];
    if (!node) return;
    node.velocity = [SPVector vectorWithX:0.0 y:0.0];
    
    for (NSString *key in [_dragNodes allKeys]) {
        SPDragNodeInfo *info = [_dragNodes objectForKey:key];
        if (info.node == node) [_dragNodes removeObjectForKey:key];
    }
    
    [_dragNodes setObject:[SPDragNodeInfo infoWithNode:node] forKey:[self infoKeyForObject:touch]];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    [_dragNodes removeObjectForKey:[self infoKeyForObject:touch]];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    [_dragNodes removeObjectForKey:[self infoKeyForObject:touch]];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    SPDragNodeInfo *nodeInfo = [_dragNodes objectForKey:[self infoKeyForObject:touch]];
    if (!nodeInfo) return;
    
    SPNode *node = nodeInfo.node;
//    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:nodeInfo.moved];
    
    if (time > 0) {
//        CGPoint oldPosition = node.position;
        node.position = [touch locationInView:self];
//        node.velocity = [SPVector vectorWithX:(node.position.x - oldPosition.x)/time 
//                                            y:(node.position.y - oldPosition.y)/time];
    }
    nodeInfo.moved = [NSDate date];
}

@end
