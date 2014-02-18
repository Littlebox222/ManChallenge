//
//  HelloWorldLayer.m
//  ManChallenge
//
//  Created by Littlebox222 on 14-2-11.
//  Copyright Littlebox222 2014年. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "GameOverLayer.h"
#import "SimpleAudioEngine.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

@synthesize player = _player;
@synthesize scoreLayer = _scoreLayer;
@synthesize bullets = _bullets;

- (NSString*)filePath:(NSString*)fileName {
    
    NSArray* myPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* myDocPath = [myPaths objectAtIndex:0];
    NSString* filePath = [myDocPath stringByAppendingPathComponent:fileName];
    return filePath;
}

-(void)dealloc {
    
    [_player removeFromParentAndCleanup:YES];
    
    [_scoreLayer release];
    
    for (CCSprite *node in _bullets) {
        [node removeFromParentAndCleanup:YES];
    }
    
    [_bullets removeAllObjects];
    [_bullets release];
    
    [super dealloc];
}

+(CCScene *) scene {
    
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
    
    ScoreLayer *scLayer = [ScoreLayer node];
    [scene addChild:scLayer];
    layer.scoreLayer = scLayer;
	
	return scene;
}

-(id)init {
    
	if( (self=[super init])) {
		
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        _player = [CCSprite spriteWithFile:@"player.png"];
        _player.tag = 2;
        
        _player.position = ccp(size.width/2, size.height/2);
        
        [self addChild:_player];
        
        self.isAccelerometerEnabled = YES;
        
        _countTimer = 0;
        
        _bullets = [[NSMutableArray alloc] init];
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"game_music.mp3"];
	}
    
    [self schedule:@selector(gameLogic:) interval:0.001];
    
	return self;
}

static UIAccelerationValue rollingX = 0, rollingY = 0, rollingZ = 0;

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
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
    
    _shipPointsPerSecY = pointsPerSecY;
    _shipPointsPerSecX = pointsPerSecX;
}

-(void) updatePlayer:(ccTime)dt {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    float maxX = winSize.width - _player.contentSize.width/2;
    float minX = _player.contentSize.width/2;
    float newX = _player.position.x + (_shipPointsPerSecX * dt);
    newX = MIN(MAX(newX, minX), maxX);
    
    float maxY = winSize.height - _player.contentSize.height/2;
    float minY = _player.contentSize.height/2;
    float newY = _player.position.y + (_shipPointsPerSecY * dt);
    newY = MIN(MAX(newY, minY), maxY);
    
    _player.position = ccp(newX, newY);
    
    [_scoreLayer scoreTimeChanged:dt];
}

-(void)gameLogic:(ccTime)dt {
    
    _countTimer++;
    
    if (_countTimer == 10) {
        _countTimer = 0;
        [self addBullet];
    }
    
    
    [self updatePlayer:dt];
    
    
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
    
    for (CCSprite *bullet in bulletsToDelete) {
        
        [_bullets removeObject:bullet];
        [self removeChild:bullet cleanup:YES];
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"game_over.mp3"];
        
        CCScene *gameOverScene = [GameOverLayer sceneInitWithScore:_scoreLayer.livingTime andBestScore:_scoreLayer.bestTime];
        [[CCDirector sharedDirector] replaceScene:gameOverScene];
        
        if (_scoreLayer.bestTime < _scoreLayer.livingTime) {
            
            NSString* fileName = [self filePath:@"bestTime.plist"];

            NSMutableArray* data = [[[NSMutableArray alloc] init] autorelease];
            
            [data addObject:[NSString stringWithFormat:@"%f", _scoreLayer.livingTime]];
            [data writeToFile:fileName atomically:YES];
        }
    }
    
    [bulletsToDelete release];
}

- (void)addBullet {
    
    CCSprite *bullet = [CCSprite spriteWithFile:@"bullet.png"];
    bullet.tag = 1;
    [_bullets addObject:bullet];
    
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    // speed
    int minDuration = 3.0;
    int maxDuration = 8.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // start & end
    int edgeStart = arc4random() % 4; // 0 -> up, 1 -> right
    
    int minY = -bullet.contentSize.height / 2;
    int maxY = winSize.height + bullet.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    int minX = -bullet.contentSize.width / 2;
    int maxX = winSize.width + bullet.contentSize.width/2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    
    CCMoveTo *actionMove;
    CGPoint endPosition;
    int edgeEnd = arc4random() % 3;
    
    if (edgeStart == 0) {
        
        bullet.position = ccp(actualX, maxY);
        
        int minEndX = -bullet.contentSize.width / 2;
        int maxEndX = winSize.width + bullet.contentSize.width / 2;
        int rangeEndX = maxEndX - minEndX;
        int actualEndX = (arc4random() % rangeEndX) + minEndX;
        
        int minEndY = -bullet.contentSize.height / 2;
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
        
        bullet.position = ccp(winSize.width + bullet.contentSize.width/2, actualY);
        
        int minEndX = -bullet.contentSize.width / 2;
        int maxEndX = winSize.width / 2;
        int rangeEndX = maxEndX - minEndX;
        int actualEndX = (arc4random() % rangeEndX) + minEndX;
        
        int minEndY = -bullet.contentSize.height / 2;
        int maxEndY = winSize.height + bullet.contentSize.height / 2;
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
        
        bullet.position = ccp(actualX, minY);
        
        int minEndX = -bullet.contentSize.width / 2;
        int maxEndX = winSize.width + bullet.contentSize.width / 2;
        int rangeEndX = maxEndX - minEndX;
        int actualEndX = (arc4random() % rangeEndX) + minEndX;
        
        int minEndY = winSize.height / 2;
        int maxEndY = winSize.height + bullet.contentSize.height / 2;
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
        
        bullet.position = ccp(-bullet.contentSize.width/2, actualY);
        
        int minEndX = winSize.width / 2;
        int maxEndX = winSize.width + bullet.contentSize.width / 2;
        int rangeEndX = maxEndX - minEndX;
        int actualEndX = (arc4random() % rangeEndX) + minEndX;
        
        int minEndY = -bullet.contentSize.height / 2;
        int maxEndY = winSize.height + bullet.contentSize.height / 2;
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
    
    [self addChild:bullet];
    

    // animation
    actionMove = [CCMoveTo actionWithDuration:actualDuration position:endPosition];
    
    CCCallBlockN *actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node removeFromParentAndCleanup:YES];
        [_bullets removeObject:node];
    }];
    
    [bullet runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    
}


#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
