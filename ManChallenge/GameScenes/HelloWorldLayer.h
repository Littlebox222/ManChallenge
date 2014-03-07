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

#import "THCapture.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate, THCaptureDelegate> {
    
    float _shipPointsPerSecX;
    float _shipPointsPerSecY;
    
    int colorRampUniformLocation;
}

@property (nonatomic, retain) CCSprite *player;
@property (nonatomic, retain) ScoreLayer *scoreLayer;
@property (nonatomic, retain) NSMutableArray *bullets;

@property (nonatomic, retain) THCapture *capture;


// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

-(void) updatePlayer:(ccTime)dt;

@end
