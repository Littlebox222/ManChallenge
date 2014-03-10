//
//  Bullet.m
//  ManChallenge
//
//  Created by Littlebox222 on 14-3-7.
//  Copyright (c) 2014年 Littlebox222. All rights reserved.
//

#import "Bullet.h"

@implementation Bullet

- (id)initWithFile:(NSString *)filename andContainArray:(NSMutableArray *)containArray
{
    self = [super initWithFile:filename];
    
    if (!self) {
        
        return NULL;
    }
    
    _containArray = containArray;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    // speed
    int minDuration = 3.0;
    int maxDuration = 8.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // start & end
    int edgeStart = arc4random() % 4; // 0 -> up, 1 -> right
    
    int minY = -self.contentSize.height / 2;
    int maxY = winSize.height + self.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    int minX = -self.contentSize.width / 2;
    int maxX = winSize.width + self.contentSize.width/2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    
    CCMoveTo *actionMove;
    CGPoint endPosition;
    int edgeEnd = arc4random() % 3;
    
    if (edgeStart == 0) {
        
        self.position = ccp(actualX, maxY);
        
        int minEndX = -self.contentSize.width / 2;
        int maxEndX = winSize.width + self.contentSize.width / 2;
        int rangeEndX = maxEndX - minEndX;
        int actualEndX = (arc4random() % rangeEndX) + minEndX;
        
        int minEndY = -self.contentSize.height / 2;
        int maxEndY = winSize.height / 2;
        int rangeEndY = maxEndY - minEndY;
        int actualEndY = (arc4random() % rangeEndY) + minEndY;
        
        if (edgeEnd == 0) {
            endPosition = ccp(maxEndX, actualEndY);
        }else if (edgeEnd == 1) {
            endPosition = ccp(actualEndX, minEndY);
        }else {
            endPosition = ccp(minEndX, actualEndY);
        }
        
    }else if (edgeStart == 1) {
        
        self.position = ccp(winSize.width + self.contentSize.width/2, actualY);
        
        int minEndX = -self.contentSize.width / 2;
        int maxEndX = winSize.width / 2;
        int rangeEndX = maxEndX - minEndX;
        int actualEndX = (arc4random() % rangeEndX) + minEndX;
        
        int minEndY = -self.contentSize.height / 2;
        int maxEndY = winSize.height + self.contentSize.height / 2;
        int rangeEndY = maxEndY - minEndY;
        int actualEndY = (arc4random() % rangeEndY) + minEndY;
        
        if (edgeEnd == 0) {
            endPosition = ccp(actualEndX, minEndY);
        }else if (edgeEnd == 1) {
            endPosition = ccp(minEndX, actualEndY);
        }else {
            endPosition = ccp(actualEndX, maxEndY);
        }
        
    }else if (edgeStart == 2) {
        
        self.position = ccp(actualX, minY);
        
        int minEndX = -self.contentSize.width / 2;
        int maxEndX = winSize.width + self.contentSize.width / 2;
        int rangeEndX = maxEndX - minEndX;
        int actualEndX = (arc4random() % rangeEndX) + minEndX;
        
        int minEndY = winSize.height / 2;
        int maxEndY = winSize.height + self.contentSize.height / 2;
        int rangeEndY = maxEndY - minEndY;
        int actualEndY = (arc4random() % rangeEndY) + minEndY;
        
        if (edgeEnd == 0) {
            endPosition = ccp(minEndX, actualEndY);
        }else if (edgeEnd == 1) {
            endPosition = ccp(actualEndX, maxEndY);
        }else {
            endPosition = ccp(maxEndX, actualEndY);
        }
        
    }else {
        
        self.position = ccp(-self.contentSize.width/2, actualY);
        
        int minEndX = winSize.width / 2;
        int maxEndX = winSize.width + self.contentSize.width / 2;
        int rangeEndX = maxEndX - minEndX;
        int actualEndX = (arc4random() % rangeEndX) + minEndX;
        
        int minEndY = -self.contentSize.height / 2;
        int maxEndY = winSize.height + self.contentSize.height / 2;
        int rangeEndY = maxEndY - minEndY;
        int actualEndY = (arc4random() % rangeEndY) + minEndY;
        
        if (edgeEnd == 0) {
            endPosition = ccp(actualEndX, maxEndY);
        }else if (edgeEnd == 1) {
            endPosition = ccp(maxEndX, actualEndY);
        }else {
            endPosition = ccp(actualEndX, minEndY);
        }
    }
    
    
    // animation
    actionMove = [CCMoveTo actionWithDuration:actualDuration position:endPosition];
    
    CCCallBlockN *actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node removeFromParentAndCleanup:YES];
        [_containArray removeObject:node];
    }];
    
    [self runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    
    return self;
}

@end
