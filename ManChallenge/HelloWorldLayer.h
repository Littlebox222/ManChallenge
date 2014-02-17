//
//  HelloWorldLayer.h
//  ManChallenge
//
//  Created by Littlebox222 on 14-2-11.
//  Copyright Littlebox222 2014年. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "ScoreLayer.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate> {
    
    float _shipPointsPerSecX;
    float _shipPointsPerSecY;
    int _countTimer;
}

@property (nonatomic, retain) CCSprite *player;
@property (nonatomic, retain) ScoreLayer *scoreLayer;
@property (nonatomic, retain) NSMutableArray *bullets;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

-(void) updatePlayer:(ccTime)dt;

@end
