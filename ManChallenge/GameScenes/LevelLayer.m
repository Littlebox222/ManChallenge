//
//  LevelLayer.m
//  ManChallenge
//
//  Created by Littlebox222 on 14-3-7.
//  Copyright (c) 2014年 Littlebox222. All rights reserved.
//

#import "LevelLayer.h"
#import "GameScene.h"

@implementation LevelLayer

@synthesize player = _player;
@synthesize bullets = _bullets;

- (void)dealloc {
    
    [_player removeFromParentAndCleanup:YES];
    
    for (Bullet *node in _bullets) {
        [node removeFromParentAndCleanup:YES];
    }
    
    [_bullets removeAllObjects];
    [_bullets release];
    
    [super dealloc];
}

- (id)init {
    
    if (self = [super init]) {
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        self.player = [[[Hero alloc] initWithFile:@"player.png"] autorelease];
        _player.position = ccp(size.width/2, size.height/2);
        [self addChild:_player];
        
        self.bullets = [[[NSMutableArray alloc] init] autorelease];
        
        self.isAccelerometerEnabled = YES;
    }
    
    [self scheduleUpdate];
    [self schedule:@selector(gameLogic:) interval:1/5.0];
    
    return self;
}


static UIAccelerationValue rollingX = 0, rollingY = 0, rollingZ = 0;

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
#define kFilteringFactor 0.001
#define kRestAccel -0
#define kShipMaxPointsPerSec (winSize.width*0.5)
#define kMaxDiff 0.2
    
    rollingX = (acceleration.x * kFilteringFactor) + (rollingX * (1.0- kFilteringFactor));
    rollingY = (acceleration.y * kFilteringFactor) + (rollingY * (1.0- kFilteringFactor));
    rollingZ = (acceleration.z * kFilteringFactor) + (rollingZ * (1.0- kFilteringFactor));
    
    float accelX = acceleration.x - rollingX;
    float accelY = acceleration.y - rollingY;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    float accelDiffY = accelY - kRestAccel;
    float accelFractionY = accelDiffY / kMaxDiff;
    float pointsPerSecY = kShipMaxPointsPerSec * accelFractionY;
    
    float accelDiffX = accelX - kRestAccel;
    float accelFractionX = accelDiffX / kMaxDiff;
    float pointsPerSecX = kShipMaxPointsPerSec * accelFractionX;
    
    _player.posPerSecByAccX = pointsPerSecX;
    _player.posPerSecByAccY = pointsPerSecY;
}

- (void)update:(ccTime)delta {
    
    CGRect rect = _player.boundingBox;
    CGRect rect1 = CGRectMake(rect.origin.x + 11, rect.origin.y + 1, 8, 28);
    CGRect rect2 = CGRectMake(rect.origin.x +  4, rect.origin.y + 1, 7, 16);
    CGRect rect3 = CGRectMake(rect.origin.x + 19, rect.origin.y + 1, 7, 16);
    CGRect rect4 = CGRectMake(rect.origin.x +  0, rect.origin.y + 3, 4,  5);
    CGRect rect5 = CGRectMake(rect.origin.x + 27, rect.origin.y + 3, 4,  5);
    
    
    NSMutableArray *bulletsToDelete = [[NSMutableArray alloc] init];
    
    for (CCSprite *bullet in _bullets) {
        
        if (CGRectIntersectsRect(rect1, bullet.boundingBox) ||
            CGRectIntersectsRect(rect2, bullet.boundingBox) ||
            CGRectIntersectsRect(rect3, bullet.boundingBox) ||
            CGRectIntersectsRect(rect4, bullet.boundingBox) ||
            CGRectIntersectsRect(rect5, bullet.boundingBox)) {
            
            [bulletsToDelete addObject:bullet];
        }
    }
    
//    for (Bullet *bullet in bulletsToDelete) {
//        
//        [_bullets removeObject:bullet];
//        [self removeChild:bullet cleanup:YES];
//        
//        [_player handleCollisionWith:bullet];
//        
//        [[GameScene sharedScene] handleGameOver];
//    }
    
    [bulletsToDelete release];
}

-(void)gameLogic:(ccTime)dt {
    
    [self addBullet];
}

- (void)addBullet {
    
    Bullet *bullet =  [[[Bullet alloc] initWithFile:@"bullet.png" andContainArray:_bullets] autorelease];
    [_bullets addObject:bullet];
    
    [self addChild:bullet];
}

@end
