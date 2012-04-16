//
//  SPDragNodeInfo.h
//  SpringyPhysics
//
//  Created by Ryan Sullivan on 4/15/12.
//  Copyright (c) 2012 Freelance Web Developer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPNode;

@interface SPDragNodeInfo : NSObject {
    __weak SPNode *node;
    NSDate *moved;
}

+(id)infoWithNode:(SPNode*)n;
-(id)initWithNode:(SPNode*)n;

@property (weak, readonly) SPNode *node;
@property (strong) NSDate *moved;

@end
