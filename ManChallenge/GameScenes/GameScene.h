//
//  GameScene.h
//  ManChallenge
//
//  Created by Littlebox222 on 14-3-7.
//  Copyright (c) 2014年 Littlebox222. All rights reserved.
//

#import "cocos2d.h"
#import "LevelLayer.h"
#import "ScoreLayer.h"

#import "Snapshoter.h"

@interface GameScene : CCLayer <SnapshoterDelegate> {
    
    LevelLayer *_levelLayer;
    ScoreLayer *_scoreLayer;
    
    CCSprite *_background1;
    CCSprite *_background2;
    
    BOOL destroyed;
}


@property (nonatomic, retain) LevelLayer *levelLayer;
@property (nonatomic, retain) ScoreLayer *scoreLayer;

@property (nonatomic, retain) CCSprite *background1;
@property (nonatomic, retain) CCSprite *background2;

@property (nonatomic, retain) Snapshoter *snapshorer;

+ (GameScene *)sharedScene;
- (void)handleGameOver;
- (void)handleLevelChanged;
- (id)initWithBackgroundFile:(NSString *)filename;

@end
