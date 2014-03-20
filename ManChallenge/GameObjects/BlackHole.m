//
//  BlackHole.m
//  ManChallenge
//
//  Created by Littlebox on 14-3-18.
//  Copyright (c) 2014年 Littlebox222. All rights reserved.
//

#import "BlackHole.h"

@implementation BlackHole

- (id)initWithFile:(NSString *)filename {
    
    self = [super initWithFile:filename];
    
    if (!self) {
        
        return NULL;
    }
    
    self.opacity = 0;
    self.zOrder = 0;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    int minY = self.contentSize.height / 2;
    int maxY = winSize.height - self.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    int minX = self.contentSize.width;
    int maxX = winSize.width - self.contentSize.width/2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    self.position = ccp(actualX, actualY);
    
    
    
    CCRepeatForever *rotate = [CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:5.0 angle:360]];
    CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:2];
    CCFadeIn *fadeIn = [CCFadeIn actionWithDuration:5];
    
    CCCallBlockN *actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node removeFromParentAndCleanup:YES];
    }];
    
    
    [self runAction:rotate];
    [self runAction:[CCSequence actions:fadeIn, fadeOut, actionMoveDone, nil]];
    
    return self;
}

@end
