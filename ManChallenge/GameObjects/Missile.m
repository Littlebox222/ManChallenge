//
//  Missile.m
//  ManChallenge
//
//  Created by Littlebox on 14-3-17.
//  Copyright (c) 2014年 Littlebox222. All rights reserved.
//

#import "Missile.h"

#define kAngleEdge  [CCDirector sharedDirector].winSize.height / [CCDirector sharedDirector].winSize.width

@implementation Missile

- (id)initWithFile:(NSString *)filename andContainArray:(NSMutableArray *)containArray targetObject:(GameObject *)target
{
    self = [super initWithFile:filename];
    
    if (!self) {
        
        return NULL;
    }
    
    _containArray = containArray;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    // speed
    int minDuration = 1.0;
    int maxDuration = 3.0;
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
    
    if (edgeStart == 0) {
        
        self.position = ccp(actualX, maxY);
        
        float tmpAngle = 0.0;
        
        if (self.position.x == target.position.x) {
            
            self.rotation = 180;
            endPosition = ccp(self.position.x, -self.contentSize.height/2);
            
        }else {
            
            tmpAngle = atan( (target.position.y - self.position.y) / (target.position.x - self.position.x) );
            
            if (tmpAngle < 0) {
                
                self.rotation = 90 + CC_RADIANS_TO_DEGREES(ABS(tmpAngle));
                float tmp = self.position.y / tan(tmpAngle);
                
                if (ABS(tmp) < winSize.width) {
                    endPosition = ccp(self.position.x - tmp, -self.contentSize.height/2);
                }else {
                    endPosition = ccp(winSize.width + self.contentSize.width/2, winSize.height - tan(tmpAngle) * (self.position.x - winSize.width));
                }
                
            }else {
                
                self.rotation = -90 - CC_RADIANS_TO_DEGREES(ABS(tmpAngle));
                float tmp = self.position.y / tan(tmpAngle);
                
                if (ABS(tmp) < winSize.width) {
                    endPosition = ccp(self.position.x - tmp, -self.contentSize.height/2);
                }else {
                    endPosition = ccp(-self.contentSize.width/2, winSize.height - tan(tmpAngle) * self.position.x);
                }
            }
        }
        
    }else if (edgeStart == 1) {
        
        self.position = ccp(winSize.width + self.contentSize.width/2, actualY);
        
        float tmpAngle = 0.0;
        
        if (self.position.y == target.position.y) {
            
            self.rotation = -90;
            endPosition = ccp(-self.contentSize.width / 2, self.position.y);
            
        }else {
            
            tmpAngle = atan((self.position.y - target.position.y) / (self.position.x - target.position.x));
            
            if (tmpAngle < 0) {
                
                self.rotation = -90 + CC_RADIANS_TO_DEGREES(ABS(tmpAngle));
                float tmp = (winSize.height - self.position.y) / -tan(tmpAngle);
                
                if (ABS(tmp) < winSize.width) {
                    endPosition = ccp(self.position.x - tmp, winSize.height + self.contentSize.height/2);
                }else {
                    endPosition = ccp(-self.contentSize.width/2, self.position.y - tan(tmpAngle) * self.position.x);
                }
                
            }else {
                
                self.rotation = -90 - CC_RADIANS_TO_DEGREES(ABS(tmpAngle));
                float tmp = self.position.y / tan(tmpAngle);
                
                if (ABS(tmp) < winSize.width) {
                    endPosition = ccp(self.position.x - tmp, -self.contentSize.height/2);
                }else {
                    endPosition = ccp(-self.contentSize.width/2, self.position.y - tan(tmpAngle) * winSize.width);
                }
            }
        }
        
    }else if (edgeStart == 2) {
        
        self.position = ccp(actualX, minY);
        
        float tmpAngle = 0.0;
        
        if (self.position.x == target.position.x) {
            
            self.rotation = 0;
            endPosition = ccp(self.position.x, winSize.height + self.contentSize.height/2);
            
        }else {
            
            tmpAngle = atan( (target.position.y - self.position.y) / (target.position.x - self.position.x) );
            
            if (tmpAngle < 0) {
                
                self.rotation = -90 + CC_RADIANS_TO_DEGREES(ABS(tmpAngle));
                float tmp = winSize.height / -tan(tmpAngle);
                
                if (ABS(tmp) < winSize.width) {
                    endPosition = ccp(self.position.x - tmp, winSize.height + self.contentSize.height/2);
                }else {
                    endPosition = ccp(-self.contentSize.width/2, -tan(tmpAngle) * self.position.x);
                }
                
            }else {
                
                self.rotation = 90 - CC_RADIANS_TO_DEGREES(ABS(tmpAngle));
                float tmp = winSize.height / tan(tmpAngle);
                
                if (ABS(tmp) < winSize.width) {
                    endPosition = ccp(self.position.x + tmp, winSize.height + self.contentSize.height/2);
                }else {
                    endPosition = ccp(winSize.width + self.contentSize.width/2, tan(tmpAngle) * (winSize.width - self.position.x));
                }
            }
        }
        
    }else {
        
        self.position = ccp(-self.contentSize.width/2, actualY);
        
        float tmpAngle = 0.0;
        
        if (self.position.x == target.position.x) {
            
            self.rotation = 90;
            endPosition = ccp(winSize.width + self.contentSize.width / 2, self.position.y);
            
        }else {
            
            tmpAngle = atan((self.position.y - target.position.y) / (self.position.x - target.position.x));
            
            if (tmpAngle < 0) {
                
                self.rotation = 90 + CC_RADIANS_TO_DEGREES(ABS(tmpAngle));
                float tmp = self.position.y / -tan(tmpAngle);
                
                if (ABS(tmp) < winSize.width) {
                    endPosition = ccp(tmp, -self.contentSize.height/2);
                }else {
                    endPosition = ccp(winSize.width + self.contentSize.width/2, self.position.y + tan(tmpAngle) * winSize.width);
                }
                
            }else {
                
                self.rotation = 90 - CC_RADIANS_TO_DEGREES(ABS(tmpAngle));
                float tmp = (winSize.height - self.position.y) / tan(tmpAngle);
                
                if (ABS(tmp) < winSize.width) {
                    endPosition = ccp(tmp, winSize.height + self.contentSize.height/2);
                }else {
                    endPosition = ccp(winSize.width + self.contentSize.width/2, self.position.y + tan(tmpAngle) * winSize.width);
                }
            }
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
