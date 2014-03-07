//
//  GameObject.h
//  ManChallenge
//
//  Created by Littlebox222 on 14-3-7.
//  Copyright (c) 2014年 Littlebox222. All rights reserved.
//
#import "cocos2d.h"
#import "Global.h"
#import "CCNode.h"

@interface GameObject : CCSprite
{
    BOOL _isScheduleForRemove;
}

@property (nonatomic, assign) BOOL isScheduleForRemove;

- (void)update:(ccTime)delta;

- (void)handleCollisionWith:(GameObject*)gameObject;

@end
