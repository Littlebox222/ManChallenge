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
@synthesize missiles = _missiles;

- (void)dealloc {
    
    [_player removeFromParentAndCleanup:YES];
    
    for (Bullet *node in _bullets) {
        [node removeFromParentAndCleanup:YES];
    }
    
    [_bullets removeAllObjects];
    [_bullets release];
    
    for (Missile *node in _missiles) {
        [node removeFromParentAndCleanup:YES];
    }
    
    [_missiles removeAllObjects];
    [_missiles release];
    
    [super dealloc];
}

- (id)init {
    
    if (self = [super init]) {
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        self.player = [[[Hero alloc] initWithFile:@"player.png"] autorelease];
        _player.position = ccp(size.width/2, size.height/2);
        [self addChild:_player];
        
        self.bullets = [[[NSMutableArray alloc] init] autorelease];
        self.missiles = [[[NSMutableArray alloc] init] autorelease];
        
        self.isAccelerometerEnabled = YES;
    }
    
    [self scheduleUpdate];
    
    [self schedule:@selector(gameLogicBullet:) interval:1/5.0];
    
    [self schedule:@selector(gameLogicMissile:) interval:3.0];
    
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
    
    for (CCSprite *missile in _missiles) {
        
        if (CGRectIntersectsRect(rect1, missile.boundingBox) ||
            CGRectIntersectsRect(rect2, missile.boundingBox) ||
            CGRectIntersectsRect(rect3, missile.boundingBox) ||
            CGRectIntersectsRect(rect4, missile.boundingBox) ||
            CGRectIntersectsRect(rect5, missile.boundingBox)) {
            
            [bulletsToDelete addObject:missile];
        }
    }
    
    for (Bullet *bullet in bulletsToDelete) {
        
        [_bullets removeObject:bullet];
        [self removeChild:bullet cleanup:YES];
        
        [_player handleCollisionWith:bullet];
        
        [[GameScene sharedScene] handleGameOver];
    }
    
    for (Missile *missile in bulletsToDelete) {
        
        [_missiles removeObject:missile];
        [self removeChild:missile cleanup:YES];
        
        [_player handleCollisionWith:missile];
        
        [[GameScene sharedScene] handleGameOver];
    }

    
    [bulletsToDelete release];
}

-(void)gameLogicBullet:(ccTime)dt {
    
    [self addBullet];
}

-(void)gameLogicMissile:(ccTime)dt {
    
    [self addMissile];
}

- (void)addBullet {
    
    Bullet *bullet =  [[[Bullet alloc] initWithFile:@"bullet.png" andContainArray:_bullets] autorelease];
    
    if (bullet != nil) {
        
        [_bullets addObject:bullet];
        [self addChild:bullet];
    }
}

- (void)addMissile {
    
    Missile *missile = [[Missile alloc] initWithFile:@"player.png" andContainArray:_missiles targetObject:_player];
    
    if (missile != nil) {
        
        [_missiles addObject:missile];
        [self addChild:missile];
    }
}

@end
