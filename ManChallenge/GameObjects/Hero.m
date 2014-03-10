//
//  Hero.m
//  ManChallenge
//
//  Created by Littlebox222 on 14-3-7.
//  Copyright (c) 2014年 Littlebox222. All rights reserved.
//

#import "Hero.h"
#import "SimpleAudioEngine.h"
#import "Bullet.h"

@implementation Hero

@synthesize destroyed = _destroyed;
@synthesize posPerSecByAccX = _posPerSecByAccX;
@synthesize posPerSecByAccY = _posPerSecByAccY;


- (id)initWithFile:(NSString *)filename
{
    self = [super initWithFile:filename];
    if (!self) return NULL;
    
    _destroyed = NO;
    self.tag = kTagHero;
    
    [self scheduleUpdate];
    
    return self;
}


- (void)update:(ccTime)delta
{
    if (self.destroyed) {
        
        return;
        
    }else {
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        float maxX = winSize.width - self.contentSize.width/2;
        float minX = self.contentSize.width/2;
        float newX = self.position.x + (_posPerSecByAccX * delta);
        newX = MIN(MAX(newX, minX), maxX);
        
        float maxY = winSize.height - self.contentSize.height/2;
        float minY = self.contentSize.height/2;
        float newY = self.position.y + (_posPerSecByAccY * delta);
        newY = MIN(MAX(newY, minY), maxY);
        
        self.position = ccp(newX, newY);
    }
}

- (void)handleCollisionWith:(GameObject *)gameObject
{
    
    if (!_destroyed && [gameObject isKindOfClass:[Bullet class]]) {
        
        _destroyed = YES;
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"game_over.mp3"];
    }
}

@end
