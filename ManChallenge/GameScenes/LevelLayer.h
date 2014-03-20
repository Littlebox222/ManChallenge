//
//  LevelLayer.h
//  ManChallenge
//
//  Created by Littlebox222 on 14-3-7.
//  Copyright (c) 2014年 Littlebox222. All rights reserved.
//

#import "CCLayer.h"
#import "Hero.h"
#import "Bullet.h"
#import "Missile.h"
#import "BlackHole.h"

@interface LevelLayer : CCLayer

@property (nonatomic, retain) Hero *player;
@property (nonatomic, retain) NSMutableArray *bullets;
@property (nonatomic, retain) NSMutableArray *missiles;

@end
